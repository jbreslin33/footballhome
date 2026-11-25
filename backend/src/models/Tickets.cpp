#include "Tickets.h"

#include <algorithm>
#include <cctype>

#include "../database/Database.h"

using json = nlohmann::json;

namespace {

// A home match's time: the kickoff when known, else the calendar start.
// Cancelled or deleted calendar entries are not games.
const char* kGameJoin =
    " FROM fh_events e "
    " JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL "
    "                   AND COALESCE(g.status, '') <> 'cancelled' "
    " CROSS JOIN LATERAL (SELECT COALESCE(e.kickoff_at, g.starts_at) AS ts) x ";

// Is ticket t (with product p) good for game e?  Single-game: its own game.
// Season: a home match of the product's league inside its window (dates in
// Philadelphia time).
const char* kValidFor =
    " ((p.kind = 'single' AND t.fh_event_id = e.id) "
    "  OR (p.kind = 'season' AND e.kind = 'match' AND e.is_home "
    "      AND upper(COALESCE(e.league, '')) = upper(p.league) "
    "      AND (x.ts AT TIME ZONE 'America/New_York')::date BETWEEN p.valid_from AND p.valid_to)) ";

std::string str(const pqxx::field& f) { return f.is_null() ? std::string() : std::string(f.c_str()); }

json game(const pqxx::row& r) {
    return {{"id", r["id"].as<long long>()}, {"league", str(r["league"])},
            {"category", str(r["category"])}, {"opponent", str(r["opponent"])},
            {"kickoffAt", str(r["ts"])}};
}

// The token out of whatever was scanned: a bare token or a /t/?k=<token> link.
std::string tokenOf(const std::string& code) {
    std::string s = code;
    const auto k = s.find("k=");
    if (k != std::string::npos) s = s.substr(k + 2);
    std::string out;
    for (char c : s) {
        if (std::isalnum(static_cast<unsigned char>(c))) out += static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
        else if (!out.empty()) break;
    }
    return out.size() > 64 ? std::string() : out;
}

}  // namespace

json Tickets::gateGames() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(
            std::string("SELECT e.id, e.league, e.category, e.opponent, x.ts::text AS ts, "
                        "       (x.ts AT TIME ZONE 'America/New_York')::date = (now() AT TIME ZONE 'America/New_York')::date AS today ")
            + kGameJoin +
            " WHERE e.kind = 'match' AND e.is_home "
            "   AND x.ts BETWEEN now() - interval '1 day' AND now() + interval '14 days' "
            " ORDER BY x.ts")) {
        json g = game(r);
        g["today"] = r["today"].as<bool>();
        out.push_back(g);
    }
    return out;
}

