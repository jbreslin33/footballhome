#include "Invoice.h"

#include <cmath>
#include <iostream>
#include <sstream>
#include <iomanip>

#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string str(const pqxx::row& r, const char* col) {
    return r[col].is_null() ? std::string() : r[col].c_str();
}
double num(const pqxx::row& r, const char* col) {
    return r[col].is_null() ? 0.0 : r[col].as<double>();
}
json numOrNull(const pqxx::row& r, const char* col) {
    if (r[col].is_null()) return nullptr;
    return r[col].as<double>();
}
std::string money2(double v) {
    std::ostringstream o;
    o << std::fixed << std::setprecision(2) << v;
    return o.str();
}
double round2(double v) { return std::round(v * 100.0) / 100.0; }

std::string s(const json& j, const char* key, const std::string& dflt = "") {
    if (!j.contains(key) || j[key].is_null()) return dflt;
    if (j[key].is_string()) return j[key].get<std::string>();
    if (j[key].is_number()) { std::ostringstream o; o << j[key].get<double>(); return o.str(); }
    if (j[key].is_boolean()) return j[key].get<bool>() ? "true" : "false";
    return dflt;
}
bool hasNum(const json& j, const char* key) {
    if (!j.contains(key) || j[key].is_null()) return false;
    if (j[key].is_number()) return true;
    if (j[key].is_string()) { try { std::stod(j[key].get<std::string>()); return true; } catch (...) {} }
    return false;
}
double n(const json& j, const char* key, double dflt = 0.0) {
    if (!hasNum(j, key)) return dflt;
    return j[key].is_number() ? j[key].get<double>() : std::stod(j[key].get<std::string>());
}

}  // namespace

Invoice::Invoice() : db_(Database::getInstance()) {}

// ── read ───────────────────────────────────────────────────────────────────

json Invoice::openPlans(long long issuerId) {
    auto rows = db_->query(R"SQL(
        SELECT p.id, p.category, p.description, p.total_amount, p.installment_count, p.show_total,
               COALESCE(MAX(l.installment_no), 0) AS used
          FROM invoice_installment_plans p
          LEFT JOIN invoice_lines l ON l.plan_id = p.id
         WHERE p.issuer_id = $1::int
         GROUP BY p.id
        HAVING COALESCE(MAX(l.installment_no), 0) < p.installment_count
         ORDER BY p.created_at, p.id)SQL", {std::to_string(issuerId)});
    json out = json::array();
    for (const auto& r : rows) {
        const int count = r["installment_count"].as<int>();
        const double total = num(r, "total_amount");
        out.push_back({
            {"id", r["id"].as<long long>()},
            {"category", str(r, "category")},
            {"description", str(r, "description")},
            {"total_amount", total},
            {"installment_count", count},
            {"show_total", r["show_total"].as<bool>()},
            {"used", r["used"].as<int>()},
            {"next_no", r["used"].as<int>() + 1},
            {"per_amount", round2(total / count)},
        });
    }
    return out;
}

int Invoice::nextNumber(long long issuerId, int year) {
    auto rows = db_->query(R"SQL(
        SELECT COALESCE(MAX(invoice_number), 0) AS hi,
               COALESCE(MAX(invoice_number) FILTER (WHERE issuer_id = $1::int), 0) AS mine
          FROM invoices WHERE invoice_year = $2::int)SQL",
        {std::to_string(issuerId), std::to_string(year)});
    if (rows.empty()) return 1;
    const int hi = rows[0]["hi"].as<int>(), mine = rows[0]["mine"].as<int>();
    if (hi == 0) return 1;
    return mine >= hi ? hi + 1 : hi;
}

