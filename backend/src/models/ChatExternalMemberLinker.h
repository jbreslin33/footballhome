#pragma once
#include <optional>
#include <string>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// ChatExternalMemberLinker — write model for /api/chat-external-members/link.
//
// Lightweight counterpart to PersonMerge: when a GroupMe chat member never
// had a `person_id` of their own (cem.person_id IS NULL) the operator can
// drag-link them on the Lineups screen.  This sets cem.person_id =
// <existing person> and the upstream join (lineups, roster lookups) starts
// pulling that person's name + DOB.
//
// Provider id 1 is GroupMe — the lone provider currently using the
// chat_external_members table; matches the Node implementation that
// hard-codes provider_id = 1.
// ────────────────────────────────────────────────────────────────────────────
class ChatExternalMemberLinker {
public:
    struct Row {
        int         chatId;
        std::string externalUserId;
        int         personId;
    };

    ChatExternalMemberLinker();

    // Returns std::nullopt when no row matched (caller should respond 404).
    std::optional<Row> link(int chatId,
                             const std::string& externalUserId,
                             int personId);

private:
    Database* db_;
};
