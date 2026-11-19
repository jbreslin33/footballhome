#pragma once
#include <string>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// PersonTodos — ✅ the person's own to-do list on every screen (mig 1570).
//
// Owner 2026-11-19: "i need a todo all my screens lol. so its like a reminer
// every time i oepn app lol".  An item with remind_at shows from then on
// (NULL = now); while any is due the 🚦 band carries a red "✅ To do" box.
// Done items stay 7 days so a ✓ can be undone.
//
//   {todos:[{id, body, remind_at, due, done_at}], due: n}
//   open items first (due, then by remind_at), then done newest-first.
// ────────────────────────────────────────────────────────────────────────────
class PersonTodos {
public:
    static nlohmann::json list(long long personId);

    // remindAtIso "" = now.  "" = ok, else the error.
    static std::string add(long long personId, const std::string& body, const std::string& remindAtIso);

    // done = true ticks it, false brings it back.  false = not theirs / gone.
    static bool setDone(long long personId, long long id, bool done);

    static bool remove(long long personId, long long id);
};
