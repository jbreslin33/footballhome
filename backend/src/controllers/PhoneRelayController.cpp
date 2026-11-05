#include "PhoneRelayController.h"

#include <cctype>
#include <iostream>

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "../services/TwilioService.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    r.setHeader("Cache-Control", "no-store");
    return r;
}

Response jsonError(HttpStatus s, const std::string& message, const std::string& code = "") {
    json b = {{"error", message}};
    if (!code.empty()) b["code"] = code;
    return jsonOut(s, b);
}

bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}

std::string str(const json& j, const char* k) {
    return j.contains(k) && j[k].is_string() ? j[k].get<std::string>() : std::string{};
}

long long num(const json& j, const char* k) {
    return j.contains(k) && j[k].is_number_integer() ? j[k].get<long long>() : 0;
}

// The last ten digits of a US number — the form person_phones is matched on.
std::string tenDigits(const std::string& raw) {
    std::string d;
    for (unsigned char c : raw) if (std::isdigit(c)) d.push_back(static_cast<char>(c));
    if (d.size() == 11 && d[0] == '1') d.erase(0, 1);
    return d.size() == 10 ? d : std::string{};
}

// Pairing codes: 8 characters from an alphabet without look-alikes (no
// 0/O, 1/I/L), so typing one into a phone is easy.
std::string pairCode() {
    static const char* kAlphabet = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
    const std::string raw = fh::crypto::randomTokenB64Url(16);
    std::string code;
    for (unsigned char c : raw) {
        code.push_back(kAlphabet[c % 31]);
        if (code.size() == 8) break;
    }
    return code;
}

std::string upperAlnum(const std::string& s) {
    std::string out;
    for (unsigned char c : s) if (std::isalnum(c)) out.push_back(static_cast<char>(std::toupper(c)));
    return out;
}

long long idFromPath(const std::string& path) {
    const auto slash = path.find_last_of('/');
    try { return std::stoll(path.substr(slash + 1)); } catch (...) { return 0; }
}

std::string isoCol(const std::string& col) {
    return "to_char(" + col + " AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS " + col.substr(col.find('.') + 1);
}

const std::string kTextCols = "id, status, error, " + isoCol("created_at") + ", " + isoCol("sent_at") + ", "
                            + isoCol("delivered_at") + ", " + isoCol("not_before");

json textRow(const pqxx::row& r) {
    json t = json::object();
    for (const char* k : {"status", "error", "created_at", "sent_at", "delivered_at", "not_before"})
        t[k] = r[k].is_null() ? json(nullptr) : json(r[k].c_str());
    t["id"] = r["id"].as<long long>();
    return t;
}

}  // namespace

void PhoneRelayController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/status",        [this](const Request& r) { return handleStatus(r); });
    router.post(prefix + "/pair-code",     [this](const Request& r) { return handlePairCode(r); });
    router.post(prefix + "/texts",         [this](const Request& r) { return handleQueue(r); });
    router.get (prefix + "/contact-state", [this](const Request& r) { return handleContactState(r); });
    router.post(prefix + "/club-text",     [this](const Request& r) { return handleClubText(r); });
    router.get (prefix + "/texts/:id",     [this](const Request& r) { return handleTextStatus(r); });
    router.get (prefix + "/send-status",   [this](const Request& r) { return handleSendStatus(r); });
    router.post(prefix + "/device-send",   [this](const Request& r) { return handleDeviceSend(r); });
    router.get (prefix + "/history",       [this](const Request& r) { return handleHistory(r); });
    router.post(prefix + "/device/pair",   [this](const Request& r) { return handleDevicePair(r); });
    router.post(prefix + "/device/next",   [this](const Request& r) { return handleDeviceNext(r); });
    router.post(prefix + "/device/report", [this](const Request& r) { return handleDeviceReport(r); });
}