json Invoice::board() {
    json out;
    out["bill_to"] = nullptr;
    {
        auto rows = db_->query("SELECT organization, contact_name, address, city_state_zip, email, email_label, email_to_name FROM invoice_bill_to WHERE is_default ORDER BY id LIMIT 1");
        if (!rows.empty()) {
            const auto& r = rows[0];
            out["bill_to"] = {{"organization", str(r, "organization")}, {"contact_name", str(r, "contact_name")},
                              {"address", str(r, "address")}, {"city_state_zip", str(r, "city_state_zip")},
                              {"email", str(r, "email")}, {"email_label", str(r, "email_label")}, {"email_to_name", str(r, "email_to_name")}};
        }
    }
    out["categories"] = json::array();
    for (const auto& r : db_->query("SELECT code, label FROM invoice_line_categories ORDER BY sort_order, code"))
        out["categories"].push_back({{"code", str(r, "code")}, {"label", str(r, "label")}});

    const int year = db_->query("SELECT EXTRACT(YEAR FROM CURRENT_DATE)::int AS y")[0]["y"].as<int>();
    out["year"] = year;

    out["issuers"] = json::array();
    auto issuers = db_->query(R"SQL(
        SELECT i.id, i.person_id, i.file_slug, i.address, i.city_state_zip, i.phone, i.payable_to,
               i.duty_description, i.hourly_rate, i.bills_expenses,
               BTRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS name
          FROM invoice_issuers i JOIN persons p ON p.id = i.person_id
         WHERE i.is_active ORDER BY i.sort_order, i.id)SQL");
    for (const auto& r : issuers) {
        const long long id = r["id"].as<long long>();
        json j = {
            {"id", id}, {"person_id", r["person_id"].as<long long>()}, {"name", str(r, "name")},
            {"file_slug", str(r, "file_slug")}, {"address", str(r, "address")},
            {"city_state_zip", str(r, "city_state_zip")}, {"phone", str(r, "phone")},
            {"payable_to", str(r, "payable_to")}, {"duty_description", str(r, "duty_description")},
            {"hourly_rate", numOrNull(r, "hourly_rate")}, {"bills_expenses", r["bills_expenses"].as<bool>()},
            {"next_number", nextNumber(id, year)},
            {"open_plans", openPlans(id)},
            {"default_shifts", defaultShifts(id)},
            {"invoices", json::array()},
        };
        auto invs = db_->query(R"SQL(
            SELECT v.id, v.invoice_year, v.invoice_number, v.invoice_date::text AS invoice_date, v.is_final,
                   v.period_start::text AS period_start, v.period_end::text AS period_end,
                   to_char(date_trunc('week', v.period_start + 6)::date,  'FMMM/FMDD') AS week1,
                   to_char(date_trunc('week', v.period_start + 13)::date, 'FMMM/FMDD') AS week2,
                   COALESCE((SELECT SUM(amount) FROM invoice_lines l WHERE l.invoice_id = v.id), 0) AS total,
                   COALESCE((SELECT SUM(quantity) FROM invoice_lines l WHERE l.invoice_id = v.id AND l.category = 'labor'), 0) AS hours
              FROM invoices v WHERE v.issuer_id = $1::int
             ORDER BY v.invoice_year DESC, v.invoice_number DESC, v.id DESC)SQL", {std::to_string(id)});
        for (const auto& v : invs) {
            j["invoices"].push_back({
                {"id", v["id"].as<long long>()}, {"year", v["invoice_year"].as<int>()},
                {"number", v["invoice_number"].as<int>()}, {"date", str(v, "invoice_date")},
                {"is_final", v["is_final"].as<bool>()}, {"total", num(v, "total")}, {"hours", num(v, "hours")},
                {"week1", str(v, "week1")}, {"week2", str(v, "week2")},
                {"period_start", str(v, "period_start")}, {"period_end", str(v, "period_end")},
            });
        }
        out["issuers"].push_back(j);
    }
    return out;
}

