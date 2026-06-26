#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class ChatExternalMemberLinker;

// ────────────────────────────────────────────────────────────────────────────
// ChatExternalMemberController — POST /api/chat-external-members/link.
//
// Body: {chatId: int, externalUserId: string, personId: int}
// Returns: {linked: {chat_id, external_user_id, person_id}}
//          400 on bad body, 404 when no row matched, 500 on DB error.
//
// Used by the drag-link gesture on the Lineups screen.  Pairs with
// PersonMerge for the heavier "this chat member already had a row, fold
// them together" case.
// ────────────────────────────────────────────────────────────────────────────
class ChatExternalMemberController : public Controller {
public:
    ChatExternalMemberController();
    ~ChatExternalMemberController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<ChatExternalMemberLinker> model_;

    Response handleLink(const Request& request);

    static bool requireBearer(const Request& request);
};