// Club admins only for now — the owner is the one texting from his own
// number; a coach gets this the day one asks for it.
bool PhoneRelayController::requireSender(const Request& request, long long* personId, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Sign in first.");
        return false;
    }
    auto r = Database::getInstance()->query(
        "SELECT u.person_id FROM users u JOIN admins a ON a.user_id = u.id "
        " WHERE u.id = $1::int AND u.person_id IS NOT NULL LIMIT 1",
        {std::to_string(bearerUserId(request))});
    if (r.empty()) {
        *error = jsonError(HttpStatus::FORBIDDEN, "Only club admins can send from their phone.");
        return false;
    }
    *personId = r[0]["person_id"].as<long long>();
    return true;
}

// The app's token, from pairing, stored only as its sha256 like session
// and magic-link tokens.  A revoked phone is refused.
bool PhoneRelayController::requireDevice(const Request& request, long long* deviceId, Response* error) {
    const std::string token = request.getHeader("X-FH-Device");
    if (token.size() < 20) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Pair this phone first.", "not_paired");
        return false;
    }
    auto r = Database::getInstance()->query(
        "SELECT id FROM phone_relay_devices WHERE token_hash = $1 AND revoked_at IS NULL",
        {fh::crypto::sha256Hex(token)});
    if (r.empty()) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "This phone is no longer paired — pair it again.", "not_paired");
        return false;
    }
    *deviceId = r[0]["id"].as<long long>();
    return true;
}