json Invoice::get(long long invoiceId) {
    auto rows = db_->query(R"SQL(
        SELECT v.id, v.issuer_id, v.invoice_year, v.invoice_number, v.invoice_date::text AS invoice_date,
               to_char(v.invoice_date, 'MM/DD/YYYY') AS date_us, v.is_final, v.note,
               v.period_start::text AS period_start, v.period_end::text AS period_end, v.link_url,
               (SELECT e.email FROM person_emails e WHERE e.person_id = p.id ORDER BY e.is_primary DESC, e.id LIMIT 1) AS issuer_email,
               to_char(date_trunc('week', v.period_start + 6)::date,  'FMMM/FMDD') AS week1,
               to_char(date_trunc('week', v.period_start + 13)::date, 'FMMM/FMDD') AS week2,
               COALESCE(p.last_name,'') AS last_name, COALESCE(p.first_name,'') AS first_name,
               i.file_slug, i.address, i.city_state_zip, i.phone, i.payable_to, i.duty_description, i.hourly_rate, i.bills_expenses,
               i.person_id AS issuer_person_id,
               BTRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS name
          FROM invoices v JOIN invoice_issuers i ON i.id = v.issuer_id JOIN persons p ON p.id = i.person_id
         WHERE v.id = $1::int)SQL", {std::to_string(invoiceId)});
    if (rows.empty()) return json::object();
    const auto& r = rows[0];
    json out = {
        {"id", invoiceId}, {"issuer_id", r["issuer_id"].as<long long>()},
        {"year", r["invoice_year"].as<int>()}, {"number", r["invoice_number"].as<int>()},
        {"date", str(r, "invoice_date")}, {"date_us", str(r, "date_us")},
        {"is_final", r["is_final"].as<bool>()}, {"note", str(r, "note")},
        {"period_start", str(r, "period_start")}, {"period_end", str(r, "period_end")},
        {"week1", str(r, "week1")}, {"week2", str(r, "week2")}, {"link_url", str(r, "link_url")},
        {"title", "Invoice #" + std::to_string(r["invoice_number"].as<int>()) + " " + str(r, "week1") + " & " + str(r, "week2")
                  + ", " + str(r, "last_name") + ", " + str(r, "first_name")},
        {"issuer", {
            {"name", str(r, "name")}, {"file_slug", str(r, "file_slug")}, {"address", str(r, "address")},
            {"email", str(r, "issuer_email")}, {"person_id", r["issuer_person_id"].as<long long>()},
            {"city_state_zip", str(r, "city_state_zip")}, {"phone", str(r, "phone")}, {"payable_to", str(r, "payable_to")},
            {"duty_description", str(r, "duty_description")}, {"hourly_rate", numOrNull(r, "hourly_rate")},
            {"bills_expenses", r["bills_expenses"].as<bool>()},
        }},
        {"file_name", "Invoice" + str(r, "file_slug") + "-" + std::to_string(r["invoice_year"].as<int>()) + "." + std::to_string(r["invoice_number"].as<int>()) + ".pdf"},
        {"lines", json::array()},
    };
    {
        auto bt = db_->query("SELECT organization, contact_name, address, city_state_zip, email, email_label, email_to_name FROM invoice_bill_to WHERE is_default ORDER BY id LIMIT 1");
        out["bill_to"] = bt.empty() ? json(nullptr)
            : json{{"organization", str(bt[0], "organization")}, {"contact_name", str(bt[0], "contact_name")},
                   {"address", str(bt[0], "address")}, {"city_state_zip", str(bt[0], "city_state_zip")},
                   {"email", str(bt[0], "email")}, {"email_label", str(bt[0], "email_label")}, {"email_to_name", str(bt[0], "email_to_name")}};
    }
    double total = 0;
    auto lines = db_->query(R"SQL(
        SELECT l.id, l.category, c.label AS category_label, l.description, l.quantity, l.rate, l.amount,
               l.plan_id, l.installment_no, l.sort_order,
               p.installment_count, p.total_amount AS plan_total, p.show_total
          FROM invoice_lines l
          JOIN invoice_line_categories c ON c.code = l.category
          LEFT JOIN invoice_installment_plans p ON p.id = l.plan_id
         WHERE l.invoice_id = $1::int
         ORDER BY (l.category <> 'labor'), c.sort_order, l.sort_order, l.id)SQL", {std::to_string(invoiceId)});
    for (const auto& l : lines) {
        const double amount = num(l, "amount");
        total += amount;
        std::string printed = str(l, "description");
        if (!l["plan_id"].is_null() && !l["installment_no"].is_null()) {
            printed += " " + std::to_string(l["installment_no"].as<int>()) + " of " + std::to_string(l["installment_count"].as<int>());
            if (l["show_total"].as<bool>()) printed += " $" + money2(num(l, "plan_total"));
        }
        out["lines"].push_back({
            {"id", l["id"].as<long long>()}, {"category", str(l, "category")}, {"category_label", str(l, "category_label")},
            {"description", str(l, "description")}, {"printed", printed},
            {"quantity", num(l, "quantity")}, {"rate", numOrNull(l, "rate")}, {"amount", amount},
            {"plan_id", l["plan_id"].is_null() ? json(nullptr) : json(l["plan_id"].as<long long>())},
            {"installment_no", l["installment_no"].is_null() ? json(nullptr) : json(l["installment_no"].as<int>())},
            {"installment_count", l["installment_count"].is_null() ? json(nullptr) : json(l["installment_count"].as<int>())},
            {"sort_order", l["sort_order"].as<int>()},
        });
    }
    out["total"] = round2(total);

    // Hours by day (mig 469).
    out["shifts"] = json::array();
    double shiftHours = 0;
    auto shifts = db_->query(R"SQL(
        SELECT id, work_date::text AS work_date, to_char(work_date, 'Dy FMMM/FMDD') AS day_label,
               to_char(start_at, 'HH24:MI') AS start_at, to_char(end_at, 'HH24:MI') AS end_at, note,
               (hours IS NOT NULL) AS flat,
               ROUND(COALESCE(hours, EXTRACT(EPOCH FROM (end_at - start_at)) / 3600.0), 2) AS hours
          FROM invoice_work_shifts WHERE invoice_id = $1::int
         ORDER BY work_date, start_at, id)SQL", {std::to_string(invoiceId)});
    for (const auto& sh : shifts) {
        const double h = num(sh, "hours");
        shiftHours += h;
        out["shifts"].push_back({
            {"id", sh["id"].as<long long>()}, {"date", str(sh, "work_date")}, {"day_label", str(sh, "day_label")},
            {"start", str(sh, "start_at")}, {"end", str(sh, "end_at")}, {"note", str(sh, "note")}, {"hours", h},
            {"flat", sh["flat"].as<bool>()},
        });
    }
    out["shift_hours"] = round2(shiftHours);
    return out;
}