json Tickets::gateSummary(long long eventId) {
    auto* db = Database::getInstance();
    const std::string id = std::to_string(eventId);
    json out;
    auto in = db->query(
        "SELECT COALESCE((SELECT sum(admitted) FROM ticket_scans WHERE fh_event_id = $1::bigint), 0) AS tickets, "
        "       COALESCE((SELECT sum(n) FROM gate_counts WHERE fh_event_id = $1::bigint), 0) AS walkups", {id});
    out["withTicket"] = in[0]["tickets"].as<int>();
    out["walkups"] = in[0]["walkups"].as<int>();

    json money = json::array();
    for (const auto& r : db->query(
            "SELECT COALESCE(NULLIF(trim(concat_ws(' ', pe.first_name, pe.last_name)), ''), '—') AS seller, "
            "       s.label AS method, s.icon, count(*) AS sales, sum(t.admits) AS people, sum(t.amount)::text AS amount "
            "  FROM tickets t JOIN ticket_sources s ON s.code = t.source_code "
            "  LEFT JOIN persons pe ON pe.id = t.sold_by_person_id "
            " WHERE t.fh_event_id = $1::bigint AND s.is_gate AND t.voided_at IS NULL "
            " GROUP BY 1, s.label, s.icon, s.sort_order ORDER BY 1, s.sort_order", {id})) {
        money.push_back({{"seller", str(r["seller"])}, {"method", str(r["method"])}, {"icon", str(r["icon"])},
                         {"sales", r["sales"].as<int>()}, {"people", r["people"].as<int>()},
                         {"amount", str(r["amount"])}});
    }
    out["money"] = money;

    json scans = json::array();
    for (const auto& r : db->query(
            "SELECT sc.scanned_at::text AS at, sc.admitted, p.label AS product, s.icon, "
            "       COALESCE(h.first_name, hp.first_name, '') AS first "
            "  FROM ticket_scans sc JOIN tickets t ON t.id = sc.ticket_id "
            "  JOIN ticket_products p ON p.id = t.product_id JOIN ticket_sources s ON s.code = t.source_code "
            "  LEFT JOIN ticket_holders h ON h.id = t.holder_id LEFT JOIN persons hp ON hp.id = h.person_id "
            " WHERE sc.fh_event_id = $1::bigint ORDER BY sc.scanned_at DESC LIMIT 12", {id})) {
        scans.push_back({{"at", str(r["at"])}, {"admitted", r["admitted"].as<int>()},
                         {"product", str(r["product"])}, {"icon", str(r["icon"])}, {"first", str(r["first"])}});
    }
    out["scans"] = scans;
    return out;
}

json Tickets::scan(long long eventId, const std::string& code, int want, int scannedByPersonId) {
    auto* db = Database::getInstance();
    const std::string token = tokenOf(code);
    if (token.empty()) return {{"result", "invalid"}};
    auto found = db->query(
        "SELECT t.id, t.admits, t.voided_at IS NOT NULL AS voided, p.label, p.kind, "
        "       COALESCE(h.first_name, hp.first_name, '') AS first, COALESCE(h.last_name, hp.last_name, '') AS last "
        "  FROM tickets t JOIN ticket_products p ON p.id = t.product_id "
        "  LEFT JOIN ticket_holders h ON h.id = t.holder_id LEFT JOIN persons hp ON hp.id = h.person_id "
        " WHERE t.token = $1", {token});
    if (found.empty()) return {{"result", "invalid"}};
    const auto& t = found[0];
    const std::string ticketId = t["id"].c_str();
    const int admits = t["admits"].as<int>();
    json out = {{"admits", admits}, {"product", str(t["label"])},
                {"holder", (str(t["first"]) + " " + str(t["last"]))}};
    if (t["voided"].as<bool>()) { out["result"] = "voided"; return out; }

    const std::string ev = std::to_string(eventId);
    auto valid = db->query(
        std::string("SELECT 1 FROM tickets t JOIN ticket_products p ON p.id = t.product_id, ") +
        "      fh_events e JOIN gcal_events g ON g.id = e.gcal_event_id "
        "      CROSS JOIN LATERAL (SELECT COALESCE(e.kickoff_at, g.starts_at) AS ts) x "
        " WHERE t.id = $1::int AND e.id = $2::bigint AND " + kValidFor, {ticketId, ev});
    if (valid.empty()) { out["result"] = "wrong_game"; return out; }

    auto used = db->query(
        "SELECT COALESCE(sum(admitted), 0) AS n FROM ticket_scans WHERE ticket_id = $1::int AND fh_event_id = $2::bigint",
        {ticketId, ev});
    const int remaining = admits - used[0]["n"].as<int>();
    if (remaining <= 0) { out["result"] = "used"; out["remaining"] = 0; return out; }
    const int n = want <= 0 ? remaining : std::min(want, remaining);
    db->query("INSERT INTO ticket_scans (ticket_id, fh_event_id, admitted, scanned_by_person_id) "
              "VALUES ($1::int, $2::bigint, $3::int, NULLIF($4, '0')::int)",
              {ticketId, ev, std::to_string(n), std::to_string(scannedByPersonId)});
    out["result"] = "ok";
    out["admitted"] = n;
    out["remaining"] = remaining - n;
    return out;
}

