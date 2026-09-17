#include "MessageCopy.h"

#include "../core/Crypto.h"
#include "../database/Database.h"

using nlohmann::json;

namespace {

void replaceAll(std::string& s, const std::string& from, const std::string& to) {
    if (from.empty()) return;
    for (size_t pos = 0; (pos = s.find(from, pos)) != std::string::npos; pos += to.size())
        s.replace(pos, from.size(), to);
}

const std::string* valueOf(const MessageCopy::Tokens& tokens, const std::string& name) {
    for (const auto& t : tokens) if (t.first == name) return &t.second;
    return nullptr;
}

// A dropped optional section or empty block leaves blank lines behind.
std::string tidy(std::string s) {
    for (size_t pos; (pos = s.find("\n\n\n")) != std::string::npos; ) s.erase(pos, 1);
    while (!s.empty() && (s.back() == '\n' || s.back() == ' ')) s.pop_back();
    size_t lead = 0;
    while (lead < s.size() && s[lead] == '\n') ++lead;
    return s.substr(lead);
}

}  // namespace

MessageCopy::MessageCopy(int clubId)
    : db_(Database::getInstance()), clubId_(clubId) {}

std::string MessageCopy::fallbackFor(const std::string& token) {
    auto rows = db_->query(
        "SELECT body FROM message_templates WHERE kind = 'fallback' AND tier = $1 AND is_active "
        " ORDER BY sort_order, id LIMIT 1", {token});
    return rows.empty() ? std::string{} : std::string(rows[0]["body"].c_str());
}

std::string MessageCopy::fill(std::string text, const Tokens& tokens) {
    // 1. Optional sections: keep the inside only when every known token
    //    in it has a value.
    for (size_t open; (open = text.find("[[")) != std::string::npos; ) {
        const size_t close = text.find("]]", open);
        if (close == std::string::npos) break;
        std::string inner = text.substr(open + 2, close - open - 2);
        bool keep = true;
        for (const auto& t : tokens) {
            if (inner.find("{" + t.first + "}") != std::string::npos && t.second.empty()) { keep = false; break; }
        }
        if (keep) for (const auto& t : tokens) replaceAll(inner, "{" + t.first + "}", t.second);
        text.replace(open, close - open + 2, keep ? inner : std::string{});
    }
    // 2. Everything else, with the DB's fallback word for an empty value.
    for (const auto& t : tokens) {
        const std::string needle = "{" + t.first + "}";
        if (text.find(needle) == std::string::npos) continue;
        replaceAll(text, needle, t.second.empty() ? fallbackFor(t.first) : t.second);
    }
    // 3. Form links.
    if (text.find("{form:") != std::string::npos) {
        auto rows = db_->query("SELECT fh_fill_form_links($1::text, $2::int) AS txt",
                               {text, std::to_string(clubId_)});
        if (!rows.empty() && !rows[0]["txt"].is_null()) text = rows[0]["txt"].c_str();
    }
    return tidy(std::move(text));
}

MessageCopy::Rendered MessageCopy::render(const std::string& kind, const std::string& tier,
                                          const Tokens& tokens) {
    auto rows = db_->query(
        "SELECT COALESCE(subject,'') AS subject, body FROM message_templates "
        " WHERE kind = $1 AND tier = $2 AND is_active ORDER BY sort_order, id LIMIT 1",
        {kind, tier});
    if (rows.empty()) return {};
    return {fill(rows[0]["subject"].c_str(), tokens), fill(rows[0]["body"].c_str(), tokens)};
}

std::string MessageCopy::withSmsLinkHint(const std::string& smsBody) {
    const auto hint = render("sms_link_hint", "all", {});
    return hint.ok() ? smsBody + "\n\n" + hint.body : smsBody;
}

std::string MessageCopy::outreachEmail() {
    auto rows = db_->query("SELECT COALESCE(outreach_email,'') AS em FROM clubs WHERE id = $1::int",
                           {std::to_string(clubId_)});
    return rows.empty() ? std::string{} : std::string(rows[0]["em"].c_str());
}

void MessageCopy::addComposeHrefs(json& out, const std::string& channel, const std::string& contact,
                                  const std::string& subject, const std::string& emailBody,
                                  const std::string& smsBody) {
    using fh::crypto::urlEncode;
    if (channel == "email") {
        out["mailto_href"] = "mailto:" + urlEncode(contact)
                           + "?subject=" + urlEncode(subject)
                           + "&body="    + urlEncode(emailBody);
        out["gmail_href"]  = std::string("https://mail.google.com/mail/?view=cm&fs=1")
                           + "&authuser=" + urlEncode(outreachEmail())
                           + "&to="       + urlEncode(contact)
                           + "&su="       + urlEncode(subject)
                           + "&body="     + urlEncode(emailBody);
    } else if (channel == "sms") {
        out["sms_href"] = "sms:" + urlEncode(contact) + "?body=" + urlEncode(withSmsLinkHint(smsBody));
    }
}