// GET /status — the desktop panel's view: is a phone paired and online,
// and how many of today's texts are used.
Response PhoneRelayController::handleStatus(const Request& request) {
    long long personId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireSender(request, &personId, &err)) return err;
    try {
        auto* db = Database::getInstance();
        json devices = json::array();
        for (const auto& r : db->query(
                "SELECT d.id, d.name, " + isoCol("d.last_seen_at") + ", "
                "       COALESCE(d.last_seen_at > now() - make_interval(secs => p.online_seconds), false) AS online "
                "  FROM phone_relay_devices d, phone_relay_policy p "
                " WHERE d.person_id = $1::int AND d.revoked_at IS NULL ORDER BY d.last_seen_at DESC NULLS LAST",
                {std::to_string(personId)})) {
            devices.push_back({{"id", r["id"].as<long long>()}, {"name", r["name"].c_str()},
                               {"online", r["online"].as<bool>()},
                               {"last_seen_at", r["last_seen_at"].is_null() ? json(nullptr) : json(r["last_seen_at"].c_str())}});
        }
        auto c = db->query(
            "SELECT p.daily_cap, (SELECT count(*) FROM phone_relay_texts t WHERE t.sender_person_id = $1::int "
            "   AND t.status <> 'expired' "
            "   AND (t.created_at AT TIME ZONE 'America/New_York')::date = (now() AT TIME ZONE 'America/New_York')::date) AS today "
            "  FROM phone_relay_policy p", {std::to_string(personId)});
        return jsonOut(HttpStatus::OK, {{"devices", devices},
                                        {"today", c.empty() ? 0 : c[0]["today"].as<long long>()},
                                        {"cap", c.empty() ? 0 : c[0]["daily_cap"].as<long long>()}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleStatus: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the phone status");
    }
}

// POST /pair-code — a one-time code for the app, good for 15 minutes.
Response PhoneRelayController::handlePairCode(const Request& request) {
    long long personId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireSender(request, &personId, &err)) return err;
    try {
        const std::string code = pairCode();
        Database::getInstance()->query(
            "INSERT INTO phone_relay_pair_codes (code_hash, person_id, expires_at) "
            "VALUES ($1, $2::int, now() + interval '15 minutes')",
            {fh::crypto::sha256Hex(code), std::to_string(personId)});
        return jsonOut(HttpStatus::CREATED, {{"code", code}, {"apk_url", "https://footballhome.org/app/fh-texter.apk"}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handlePairCode: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not make a pairing code");
    }
}

// True when this number replied STOP and has not opted back in.
static bool isStopped(const std::string& digits) {
    return !Database::getInstance()->query(
        "SELECT 1 FROM sms_opt_outs o WHERE o.phone_digits = $1 "
        "   AND NOT EXISTS (SELECT 1 FROM sms_opt_ins i WHERE i.phone_digits = $1 AND i.consented_at > o.received_at) LIMIT 1",
        {digits}).empty();
}

static bool isOptedIn(long long personId) {
    auto r = Database::getInstance()->query(
        "SELECT fh_sms_consented_at($1::int) IS NOT NULL AS ok", {std::to_string(personId)});
    return !r.empty() && r[0]["ok"].as<bool>();
}

// GET /contact-state?person_id=&to= — which texting routes the Contact
// popup may offer: 'in' (opted in), 'stopped', or 'none'.  A lead is not a
// person yet: person_id 0 answers for the number alone, never 'in'.
Response PhoneRelayController::handleContactState(const Request& request) {
    long long senderId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireSender(request, &senderId, &err)) return err;
    long long personId = 0;
    try { personId = std::stoll(request.getQueryParam("person_id")); } catch (...) {}
    const std::string digits = tenDigits(request.getQueryParam("to"));
    if (personId <= 0 && digits.empty()) return jsonError(HttpStatus::BAD_REQUEST, "person_id or to is required.");
    try {
        const std::string consent = (!digits.empty() && isStopped(digits)) ? "stopped"
                                  : (personId > 0 && isOptedIn(personId)) ? "in" : "none";
        return jsonOut(HttpStatus::OK, {{"consent", consent}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleContactState: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not read their text settings");
    }
}

// POST /club-text {person_id, to, body, for_person_id?, purpose?} — one
// text from the club number, from the Contact popup.  Opted-in people
// only, never after a STOP, only to a number on that person; brand first
// and opt-out last, as the A2P campaign promises.
Response PhoneRelayController::handleClubText(const Request& request) {
    long long senderId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireSender(request, &senderId, &err)) return err;
    json body;
    if (!parseBody(request, &body, &err)) return err;
    const long long personId = num(body, "person_id");
    const long long forPersonId = num(body, "for_person_id");
    const std::string rawTo = str(body, "to");
    const std::string text = str(body, "body");
    const std::string purpose = str(body, "purpose");
    const std::string digits = tenDigits(rawTo);
    if (personId <= 0 || digits.empty()) return jsonError(HttpStatus::BAD_REQUEST, "Not a US mobile number.");
    if (text.empty() || text.size() > 1500) return jsonError(HttpStatus::BAD_REQUEST, "The message is empty or too long.");
    try {
        auto owned = Database::getInstance()->query(
            "SELECT 1 FROM person_phones pp WHERE pp.person_id = $1::int "
            "   AND right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10) = $2 LIMIT 1",
            {std::to_string(personId), digits});
        if (owned.empty()) return jsonError(HttpStatus::FORBIDDEN, "That number isn't on this person.");
        if (isStopped(digits)) return jsonError(HttpStatus::CONFLICT, "They replied STOP — call them instead.", "stopped");
        if (!isOptedIn(personId)) return jsonError(HttpStatus::CONFLICT, "They haven't opted in to club texts.", "not_opted_in");
        MessageCopy copy;
        const auto pre  = copy.render("club_sms", "prefix", {});
        const auto foot = copy.render("club_sms", "footer", {});
        const auto sent = TwilioService::getInstance().sendSms(
            TwilioService::normalizeUs(digits), pre.body + text + foot.body,
            purpose.empty() ? "contact" : purpose, forPersonId > 0 ? forPersonId : personId, 0);
        if (!sent.ok) return jsonError(HttpStatus::BAD_GATEWAY, "The club text did not go out: " + sent.error);
        return jsonOut(HttpStatus::CREATED, {{"sent", true}, {"sid", sent.sid}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleClubText: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not send the club text");
    }
}

// POST /texts {to, body, for_person_id?, purpose?, magic_link_token_id?} — one text, one
// recipient, from the sender's own phone.  Every guardrail is checked
// here, before anything reaches the phone.
Response PhoneRelayController::handleQueue(const Request& request) {
    long long personId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireSender(request, &personId, &err)) return err;
    json body;
    if (!parseBody(request, &body, &err)) return err;
    const std::string rawTo = str(body, "to");
    const std::string text = str(body, "body");
    const std::string purpose = str(body, "purpose");
    const long long forPersonId = num(body, "for_person_id");
    const long long tokenId = num(body, "magic_link_token_id");
    if (rawTo.find_first_of(",;") != std::string::npos)
        return jsonError(HttpStatus::BAD_REQUEST, "One person at a time from your number.", "group");
    const std::string digits = tenDigits(rawTo);
    if (digits.empty()) return jsonError(HttpStatus::BAD_REQUEST, "Not a US mobile number.");
    if (text.empty() || text.size() > 1600) return jsonError(HttpStatus::BAD_REQUEST, "The message is empty or too long.");
    try {
        auto* db = Database::getInstance();
        // Only numbers on someone in the club's records, never a typed-in one:
        // a person, an active club contact — the other teams' coaches and
        // league offices on #opponents / Game Center 📇 (owner 2026-10-28) —
        // or a lead who gave it on a form (#leads, owner 2026-11-02).
        auto owner = db->query(
            "SELECT 1 FROM person_phones pp "
            " WHERE right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10) = $1 "
            "UNION ALL "
            "SELECT 1 FROM club_contacts cc "
            " WHERE cc.is_active AND right(regexp_replace(COALESCE(cc.phone, ''), '[^0-9]', '', 'g'), 10) = $1 "
            "UNION ALL "
            "SELECT 1 FROM leads l "
            " WHERE right(regexp_replace(COALESCE(l.phone, ''), '[^0-9]', '', 'g'), 10) = $1 "
            "LIMIT 1",
            {digits});
        if (owner.empty())
            return jsonError(HttpStatus::FORBIDDEN, "That number isn't on anyone in the club's records.");
        // Anyone who replied STOP to the club number is not texted from a
        // personal number either, until they text START.
        auto stop = db->query(
            "SELECT 1 FROM sms_opt_outs o WHERE o.phone_digits = $1 "
            "   AND NOT EXISTS (SELECT 1 FROM sms_opt_ins i WHERE i.phone_digits = $1 AND i.consented_at > o.received_at) LIMIT 1",
            {digits});
        if (!stop.empty()) return jsonError(HttpStatus::CONFLICT, "They replied STOP — call them instead.", "stopped");

        auto dev = db->query(
            "SELECT d.id FROM phone_relay_devices d, phone_relay_policy p "
            " WHERE d.person_id = $1::int AND d.revoked_at IS NULL "
            "   AND d.last_seen_at > now() - make_interval(secs => p.online_seconds) "
            " ORDER BY d.last_seen_at DESC LIMIT 1", {std::to_string(personId)});
        if (dev.empty()) return jsonError(HttpStatus::CONFLICT, "Your phone is offline — open FH Texter on it.", "offline");
        const long long deviceId = dev[0]["id"].as<long long>();

        auto tx = db->beginTransaction();
        // One sender at a time, so the cap and the spacing can't race.
        tx->exec_params("SELECT pg_advisory_xact_lock(667, $1)", static_cast<int>(personId));
        auto cap = tx->exec_params(
            "SELECT p.daily_cap, "
            "       (SELECT count(*) FROM phone_relay_texts t WHERE t.sender_person_id = $1 AND t.status <> 'expired' "
            "           AND (t.created_at AT TIME ZONE 'America/New_York')::date = (now() AT TIME ZONE 'America/New_York')::date) AS today "
            "  FROM phone_relay_policy p", personId);
        const long long today = cap[0]["today"].as<long long>(), dailyCap = cap[0]["daily_cap"].as<long long>();
        if (today >= dailyCap) {
            db->commit(tx);
            return jsonError(HttpStatus::CONFLICT, "Daily limit reached (" + std::to_string(today) + " today) — protects your number.", "cap");
        }
        // The next free slot: min_gap_seconds after this phone's last one.
        auto ins = tx->exec_params(
            "INSERT INTO phone_relay_texts (device_id, sender_person_id, for_person_id, to_phone, body, purpose, "
            "                               magic_link_token_id, not_before) "
            "SELECT $1, $2, NULLIF($3, 0), $4, $5, NULLIF($6, ''), "
            "       (SELECT k.id FROM magic_link_tokens k WHERE k.id = NULLIF($7, 0)), "
            "       GREATEST(now(), COALESCE((SELECT max(t.not_before) FROM phone_relay_texts t WHERE t.device_id = $1 "
            "                                   AND t.status IN ('queued', 'sending', 'sent', 'delivered')), now() - interval '1 day') "
            "                       + make_interval(secs => p.min_gap_seconds)) "
            "  FROM phone_relay_policy p "
            "RETURNING " + kTextCols,
            deviceId, personId, forPersonId, "+1" + digits, text, purpose, tokenId);
        db->commit(tx);
        json out = textRow(ins[0]);
        out["today"] = today + 1;
        out["cap"] = dailyCap;
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleQueue: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not queue the text");
    }
}

// GET /texts/:id — the panel polls this until sent / delivered / failed.
Response PhoneRelayController::handleTextStatus(const Request& request) {
    long long personId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireSender(request, &personId, &err)) return err;
    const long long id = idFromPath(request.getPath());
    try {
        auto r = Database::getInstance()->query(
            "SELECT " + kTextCols + " FROM phone_relay_texts WHERE id = $1::bigint AND sender_person_id = $2::int",
            {std::to_string(id), std::to_string(personId)});
        if (r.empty()) return jsonError(HttpStatus::NOT_FOUND, "No such text");
        return jsonOut(HttpStatus::OK, textRow(r[0]));
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleTextStatus: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the text");
    }
}

// GET /send-status?relay_id=&sid=&token_id= — what happened to one send from
// the 📇 Contact popup (owner 2026-11-05: "i need status after send"): the
// FH Texter row (queued → sent → delivered / failed), the club text's Twilio
// status (queued → sent → delivered / undelivered / failed + error code),
// and whether the sign-in link in it was opened (magic_link_tokens.consumed_at).
// Any part not asked for comes back null.  Admins and coaches (requireStaff).
Response PhoneRelayController::handleSendStatus(const Request& request) {
    long long personId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireStaff(request, &personId, &err)) return err;   // coaches too (their popup sends)
    const auto num = [&](const char* k) -> std::string {
        const std::string v = request.getQueryParam(k);
        return (!v.empty() && v.find_first_not_of("0123456789") == std::string::npos) ? v : std::string{};
    };
    const std::string relayId = num("relay_id"), tokenId = num("token_id");
    std::string sid = request.getQueryParam("sid");
    if (sid.size() > 64 || sid.find_first_not_of("ABCDEFabcdef0123456789SMMM") != std::string::npos) sid.clear();
    try {
        auto* db = Database::getInstance();
        json out = {{"relay", nullptr}, {"club", nullptr}, {"link", nullptr}};
        if (!relayId.empty()) {
            auto r = db->query("SELECT " + kTextCols + " FROM phone_relay_texts WHERE id = $1::bigint AND sender_person_id = $2::int",
                               {relayId, std::to_string(personId)});
            if (!r.empty()) out["relay"] = textRow(r[0]);
        }
        if (!sid.empty()) {
            auto r = db->query(
                "SELECT status, error_code, " + isoCol("updated_at") + " FROM sms_messages "
                " WHERE message_sid = $1 AND direction = 'out' ORDER BY id DESC LIMIT 1", {sid});
            if (!r.empty())
                out["club"] = {{"status", r[0]["status"].is_null() ? json(nullptr) : json(r[0]["status"].c_str())},
                               {"error_code", r[0]["error_code"].is_null() ? json(nullptr) : json(r[0]["error_code"].c_str())},
                               {"updated_at", r[0]["updated_at"].is_null() ? json(nullptr) : json(r[0]["updated_at"].c_str())}};
        }
        if (!tokenId.empty()) {
            auto r = db->query("SELECT " + isoCol("consumed_at") + " FROM magic_link_tokens WHERE id = $1::int", {tokenId});
            if (!r.empty())
                out["link"] = {{"opened_at", r[0]["consumed_at"].is_null() ? json(nullptr) : json(r[0]["consumed_at"].c_str())}};
        }
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleSendStatus: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the send status");
    }
}

// Admins and coaches — everyone the 📇 popup is drawn for (mig 1085).
bool PhoneRelayController::requireStaff(const Request& request, long long* personId, Response* error) {
    if (!requireBearer(request)) { *error = jsonError(HttpStatus::UNAUTHORIZED, "Sign in first."); return false; }
    auto r = Database::getInstance()->query(
        "SELECT u.person_id FROM users u WHERE u.id = $1::int AND u.person_id IS NOT NULL "
        "   AND (EXISTS (SELECT 1 FROM admins a WHERE a.user_id = u.id) "
        "        OR EXISTS (SELECT 1 FROM coaches c JOIN team_coaches tc ON tc.coach_id = c.id AND tc.ended_at IS NULL "
        "                    WHERE c.person_id = u.person_id)) LIMIT 1",
        {std::to_string(bearerUserId(request))});
    if (r.empty()) { *error = jsonError(HttpStatus::FORBIDDEN, "Coaches and admins only."); return false; }
    *personId = r[0]["person_id"].as<long long>();
    return true;
}

// POST /device-send {person_id?, for_person_id?, via: email|text, contact,
// label, subject, body, token_id?} — a ✉ / 💬 send opened in the sender's own
// app; nothing else records it, so the popup's log would miss it.
Response PhoneRelayController::handleDeviceSend(const Request& request) {
    long long senderId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireStaff(request, &senderId, &err)) return err;
    json body;
    if (!parseBody(request, &body, &err)) return err;
    const std::string via = str(body, "via");
    if (via != "email" && via != "text") return jsonError(HttpStatus::BAD_REQUEST, "via must be email or text");
    const auto idOf = [&](const char* k) -> std::string {
        if (!body.contains(k) || !body[k].is_number_integer() || body[k].get<long long>() <= 0) return "";
        return std::to_string(body[k].get<long long>());
    };
    auto cut = [](std::string v, size_t n) { if (v.size() > n) v.resize(n); return v; };
    try {
        auto r = Database::getInstance()->query(
            "INSERT INTO contact_sends (person_id, for_person_id, sender_person_id, via, contact, label, subject, body, magic_link_token_id) "
            "VALUES (NULLIF($1, '')::int, NULLIF($2, '')::int, $3::int, $4, NULLIF($5, ''), NULLIF($6, ''), NULLIF($7, ''), NULLIF($8, ''), "
            "        (SELECT k.id FROM magic_link_tokens k WHERE k.id = NULLIF($9, '')::int)) RETURNING id",
            {idOf("person_id"), idOf("for_person_id"), std::to_string(senderId), via,
             cut(str(body, "contact"), 200), cut(str(body, "label"), 200), cut(str(body, "subject"), 300),
             cut(str(body, "body"), 4000), idOf("token_id")});
        return jsonOut(HttpStatus::CREATED, {{"id", r[0]["id"].as<long long>()}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleDeviceSend: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not log the send");
    }
}

// GET /history?person_id=&phone=&email= — the contact's last 20 messages,
// newest first: club texts (sms_messages), FH Texter (phone_relay_texts) and
// ✉ / 💬 sends (contact_sends), each with method, words, status and whether
// its sign-in link was opened.
Response PhoneRelayController::handleHistory(const Request& request) {
    long long staffId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireStaff(request, &staffId, &err)) return err;
    std::string pid = request.getQueryParam("person_id");
    if (pid.empty() || pid.find_first_not_of("0123456789") != std::string::npos) pid = "0";
    const std::string digits = tenDigits(request.getQueryParam("phone"));
    std::string email = request.getQueryParam("email");
    if (email.size() > 200) email.clear();
    try {
        auto rows = Database::getInstance()->query(R"SQL(
            SELECT via, to_char(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS at,
                   label, subject, body, status, error, contact,
                   to_char(opened_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS opened_at
              FROM (
                SELECT 'club' AS via, s.created_at, s.purpose AS label, NULL::text AS subject, s.body,
                       s.status, s.error_code AS error, s.to_number AS contact,
                       (SELECT k.consumed_at FROM magic_link_tokens k WHERE k.id = s.magic_link_token_id) AS opened_at
                  FROM sms_messages s
                 WHERE s.direction = 'out'
                   AND (s.person_id = $1::int OR ($2 <> '' AND s.to_number = '+1' || $2))
                UNION ALL
                SELECT 'relay', t.created_at, t.purpose, NULL, t.body, t.status, t.error, t.to_phone,
                       (SELECT k.consumed_at FROM magic_link_tokens k WHERE k.id = t.magic_link_token_id)
                  FROM phone_relay_texts t
                 WHERE ($2 <> '' AND t.to_phone = '+1' || $2) OR (($2 = '') AND t.for_person_id = $1::int)
                UNION ALL
                SELECT c.via, c.created_at, c.label, c.subject, c.body, NULL, NULL, c.contact,
                       (SELECT k.consumed_at FROM magic_link_tokens k WHERE k.id = c.magic_link_token_id)
                  FROM contact_sends c
                 WHERE c.person_id = $1::int
                    OR ($3 <> '' AND lower(c.contact) = lower($3))
                    OR ($2 <> '' AND regexp_replace(c.contact, '\D', '', 'g') IN ($2, '1' || $2))
              ) x
             ORDER BY created_at DESC
             LIMIT 20)SQL", {pid, digits, email});
        json out = json::array();
        for (const auto& r : rows) {
            json m = json::object();
            for (const char* k : {"via", "at", "label", "subject", "body", "status", "error", "contact", "opened_at"})
                m[k] = r[k].is_null() ? json(nullptr) : json(r[k].c_str());
            out.push_back(m);
        }
        return jsonOut(HttpStatus::OK, {{"messages", out}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleHistory: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the history");
    }
}

// POST /device/pair {code, name, app_version} — the app trades the code
// for its own long-lived token (stored hashed; handed to the app once).
Response PhoneRelayController::handleDevicePair(const Request& request) {
    json body;
    Response err(HttpStatus::OK, "");
    if (!parseBody(request, &body, &err)) return err;
    const std::string code = upperAlnum(str(body, "code"));
    if (code.size() != 8) return jsonError(HttpStatus::BAD_REQUEST, "The code is 8 letters and numbers.");
    std::string name = str(body, "name");
    if (name.empty() || name.size() > 60) name = "Android";
    try {
        auto* db = Database::getInstance();
        auto c = db->query(
            "UPDATE phone_relay_pair_codes SET used_at = now() "
            " WHERE code_hash = $1 AND used_at IS NULL AND expires_at > now() RETURNING person_id",
            {fh::crypto::sha256Hex(code)});
        if (c.empty()) return jsonError(HttpStatus::NOT_FOUND, "That code is wrong or expired — make a new one on the computer.");
        const std::string token = fh::crypto::randomTokenB64Url(32);
        db->query("INSERT INTO phone_relay_devices (person_id, name, token_hash, app_version, last_seen_at) "
                  "VALUES ($1::int, $2, $3, NULLIF($4, ''), now())",
                  {c[0]["person_id"].c_str(), name, fh::crypto::sha256Hex(token), str(body, "app_version")});
        auto who = db->query("SELECT COALESCE(first_name, '') AS fn FROM persons WHERE id = $1::int", {c[0]["person_id"].c_str()});
        return jsonOut(HttpStatus::CREATED, {{"token", token}, {"first_name", who.empty() ? "" : who[0]["fn"].c_str()}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleDevicePair: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not pair");
    }
}

// POST /device/next — the app's heartbeat (every few seconds while it
// runs).  Expires what waited too long, then hands over the next text
// whose slot has come.  One at a time: nothing new while one is sending.
Response PhoneRelayController::handleDeviceNext(const Request& request) {
    long long deviceId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireDevice(request, &deviceId, &err)) return err;
    json body;
    if (!parseBody(request, &body, &err)) return err;
    try {
        auto* db = Database::getInstance();
        const std::string dev = std::to_string(deviceId);
        db->query("UPDATE phone_relay_devices SET last_seen_at = now(), app_version = COALESCE(NULLIF($2, ''), app_version) "
                  " WHERE id = $1::int", {dev, str(body, "app_version")});
        db->query("UPDATE phone_relay_texts t SET status = 'expired' FROM phone_relay_policy p "
                  " WHERE t.device_id = $1::int AND t.status = 'queued' "
                  "   AND t.created_at < now() - make_interval(mins => p.expire_minutes)", {dev});
        db->query("UPDATE phone_relay_texts SET status = 'failed', error = 'the phone never confirmed it' "
                  " WHERE device_id = $1::int AND status = 'sending' AND claimed_at < now() - interval '10 minutes'", {dev});
        if (!db->query("SELECT 1 FROM phone_relay_texts WHERE device_id = $1::int AND status = 'sending' LIMIT 1", {dev}).empty())
            return jsonOut(HttpStatus::OK, {{"text", nullptr}});
        auto r = db->query(
            "UPDATE phone_relay_texts SET status = 'sending', claimed_at = now() "
            " WHERE id = (SELECT id FROM phone_relay_texts WHERE device_id = $1::int AND status = 'queued' "
            "              AND not_before <= now() ORDER BY not_before, id LIMIT 1 FOR UPDATE SKIP LOCKED) "
            "RETURNING id, to_phone, body", {dev});
        if (r.empty()) return jsonOut(HttpStatus::OK, {{"text", nullptr}});
        return jsonOut(HttpStatus::OK, {{"text", {{"id", r[0]["id"].as<long long>()},
                                                  {"to", r[0]["to_phone"].c_str()},
                                                  {"body", r[0]["body"].c_str()}}}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleDeviceNext: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not check for texts");
    }
}

// POST /device/report {id, status, error?} — Android's sent / delivered
// broadcasts, or the reason it failed.
Response PhoneRelayController::handleDeviceReport(const Request& request) {
    long long deviceId = 0;
    Response err(HttpStatus::OK, "");
    if (!requireDevice(request, &deviceId, &err)) return err;
    json body;
    if (!parseBody(request, &body, &err)) return err;
    const long long id = num(body, "id");
    const std::string status = str(body, "status");
    if (id <= 0 || (status != "sent" && status != "delivered" && status != "failed"))
        return jsonError(HttpStatus::BAD_REQUEST, "id and status (sent, delivered, failed) required");
    try {
        // Delivered never steps back to sent; a failure keeps its reason.
        Database::getInstance()->query(
            "UPDATE phone_relay_texts SET status = CASE WHEN status = 'delivered' THEN status ELSE $3 END, "
            "       error = CASE WHEN $3 = 'failed' THEN NULLIF($4, '') ELSE error END, "
            "       sent_at = CASE WHEN $3 IN ('sent', 'delivered') THEN COALESCE(sent_at, now()) ELSE sent_at END, "
            "       delivered_at = CASE WHEN $3 = 'delivered' THEN now() ELSE delivered_at END "
            " WHERE id = $1::bigint AND device_id = $2::int",
            {std::to_string(id), std::to_string(deviceId), status, str(body, "error").substr(0, 300)});
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "PhoneRelayController::handleDeviceReport: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not record the report");
    }
}