json Tickets::sell(long long eventId, const std::string& source, int people,
                   const std::string& amount, const std::string& name,
                   const std::string& phone, int soldByPersonId) {
    auto* db = Database::getInstance();
    if (people < 1 || people > 50) return {{"error", "People must be 1 to 50."}};
    auto src = db->query("SELECT 1 FROM ticket_sources WHERE code = $1 AND is_gate", {source});
    if (src.empty()) return {{"error", "Pick how they paid."}};
    const std::string ev = std::to_string(eventId);
    auto home = db->query("SELECT 1 FROM fh_events WHERE id = $1::bigint AND kind = 'match' AND is_home", {ev});
    if (home.empty()) return {{"error", "Not a home game."}};

    std::string holderId;
    std::string first = name, last;
    const auto sp = name.find(' ');
    if (sp != std::string::npos) { first = name.substr(0, sp); last = name.substr(sp + 1); }
    if (!name.empty() || !phone.empty()) {
        auto h = db->query("INSERT INTO ticket_holders (first_name, last_name, phone) "
                           "VALUES (NULLIF($1, ''), NULLIF($2, ''), NULLIF($3, '')) RETURNING id",
                           {first, last, phone});
        holderId = h[0]["id"].c_str();
    }
    // Amount: what the seller typed, else the single-game price × people
    // ($0 for a free ticket).
    auto t = db->query(
        "INSERT INTO tickets (product_id, holder_id, source_code, fh_event_id, admits, amount, sold_by_person_id) "
        "SELECT p.id, NULLIF($1, '')::int, $2, $3::bigint, $4::int, "
        "       CASE WHEN $2 = 'free' THEN 0 ELSE COALESCE(NULLIF($5, '')::numeric, p.price * $4::int) END, "
        "       NULLIF($6, '0')::int "
        "  FROM ticket_products p WHERE p.code = 'single-game' "
        "RETURNING id, token",
        {holderId, source, ev, std::to_string(people), amount, std::to_string(soldByPersonId)});
    if (t.empty()) return {{"error", "No single-game ticket is set up."}};
    db->query("INSERT INTO ticket_scans (ticket_id, fh_event_id, admitted, scanned_by_person_id) "
              "VALUES ($1::int, $2::bigint, $3::int, NULLIF($4, '0')::int)",
              {t[0]["id"].c_str(), ev, std::to_string(people), std::to_string(soldByPersonId)});
    return {{"token", str(t[0]["token"])}, {"admitted", people}};
}

json Tickets::count(long long eventId, int n, int personId) {
    auto* db = Database::getInstance();
    const std::string ev = std::to_string(eventId);
    if (n == 1 || n == -1) {
        // Never below zero.
        db->query("INSERT INTO gate_counts (fh_event_id, person_id, n) "
                  "SELECT $1::bigint, NULLIF($2, '0')::int, $3::int "
                  " WHERE $3::int = 1 OR COALESCE((SELECT sum(n) FROM gate_counts WHERE fh_event_id = $1::bigint), 0) > 0",
                  {ev, std::to_string(personId), std::to_string(n)});
    }
    return gateSummary(eventId);
}

