#pragma once
#include <string>
#include <utility>
#include <vector>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// FacilityLockup — the nightly "was the gate locked?" check-in
// (migration 421, owner 2026-09-24).  One row per facility per night,
// keyed on the night's last event there.  This class owns every SQL
// touch; LockupScheduler decides when to send, LockupController serves
// #lockups and the one-tap confirm link.
// ────────────────────────────────────────────────────────────────────────────
class FacilityLockup {
public:
    struct Lockup {
        long long   id = 0;
        int         facilityId = 0;
        std::string facility, shortName, timezone;
        std::string localDate, dateLabel;              // "2026-09-24", "Wed Sep 24"
        long long   lastEventId = 0;
        std::string lastEvent;                         // "Practice · Mens Liga 1 7:00–8:30 PM"
        std::string startsLabel, endsLabel, deadlineLabel, confirmedLabel;
        std::string dueAtIso, deadlineAtIso, promptedAtIso, confirmedAtIso, lastAlertAtIso, announcedAtIso;
        std::string confirmedBy, confirmedVia, note;
        // maxAlerts = sum of the facility's alert steps; repeatMinutes = the
        // wait after the NEXT alert (alert_count + 1); cadence = the steps in
        // words ("every 10 min for the first 6 calls, then every hour (30 more)").
        // All three come from facility_lockup_alert_steps via fh_lockup_* (mig 426).
        int         alertCount = 0, maxAlerts = 0, repeatMinutes = 0;
        std::string cadence;
        bool        isDue = false, isOverdue = false;
        bool hasEvent()  const { return lastEventId > 0; }
        bool confirmed() const { return !confirmedAtIso.empty(); }
        // none | pending | due | overdue | locked
        std::string status() const;
    };

    struct Recipient {
        long long   personId = 0;
        std::string firstName, email, phone;
        bool wantEmail = false, wantSms = false, wantCall = false;
    };

    using Tokens = std::vector<std::pair<std::string, std::string>>;
    enum class TapOutcome { Confirmed, Already, Invalid };

    FacilityLockup();

    // Upserts tonight's row for every facility that requires a lock-up
    // (recomputed each tick until the first alert goes out, so a late
    // gcal change still moves the deadline).  Drops an untouched row whose
    // events all got cancelled.
    void syncToday();

    std::vector<Lockup> pendingPrompts();        // due, closers not yet asked
    std::vector<Lockup> pendingAlerts();         // past deadline, cadence + cap honoured
    std::vector<Lockup> pendingAnnouncements();  // confirmed after alerts had started
    std::vector<Lockup> todays();                // one per active facility (may lack an event)
    std::vector<Lockup> history(int days);       // earlier nights, newest first
    bool get(long long id, Lockup* out);

    // role 'closer' also brings the coaches of the last event's teams
    // (facilities.lockup_prompt_last_event_coaches).  Channels merged per person.
    std::vector<Recipient> recipients(long long lockupId, const std::string& role);

    struct TokenInfo {
        bool        found = false, live = false, used = false;
        long long   id = 0, lockupId = 0, personId = 0;
        std::string firstName;
    };
    std::string issueToken(long long lockupId, long long personId);   // raw token for the upload link
    TokenInfo   lookupToken(const std::string& raw);
    void        markTokenUsed(long long tokenId);
    bool        confirm(long long lockupId, long long personId, const std::string& via, const std::string& note);
    // The photo IS the confirmation (mig 424): records the file and marks
    // the night locked (via 'photo') if it was not already.
    long long   addPhoto(long long lockupId, long long personId, const std::string& urlPath,
                         const std::string& mime, long long byteSize);

    void markPrompted(long long id);
    void bumpAlert(long long id);
    void markAnnounced(long long id);
    void logAlert(long long lockupId, const std::string& stage, const std::string& channel,
                  long long personId, const std::string& contact, bool ok,
                  const std::string& providerSid, const std::string& error);

    // Club admins, anyone listed for a facility, and active coaches.
    bool canView(long long personId, bool isAdmin);
    bool isAdminUser(long long userId);
    long long personForUser(long long userId);

    nlohmann::json toJson(const Lockup& l);
    nlohmann::json alertsJson(long long lockupId);
    nlohmann::json photosJson(long long lockupId);
    nlohmann::json peopleJson();
    Tokens tokens(const Lockup& l, const std::string& name, const std::string& link, int alertN);

private:
    std::vector<Lockup> select(const std::string& where, const std::vector<std::string>& params,
                               const std::string& order = "");
    Database* db_;
};
