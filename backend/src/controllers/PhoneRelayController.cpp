#include "PhoneRelayController.h"

#include <cctype>
#include <iostream>

#include "../core/Crypto.h"
#include "../database/Database.h"
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
    router.get (prefix + "/texts/:id",     [this](const Request& r) { return handleTextStatus(r); });
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
        // Only numbers on someone in the club's records, never a typed-in one.
        auto owner = db->query(
            "SELECT pp.person_id FROM person_phones pp "
            " WHERE right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10) = $1 LIMIT 1",
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