json Tickets::list() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(
            "SELECT t.id, t.token, t.admits, t.amount::text AS amount, t.created_at::text AS created, "
            "       t.voided_at IS NOT NULL AS voided, p.label AS product, p.kind, s.label AS source, s.icon, "
            "       COALESCE(h.first_name, hp.first_name, '') AS first, COALESCE(h.last_name, hp.last_name, '') AS last, "
            "       COALESCE(h.email, '') AS email, COALESCE(h.phone, '') AS phone, "
            "       e.opponent, (SELECT COALESCE(sum(admitted), 0) FROM ticket_scans sc WHERE sc.ticket_id = t.id) AS scanned "
            "  FROM tickets t JOIN ticket_products p ON p.id = t.product_id JOIN ticket_sources s ON s.code = t.source_code "
            "  LEFT JOIN ticket_holders h ON h.id = t.holder_id LEFT JOIN persons hp ON hp.id = h.person_id "
            "  LEFT JOIN fh_events e ON e.id = t.fh_event_id "
            " ORDER BY t.created_at DESC LIMIT 500")) {
        out.push_back({{"id", r["id"].as<int>()}, {"token", str(r["token"])}, {"admits", r["admits"].as<int>()},
                       {"amount", str(r["amount"])}, {"created", str(r["created"])}, {"voided", r["voided"].as<bool>()},
                       {"product", str(r["product"])}, {"kind", str(r["kind"])}, {"source", str(r["source"])},
                       {"icon", str(r["icon"])}, {"first", str(r["first"])}, {"last", str(r["last"])},
                       {"email", str(r["email"])}, {"phone", str(r["phone"])}, {"opponent", str(r["opponent"])},
                       {"scanned", r["scanned"].as<int>()}});
    }
    return out;
}

json Tickets::publicTicket(const std::string& rawToken) {
    auto* db = Database::getInstance();
    const std::string token = tokenOf(rawToken);
    if (token.empty()) return nullptr;
    auto found = db->query(
        "SELECT t.id, t.admits, t.voided_at IS NOT NULL AS voided, p.label, p.kind, "
        "       COALESCE(h.first_name, hp.first_name, '') AS first "
        "  FROM tickets t JOIN ticket_products p ON p.id = t.product_id "
        "  LEFT JOIN ticket_holders h ON h.id = t.holder_id LEFT JOIN persons hp ON hp.id = h.person_id "
        " WHERE t.token = $1", {token});
    if (found.empty()) return nullptr;
    const auto& t = found[0];
    json out = {{"token", token}, {"admits", t["admits"].as<int>()}, {"voided", t["voided"].as<bool>()},
                {"product", str(t["label"])}, {"kind", str(t["kind"])}, {"first", str(t["first"])}};
    // Its games: the ones still to come, and any already played that it was
    // used at.
    json games = json::array();
    for (const auto& r : db->query(
            std::string("SELECT e.id, e.league, e.category, e.opponent, x.ts::text AS ts, "
                        "       COALESCE((SELECT sum(admitted) FROM ticket_scans sc WHERE sc.ticket_id = t.id AND sc.fh_event_id = e.id), 0) AS used "
                        "  FROM tickets t JOIN ticket_products p ON p.id = t.product_id, ") +
            "       fh_events e JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL "
            "                   AND COALESCE(g.status, '') <> 'cancelled' "
            "       CROSS JOIN LATERAL (SELECT COALESCE(e.kickoff_at, g.starts_at) AS ts) x "
            " WHERE t.id = $1::int AND " + kValidFor +
            "   AND (x.ts >= now() - interval '6 hours' "
            "        OR EXISTS (SELECT 1 FROM ticket_scans sc WHERE sc.ticket_id = t.id AND sc.fh_event_id = e.id)) "
            " ORDER BY x.ts", {t["id"].c_str()})) {
        json g = game(r);
        g["used"] = r["used"].as<int>();
        games.push_back(g);
    }
    out["games"] = games;
    return out;
}

json Tickets::onSale() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(
            "SELECT label, kind, price::text AS price, buy_url FROM ticket_products "
            " WHERE is_active AND is_on_sale AND buy_url IS NOT NULL ORDER BY sort_order, id")) {
        out.push_back({{"label", str(r["label"])}, {"kind", str(r["kind"])},
                       {"price", str(r["price"])}, {"buyUrl", str(r["buy_url"])}});
    }
    return out;
}

bool Tickets::isGateStaff(int personId) {
    if (personId <= 0) return false;
    return !Database::getInstance()->query(
        "SELECT 1 FROM ticket_gate_staff WHERE person_id = $1::int", {std::to_string(personId)}).empty();
}
