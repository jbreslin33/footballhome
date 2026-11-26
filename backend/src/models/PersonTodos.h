#pragma once
#include <string>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// PersonTodos — ✅ the person's to-do list on every screen (mig 1570), and
// since mig 1903 the list staff give a player from the player sheet.
//
// Owner 2026-11-19: "i need a todo all my screens lol. so its like a reminer
// every time i oepn app lol".  An item with remind_at shows from then on
// (NULL = now); while any is due the 🚦 band carries a red "✅ To do" box.
// Done items stay 7 days so a ✓ can be undone.
//
// Owner 2026-11-25: "we need indivdual todo lists for all players … for our
// hight school kids did you apply for financial aid. college applications.
// for some it might reminders to stretch every day."  Club admins and the
// player's coaches give items (assigned_by_person_id) — one player, or
// everyone on a team they manage (one batch_id).  repeat 'daily' comes back
// every club day; due_on is an optional deadline.  The player ticks a given
// item but only staff remove it.
// ────────────────────────────────────────────────────────────────────────────
class PersonTodos {
public:
    // The person's own view (the band):
    //   {todos:[{id, body, remind_at, due, done_at, repeat, due_on, from,
    //            mine, photo_proof, call_at "HH:MM", guide_id,
    //            photo_id, photo_at (today's latest photo)}], due: n}
    //   open items first (due, then by remind_at), then done newest-first.
    //   A daily item's done_at is today's tick only (else null and due).
    static nlohmann::json list(long long personId);

    // remindAtIso "" = now.  "" = ok, else the error.
    static std::string add(long long personId, const std::string& body, const std::string& remindAtIso);

    // done = true ticks it, false brings it back.  false = not theirs / gone.
    static bool setDone(long long personId, long long id, bool done);

    // Their own reminders only — a given item is staff's to take back.
    static bool remove(long long personId, long long id);

    // ── Staff (the player sheet's ✅ To do tab) ──────────────────────────
    // A club admin, or a coach of a team the person is on.
    static bool canGive(long long viewerUserId, long long personId);

    //   { personId, canGive, viewerIsAdmin,
    //     teams: [{teamId, label, n}]   the person's teams the viewer
    //                                   manages, n = players on it
    //     todos: [{id, body, repeat, due_on, remind_at, from, mine,
    //              done_at, done_today, created_at, batch_id, batch_n}] }
    //   Given items first (open, then done), then their own reminders.
    static nlohmann::json sheet(long long personId, long long viewerUserId);

    // Give `body` to personId, or (teamId > 0) to every player on that
    // team.  repeat "" | "daily"; dueOn "" | YYYY-MM-DD.  Returns how many
    // got it; err set on a bad input.
    static int give(long long viewerUserId, long long personId, long long teamId,
                    const std::string& body, const std::string& repeat,
                    const std::string& dueOn, std::string& err);

    // Take a given item back from personId — or, all = true, from everyone
    // in its batch.  false = no such given item on this person.
    static bool take(long long personId, long long id, bool all);

    // ── 📷 Photo proof, 📞 the daily call, 📖 the guide (mig 1944) ────────
    // Owner 2026-11-26 (Luke's daily stretching): "call if he has not
    // uploaded photo of him starting streting routine uploaded 1pm every
    // day. on the page give him full complement of stretehcss".
    // A photo_proof item is ticked by its photo: addPhoto stores today's
    // (club day) photo from a data URL (JPEG / PNG / WebP / HEIC, ≤ 10 MB)
    // and sets done_at.  "" = ok, else the error.
    static std::string addPhoto(long long personId, long long id, const std::string& dataUrl);

    // A photo's bytes for the person it belongs to, or staff who may give
    // them to-dos (canGive).  false = not found / not theirs to see.
    struct Photo { std::string mime, bytes; };
    static bool photo(long long viewerPersonId, long long photoId, Photo& out);

    // The routine on an item: {id, slug, title, intro, sections:[{title,
    // note, items:[{name, how, dose}]}]}; null when there is no such guide.
    static nlohmann::json guide(long long guideId);
};
