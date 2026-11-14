#pragma once
#include <memory>
#include <string>
#include <vector>

#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// NoticeBoard — the notices strip atop Event Center: things about the viewer
// and their kids that need doing, whatever event they open (docs/event-
// center-design.md, slice 3).  Owner 2026-11-14: "do we need my section now?
// lets think of proper build with oop concepts on front and back end".
//
// Each kind is a Notice subclass; adding a kind = one class + one line in
// NoticeBoard::collect, and one renderer on the page (lib/notices.js).
// Words stay in message_templates (the page renders them by kind).
// ────────────────────────────────────────────────────────────────────────────
class Notice {
public:
    virtual ~Notice() = default;
    virtual std::string kind() const = 0;
    // {kind, ...} — what the page needs to draw it.
    virtual nlohmann::json toJson() const = 0;
};

// Dues standing of one person (the viewer or a child) — migrations 416 / 513
// / 614.  Also the feed's `dues` map (CalendarController), so the two never
// drift.
struct DuesStanding {
    long long personId = 0;
    bool isSelf = false;
    std::string firstName;
    double balance = 0.0;
    nlohmann::json line = nullptr;     // number | null
    bool eligible = true;
    double minPayment = 0.0;
    bool blocks = false;      // mig 513: the line blocks this person (Men)
    bool overLine = false;    // mig 513: at/over the line
    bool alternate = false;   // mig 614: any balance + the alternate policy (Men)
    std::string payUrl;

    nlohmann::json toJson() const;
    // The viewer and every child they are a guardian of.
    static std::vector<DuesStanding> forPersonAndKids(Database* db, long long personId);
    // Needs a banner: blocked, over the line, or a dues alternate.
    bool needsNotice() const { return !eligible || overLine || alternate; }
};

// 💰 / ⚠️ / ⛔ dues banner for one person.  Words: message_templates my_dues.
class DuesNotice : public Notice {
public:
    explicit DuesNotice(DuesStanding s) : s_(std::move(s)) {}
    std::string kind() const override { return "dues"; }
    nlohmann::json toJson() const override;
private:
    DuesStanding s_;
};

// 🙋 Overdue → volunteer one evening a week instead (mig 1222).  Present
// while there is an offer or a live pick; the page mounts VolunteerShiftCard,
// which reads /api/my/volunteer itself.
class VolunteerShiftNotice : public Notice {
public:
    explicit VolunteerShiftNotice(nlohmann::json mine) : mine_(std::move(mine)) {}
    std::string kind() const override { return "volunteer_shift"; }
    nlohmann::json toJson() const override;
private:
    nlohmann::json mine_;
};

class NoticeBoard {
public:
    // personId = the EFFECTIVE person (after view-as).
    static std::vector<std::unique_ptr<Notice>> collect(Database* db, long long personId);
    static nlohmann::json toJson(const std::vector<std::unique_ptr<Notice>>& notices);
};
