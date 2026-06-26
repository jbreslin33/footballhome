#include "ChatExternalMemberLinker.h"

#include "../database/Database.h"

ChatExternalMemberLinker::ChatExternalMemberLinker()
    : db_(Database::getInstance()) {}

std::optional<ChatExternalMemberLinker::Row>
ChatExternalMemberLinker::link(int chatId,
                                const std::string& externalUserId,
                                int personId) {
    auto rows = db_->query(
        "UPDATE chat_external_members "
        "   SET person_id = $1 "
        " WHERE chat_id = $2 "
        "   AND provider_id = 1 "
        "   AND external_user_id = $3 "
        " RETURNING chat_id, external_user_id, person_id",
        {std::to_string(personId), std::to_string(chatId), externalUserId});

    if (rows.empty()) return std::nullopt;

    Row r;
    r.chatId         = rows[0]["chat_id"].as<int>();
    r.externalUserId = rows[0]["external_user_id"].as<std::string>();
    r.personId       = rows[0]["person_id"].as<int>();
    return r;
}