void Invoice::syncLabor(long long invoiceId) {
    db_->query(R"SQL(
        WITH h AS (
            SELECT COUNT(*) AS n, COALESCE(SUM(COALESCE(hours, EXTRACT(EPOCH FROM (end_at - start_at)) / 3600.0)), 0) AS hours
              FROM invoice_work_shifts WHERE invoice_id = $1::int)
        UPDATE invoice_lines l
           SET quantity = ROUND(h.hours::numeric, 2),
               amount   = CASE WHEN l.rate IS NULL THEN l.amount ELSE ROUND(ROUND(h.hours::numeric, 2) * l.rate, 2) END
          FROM h
         WHERE l.invoice_id = $1::int AND l.category = 'labor' AND h.n > 0)SQL", {std::to_string(invoiceId)});
    db_->query("UPDATE invoices SET updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId)});
}

long long Invoice::upsertShift(long long invoiceId, long long shiftId, const json& f, std::string* error) {
    // Either from + till (hours follow) or a flat number of hours (times blank).
    const std::string date = s(f, "date"), note = s(f, "note");
    std::string start = s(f, "start"), end = s(f, "end"), hours;
    if (date.empty()) { *error = "date is required"; return 0; }
    const bool timed = !start.empty() && !end.empty();
    if (!timed) {
        if (!hasNum(f, "hours") || n(f, "hours") <= 0) { *error = "enter from and till, or the hours"; return 0; }
        hours = money2(n(f, "hours")); start.clear(); end.clear();
    }
    if (db_->query("SELECT 1 FROM invoices WHERE id = $1::int", {std::to_string(invoiceId)}).empty()) { *error = "no such invoice"; return 0; }
    try {
        if (shiftId > 0) {
            auto r = db_->query(
                "UPDATE invoice_work_shifts SET work_date = $3::date, start_at = NULLIF($4,'')::time, end_at = NULLIF($5,'')::time, "
                "       hours = NULLIF($7,'')::numeric, note = NULLIF($6,'') "
                "WHERE id = $1::int AND invoice_id = $2::int RETURNING id",
                {std::to_string(shiftId), std::to_string(invoiceId), date, start, end, note, hours});
            if (r.empty()) { *error = "no such day"; return 0; }
            syncLabor(invoiceId);
            return shiftId;
        }
        auto r = db_->query(
            "INSERT INTO invoice_work_shifts (invoice_id, work_date, start_at, end_at, hours, note) "
            "VALUES ($1::int, $2::date, NULLIF($3,'')::time, NULLIF($4,'')::time, NULLIF($6,'')::numeric, NULLIF($5,'')) RETURNING id",
            {std::to_string(invoiceId), date, start, end, note, hours});
        if (r.empty()) { *error = "could not add the day"; return 0; }
        syncLabor(invoiceId);
        return r[0]["id"].as<long long>();
    } catch (const std::exception& e) {
        // The CHECK (end_at > start_at) and bad date / time text land here.
        *error = "till must be after from";
        std::cerr << "[invoices shift] " << e.what() << std::endl;
        return 0;
    }
}

bool Invoice::removeShift(long long shiftId) {
    auto r = db_->query("DELETE FROM invoice_work_shifts WHERE id = $1::int RETURNING invoice_id", {std::to_string(shiftId)});
    if (r.empty()) return false;
    const long long invoiceId = r[0]["invoice_id"].as<long long>();
    // With no days left the hours line goes back to 0 rather than keeping a stale sum.
    auto left = db_->query("SELECT 1 FROM invoice_work_shifts WHERE invoice_id = $1::int LIMIT 1", {std::to_string(invoiceId)});
    if (left.empty()) {
        db_->query("UPDATE invoice_lines SET quantity = 0, amount = 0 WHERE invoice_id = $1::int AND category = 'labor'", {std::to_string(invoiceId)});
        db_->query("UPDATE invoices SET updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId)});
    } else {
        syncLabor(invoiceId);
    }
    return true;
}

long long Invoice::issuerOf(long long invoiceId) {
    auto rows = db_->query("SELECT issuer_id FROM invoices WHERE id = $1::int", {std::to_string(invoiceId)});
    return rows.empty() ? 0 : rows[0]["issuer_id"].as<long long>();
}

// ── write ──────────────────────────────────────────────────────────────────

long long Invoice::create(long long issuerId, const std::string& isoDate, std::string* error) {
    auto iss = db_->query("SELECT duty_description, hourly_rate FROM invoice_issuers WHERE id = $1::int AND is_active", {std::to_string(issuerId)});
    if (iss.empty()) { *error = "no such issuer"; return 0; }
    const std::string date = isoDate.empty() ? "CURRENT_DATE" : "$2::date";
    auto yr = db_->query("SELECT EXTRACT(YEAR FROM " + std::string(isoDate.empty() ? "CURRENT_DATE" : "$1::date") + ")::int AS y",
                         isoDate.empty() ? std::vector<std::string>{} : std::vector<std::string>{isoDate});
    const int year = yr[0]["y"].as<int>();
    const int number = nextNumber(issuerId, year);
    // Period from the year's policy (mig 472); the invoice is dated the day
    // after the period ends (a Friday) unless a date was given.  With no
    // policy row for the year the period is left blank to be set by hand.
    auto ins = db_->query(R"SQL(
        WITH p AS (SELECT fh_invoice_period_start($2::int, $3::int) AS ps, fh_invoice_period_days($2::int) AS days)
        INSERT INTO invoices (issuer_id, invoice_year, invoice_number, invoice_date, period_start, period_end)
        SELECT $1::int, $2::int, $3::int,
               COALESCE(NULLIF($4, '')::date, p.ps + p.days, CURRENT_DATE),
               p.ps, p.ps + p.days - 1
          FROM p RETURNING id)SQL",
        {std::to_string(issuerId), std::to_string(year), std::to_string(number), isoDate});
    if (ins.empty()) { *error = "could not create"; return 0; }
    const long long id = ins[0]["id"].as<long long>();

    // The hours line, blank hours at the issuer's rate.
    const std::string duty = str(iss[0], "duty_description");
    const std::string rate = iss[0]["hourly_rate"].is_null() ? "" : iss[0]["hourly_rate"].c_str();
    db_->query(
        "INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order) "
        "VALUES ($1::int, 'labor', $2, 0, NULLIF($3,'')::numeric, 0, 1)",
        {std::to_string(id), duty.empty() ? "Hours" : duty, rate});

    // The next "k of N" of every plan still running.
    int sort = 2;
    for (const auto& p : openPlans(issuerId)) {
        const int k = p["next_no"].get<int>(), count = p["installment_count"].get<int>();
        const double total = p["total_amount"].get<double>(), per = round2(total / count);
        const double amt = (k == count) ? round2(total - per * (count - 1)) : per;   // last one absorbs rounding
        db_->query(
            "INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order) "
            "VALUES ($1::int, $2, $3, 1, $4::numeric, $4::numeric, $5::int, $6::int, $7::int)",
            {std::to_string(id), p["category"].get<std::string>(), p["description"].get<std::string>(),
             money2(amt), std::to_string(p["id"].get<long long>()), std::to_string(k), std::to_string(sort++)});
    }

    // The usual week, one row per matching day of the period (mig 470).
    std::string ignored;
    applyDefaults(id, false, &ignored);
    return id;
}

bool Invoice::update(long long invoiceId, const json& f, std::string* error) {
    auto cur = db_->query("SELECT issuer_id, invoice_year, invoice_number FROM invoices WHERE id = $1::int", {std::to_string(invoiceId)});
    if (cur.empty()) { *error = "no such invoice"; return false; }
    if (f.contains("date") && f["date"].is_string() && !f["date"].get<std::string>().empty()) {
        db_->query("UPDATE invoices SET invoice_date = $2::date, invoice_year = EXTRACT(YEAR FROM $2::date)::int, updated_at = now() WHERE id = $1::int",
                   {std::to_string(invoiceId), f["date"].get<std::string>()});
    }
    if (hasNum(f, "number")) {
        const int num_ = static_cast<int>(n(f, "number"));
        if (num_ <= 0) { *error = "number must be positive"; return false; }
        auto clash = db_->query(
            "SELECT 1 FROM invoices WHERE issuer_id = $1::int AND invoice_year = (SELECT invoice_year FROM invoices WHERE id = $2::int) "
            "AND invoice_number = $3::int AND id <> $2::int",
            {cur[0]["issuer_id"].c_str(), std::to_string(invoiceId), std::to_string(num_)});
        if (!clash.empty()) { *error = "that number is already used this year"; return false; }
        db_->query(R"SQL(
            UPDATE invoices v
               SET invoice_number = $2::int,
                   period_start = COALESCE(fh_invoice_period_start(v.invoice_year, $2::int), v.period_start),
                   period_end   = COALESCE(fh_invoice_period_start(v.invoice_year, $2::int) + fh_invoice_period_days(v.invoice_year) - 1, v.period_end),
                   invoice_date = COALESCE(fh_invoice_period_start(v.invoice_year, $2::int) + fh_invoice_period_days(v.invoice_year), v.invoice_date),
                   updated_at = now()
             WHERE id = $1::int)SQL", {std::to_string(invoiceId), std::to_string(num_)});
    }
    if (f.contains("is_final") && f["is_final"].is_boolean()) {
        db_->query("UPDATE invoices SET is_final = $2::bool, updated_at = now() WHERE id = $1::int",
                   {std::to_string(invoiceId), f["is_final"].get<bool>() ? "true" : "false"});
    }
    if (f.contains("note") && f["note"].is_string()) {
        db_->query("UPDATE invoices SET note = NULLIF($2,''), updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId), f["note"].get<std::string>()});
    }
    if (f.contains("link_url") && f["link_url"].is_string()) {
        db_->query("UPDATE invoices SET link_url = NULLIF(BTRIM($2),''), updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId), f["link_url"].get<std::string>()});
    }
    if (f.contains("period_start") && f["period_start"].is_string() && !f["period_start"].get<std::string>().empty()) {
        db_->query("UPDATE invoices SET period_start = $2::date, updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId), f["period_start"].get<std::string>()});
    }
    if (f.contains("period_end") && f["period_end"].is_string() && !f["period_end"].get<std::string>().empty()) {
        db_->query("UPDATE invoices SET period_end = $2::date, updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId), f["period_end"].get<std::string>()});
    }
    return true;
}

bool Invoice::remove(long long invoiceId) {
    auto r = db_->query("DELETE FROM invoices WHERE id = $1::int RETURNING id", {std::to_string(invoiceId)});
    return !r.empty();
}

long long Invoice::upsertLine(long long invoiceId, long long lineId, const json& f, std::string* error) {
    const std::string category = s(f, "category", "other");
    if (db_->query("SELECT 1 FROM invoice_line_categories WHERE code = $1", {category}).empty()) { *error = "unknown category"; return 0; }
    const std::string description = s(f, "description");
    if (description.empty()) { *error = "description is required"; return 0; }
    const double qty = hasNum(f, "quantity") ? n(f, "quantity") : 1.0;
    const bool hasRate = hasNum(f, "rate");
    const double rate = hasRate ? n(f, "rate") : 0.0;
    const double amount = hasNum(f, "amount") ? n(f, "amount") : round2(qty * rate);
    if (lineId > 0) {
        auto r = db_->query(
            "UPDATE invoice_lines SET category = $3, description = $4, quantity = $5::numeric, rate = NULLIF($6,'')::numeric, amount = $7::numeric "
            "WHERE id = $1::int AND invoice_id = $2::int RETURNING id",
            {std::to_string(lineId), std::to_string(invoiceId), category, description, money2(qty), hasRate ? money2(rate) : "", money2(amount)});
        if (r.empty()) { *error = "no such line"; return 0; }
        db_->query("UPDATE invoices SET updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId)});
        return lineId;
    }
    auto r = db_->query(
        "INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order) "
        "VALUES ($1::int, $2, $3, $4::numeric, NULLIF($5,'')::numeric, $6::numeric, "
        "        (SELECT COALESCE(MAX(sort_order), 0) + 1 FROM invoice_lines WHERE invoice_id = $1::int)) RETURNING id",
        {std::to_string(invoiceId), category, description, money2(qty), hasRate ? money2(rate) : "", money2(amount)});
    if (r.empty()) { *error = "could not add line"; return 0; }
    db_->query("UPDATE invoices SET updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId)});
    return r[0]["id"].as<long long>();
}

bool Invoice::removeLine(long long lineId) {
    auto r = db_->query("DELETE FROM invoice_lines WHERE id = $1::int RETURNING invoice_id", {std::to_string(lineId)});
    if (r.empty()) return false;
    db_->query("UPDATE invoices SET updated_at = now() WHERE id = $1::int", {r[0]["invoice_id"].c_str()});
    return true;
}

long long Invoice::createPlan(long long issuerId, long long invoiceId, const json& f, std::string* error) {
    const std::string category = s(f, "category", "other");
    if (db_->query("SELECT 1 FROM invoice_line_categories WHERE code = $1", {category}).empty()) { *error = "unknown category"; return 0; }
    const std::string description = s(f, "description");
    if (description.empty()) { *error = "description is required"; return 0; }
    const double total = n(f, "total_amount");
    const int count = static_cast<int>(n(f, "installment_count"));
    if (total <= 0) { *error = "total must be positive"; return 0; }
    if (count <= 0) { *error = "instalments must be at least 1"; return 0; }
    const bool showTotal = f.contains("show_total") && f["show_total"].is_boolean() && f["show_total"].get<bool>();
    auto ins = db_->query(
        "INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total) "
        "VALUES ($1::int, $2, $3, $4::numeric, $5::int, $6::bool) RETURNING id",
        {std::to_string(issuerId), category, description, money2(total), std::to_string(count), showTotal ? "true" : "false"});
    if (ins.empty()) { *error = "could not create plan"; return 0; }
    const long long planId = ins[0]["id"].as<long long>();
    if (invoiceId > 0 && issuerOf(invoiceId) == issuerId) {
        const double per = round2(total / count);
        const double amt = (count == 1) ? total : per;
        db_->query(
            "INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order) "
            "VALUES ($1::int, $2, $3, 1, $4::numeric, $4::numeric, $5::int, 1, "
            "        (SELECT COALESCE(MAX(sort_order), 0) + 1 FROM invoice_lines WHERE invoice_id = $1::int))",
            {std::to_string(invoiceId), category, description, money2(amt), std::to_string(planId)});
        db_->query("UPDATE invoices SET updated_at = now() WHERE id = $1::int", {std::to_string(invoiceId)});
    }
    return planId;
}

bool Invoice::removePlan(long long planId) {
    // Lines already invoiced keep their text; only the plan (and its future
    // instalments) goes.  plan_id on those lines becomes NULL.
    auto r = db_->query("DELETE FROM invoice_installment_plans WHERE id = $1::int RETURNING id", {std::to_string(planId)});
    return !r.empty();
}

bool Invoice::updateIssuer(long long issuerId, const json& f, std::string* error) {
    auto cur = db_->query("SELECT 1 FROM invoice_issuers WHERE id = $1::int", {std::to_string(issuerId)});
    if (cur.empty()) { *error = "no such issuer"; return false; }
    static const char* textCols[] = {"address", "city_state_zip", "phone", "payable_to", "duty_description", "file_slug"};
    for (const char* col : textCols) {
        if (f.contains(col) && f[col].is_string()) {
            db_->query(std::string("UPDATE invoice_issuers SET ") + col + " = NULLIF($2,''), updated_at = now() WHERE id = $1::int",
                       {std::to_string(issuerId), f[col].get<std::string>()});
        }
    }
    if (f.contains("hourly_rate")) {
        if (hasNum(f, "hourly_rate")) {
            db_->query("UPDATE invoice_issuers SET hourly_rate = $2::numeric, updated_at = now() WHERE id = $1::int",
                       {std::to_string(issuerId), money2(n(f, "hourly_rate"))});
        } else {
            db_->query("UPDATE invoice_issuers SET hourly_rate = NULL, updated_at = now() WHERE id = $1::int", {std::to_string(issuerId)});
        }
    }
    if (f.contains("bills_expenses") && f["bills_expenses"].is_boolean()) {
        db_->query("UPDATE invoice_issuers SET bills_expenses = $2::bool, updated_at = now() WHERE id = $1::int",
                   {std::to_string(issuerId), f["bills_expenses"].get<bool>() ? "true" : "false"});
    }
    return true;
}

// ── weekly default (mig 470) ───────────────────────────────────────────────

json Invoice::defaultShifts(long long issuerId) {
    auto rows = db_->query(R"SQL(
        SELECT id, day_index, to_char(start_at, 'HH24:MI') AS start_at, to_char(end_at, 'HH24:MI') AS end_at, note,
               (hours IS NOT NULL) AS flat,
               ROUND(COALESCE(hours, EXTRACT(EPOCH FROM (end_at - start_at)) / 3600.0), 2) AS hours
          FROM invoice_default_shifts WHERE issuer_id = $1::int ORDER BY day_index, start_at NULLS LAST, id)SQL", {std::to_string(issuerId)});
    json out = json::array();
    for (const auto& r : rows) {
        out.push_back({{"id", r["id"].as<long long>()}, {"day_index", r["day_index"].as<int>()}, {"start", str(r, "start_at")},
                       {"end", str(r, "end_at")}, {"note", str(r, "note")}, {"hours", num(r, "hours")}, {"flat", r["flat"].as<bool>()}});
    }
    return out;
}

long long Invoice::upsertDefaultShift(long long issuerId, long long id, const json& f, std::string* error) {
    std::string start = s(f, "start"), end = s(f, "end"), hours;
    const std::string note = s(f, "note");
    if (!hasNum(f, "day_index")) { *error = "day_index is required"; return 0; }
    const int weekday = static_cast<int>(n(f, "day_index"));   // 0 = first Friday … 13 = closing Thursday
    if (weekday < 0 || weekday > 13) { *error = "day_index must be 0-13"; return 0; }
    const bool timed = !start.empty() && !end.empty();
    if (!timed) {
        if (!hasNum(f, "hours") || n(f, "hours") <= 0) { *error = "enter from and till, or the hours"; return 0; }
        hours = money2(n(f, "hours")); start.clear(); end.clear();
    }
    try {
        if (id > 0) {
            auto r = db_->query(
                "UPDATE invoice_default_shifts SET day_index = $3::int, start_at = NULLIF($4,'')::time, end_at = NULLIF($5,'')::time, "
                "       hours = NULLIF($7,'')::numeric, note = NULLIF($6,'') "
                "WHERE id = $1::int AND issuer_id = $2::int RETURNING id",
                {std::to_string(id), std::to_string(issuerId), std::to_string(weekday), start, end, note, hours});
            if (r.empty()) { *error = "no such default"; return 0; }
            return id;
        }
        auto r = db_->query(
            "INSERT INTO invoice_default_shifts (issuer_id, day_index, start_at, end_at, hours, note) "
            "VALUES ($1::int, $2::int, NULLIF($3,'')::time, NULLIF($4,'')::time, NULLIF($6,'')::numeric, NULLIF($5,'')) RETURNING id",
            {std::to_string(issuerId), std::to_string(weekday), start, end, note, hours});
        if (r.empty()) { *error = "could not add"; return 0; }
        return r[0]["id"].as<long long>();
    } catch (const std::exception& e) {
        *error = "till must be after from";
        std::cerr << "[invoices default] " << e.what() << std::endl;
        return 0;
    }
}

bool Invoice::removeDefaultShift(long long id) {
    auto r = db_->query("DELETE FROM invoice_default_shifts WHERE id = $1::int RETURNING id", {std::to_string(id)});
    return !r.empty();
}

int Invoice::applyDefaults(long long invoiceId, bool force, std::string* error) {
    auto inv = db_->query("SELECT issuer_id, period_start, period_end FROM invoices WHERE id = $1::int", {std::to_string(invoiceId)});
    if (inv.empty()) { *error = "no such invoice"; return 0; }
    if (inv[0]["period_start"].is_null() || inv[0]["period_end"].is_null()) { *error = "set the period first"; return 0; }
    if (!force) {
        auto have = db_->query("SELECT 1 FROM invoice_work_shifts WHERE invoice_id = $1::int LIMIT 1", {std::to_string(invoiceId)});
        if (!have.empty()) { *error = "this invoice already has days"; return 0; }
    }
    auto r = db_->query(R"SQL(
        INSERT INTO invoice_work_shifts (invoice_id, work_date, start_at, end_at, hours, note)
        SELECT $1::int, ($2::date + s.day_index)::date, s.start_at, s.end_at, s.hours, s.note
          FROM invoice_default_shifts s
         WHERE s.issuer_id = $4::int AND ($2::date + s.day_index) <= $3::date
         ORDER BY s.day_index, s.start_at NULLS LAST
        RETURNING id)SQL",
        {std::to_string(invoiceId), inv[0]["period_start"].c_str(), inv[0]["period_end"].c_str(), inv[0]["issuer_id"].c_str()});
    const int added = static_cast<int>(r.size());
    if (added > 0) syncLabor(invoiceId);
    return added;
}
