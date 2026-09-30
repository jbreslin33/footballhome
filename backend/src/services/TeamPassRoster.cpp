#include "TeamPassRoster.h"

#include <curl/curl.h>

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <iostream>
#include <utility>
#include <vector>

namespace {

constexpr const char* kAppBase      = "https://app.teampass.com";
constexpr const char* kLoginPath    = "/reg/login/";
constexpr const char* kUserField    = "form_Login_UserName";
constexpr const char* kPassField    = "form_Login_Password";
constexpr const char* kSubmitField  = "Update_Account";
constexpr const char* kPdfMarker    = "Printable_Roster_pdf.cfm";
constexpr const char* kDefaultProxy = "http://footballhome_scraper:3128";
constexpr const char* kUserAgent    = "footballhome-cpp/1.0 (official roster print)";
constexpr long kConnectTimeoutSec   = 10;
constexpr long kTotalTimeoutSec     = 45;    // the PDF is built on request, headshots and all

size_t writeBody(void* contents, size_t size, size_t nmemb, void* userp) {
    static_cast<std::string*>(userp)->append(static_cast<char*>(contents), size * nmemb);
    return size * nmemb;
}

std::string lower(std::string s) { std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) { return std::tolower(c); }); return s; }

std::string envOr(const std::string& name, const std::string& fallback = {}) {
    const char* v = std::getenv(name.c_str());
    return v && *v ? std::string(v) : fallback;
}

std::string urlEncode(const std::string& in) {
    static const char* hx = "0123456789ABCDEF";
    std::string out;
    for (unsigned char c : in) {
        if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') out.push_back(static_cast<char>(c));
        else { out.push_back('%'); out.push_back(hx[c >> 4]); out.push_back(hx[c & 15]); }
    }
    return out;
}

// The handful of entities an href or a hidden value carries.
std::string htmlDecode(std::string s) {
    static const std::pair<const char*, const char*> ents[] = {{"&amp;", "&"}, {"&quot;", "\""}, {"&#39;", "'"}, {"&lt;", "<"}, {"&gt;", ">"}};
    for (const auto& [from, to] : ents) {
        const std::string f(from);
        for (size_t at = s.find(f); at != std::string::npos; at = s.find(f, at + 1)) s.replace(at, f.size(), to);
    }
    return s;
}

// name="value" | name='value' | name=value inside one tag.
std::string attr(const std::string& tag, const std::string& name) {
    const std::string lt = lower(tag), key = lower(name) + "=";
    for (size_t at = lt.find(key); at != std::string::npos; at = lt.find(key, at + 1)) {
        if (at > 0 && !std::isspace(static_cast<unsigned char>(lt[at - 1]))) continue;   // data-name= is not name=
        size_t v = at + key.size();
        if (v >= tag.size()) return {};
        if (tag[v] == '"' || tag[v] == '\'') {
            const size_t end = tag.find(tag[v], v + 1);
            return end == std::string::npos ? std::string{} : htmlDecode(tag.substr(v + 1, end - v - 1));
        }
        size_t end = v;
        while (end < tag.size() && !std::isspace(static_cast<unsigned char>(tag[end])) && tag[end] != '>') end++;
        return htmlDecode(tag.substr(v, end - v));
    }
    return {};
}

std::string absolute(const std::string& url) {
    if (url.rfind("//", 0) == 0) return "https:" + url;
    if (url.rfind("/", 0) == 0) return std::string(kAppBase) + url;
    return url;
}

// https://<anything>.teampass.com/… — the session cookies go nowhere else.
bool onTeamPass(const std::string& url) {
    const std::string scheme = "https://";
    if (url.rfind(scheme, 0) != 0) return false;
    const size_t end = url.find_first_of("/?#", scheme.size());
    const std::string host = lower(url.substr(scheme.size(), end == std::string::npos ? std::string::npos : end - scheme.size()));
    const std::string dom = "teampass.com";
    return host == dom || (host.size() > dom.size() && host.compare(host.size() - dom.size() - 1, std::string::npos, "." + dom) == 0);
}

// The sign-in form: where it posts and the fields it carries besides the
// two the person types.
struct LoginForm { std::string action; std::vector<std::pair<std::string, std::string>> fields; };

bool parseLoginForm(const std::string& html, LoginForm* out) {
    const std::string lh = lower(html);
    const size_t user = lh.find(lower(kUserField));
    if (user == std::string::npos) return false;
    const size_t open = lh.rfind("<form", user);
    if (open == std::string::npos) return false;
    const size_t openEnd = html.find('>', open);
    size_t close = lh.find("</form", user);
    if (openEnd == std::string::npos) return false;
    if (close == std::string::npos) close = html.size();
    out->action = absolute(attr(html.substr(open, openEnd - open + 1), "action"));
    for (size_t at = lh.find("<input", openEnd); at != std::string::npos && at < close; at = lh.find("<input", at + 1)) {
        const size_t end = html.find('>', at);
        if (end == std::string::npos) break;
        const std::string tag = html.substr(at, end - at + 1);
        if (lower(attr(tag, "type")) != "hidden") continue;
        const std::string name = attr(tag, "name");
        if (!name.empty()) out->fields.emplace_back(name, attr(tag, "value"));
    }
    return !out->action.empty();
}

// The "Printable Roster" link on the staff view of the team page.
std::string printableRosterUrl(const std::string& html) {
    const size_t at = html.find(kPdfMarker);
    if (at == std::string::npos) return {};
    const size_t q = html.find_last_of("\"'", at);
    if (q == std::string::npos) return {};
    const size_t end = html.find(html[q], at);
    if (end == std::string::npos) return {};
    return absolute(htmlDecode(html.substr(q + 1, end - q - 1)));
}

// One signed-in visit: a single easy handle, so the cookies TeamPass sets
// at sign-in ride along on the team page and the PDF.
class Session {
public:
    struct Reply { long status = 0; std::string body, error; bool ok() const { return error.empty() && status >= 200 && status < 300; } };

    Session() : curl_(curl_easy_init()) {
        if (!curl_) return;
        curl_easy_setopt(curl_, CURLOPT_COOKIEFILE, "");            // cookie engine on, nothing on disk
        curl_easy_setopt(curl_, CURLOPT_USERAGENT, kUserAgent);
        curl_easy_setopt(curl_, CURLOPT_ACCEPT_ENCODING, "");
        curl_easy_setopt(curl_, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl_, CURLOPT_MAXREDIRS, 5L);
        curl_easy_setopt(curl_, CURLOPT_PROTOCOLS_STR, "https");
        curl_easy_setopt(curl_, CURLOPT_REDIR_PROTOCOLS_STR, "https");
        curl_easy_setopt(curl_, CURLOPT_CONNECTTIMEOUT, kConnectTimeoutSec);
        curl_easy_setopt(curl_, CURLOPT_TIMEOUT, kTotalTimeoutSec);
        curl_easy_setopt(curl_, CURLOPT_NOSIGNAL, 1L);
        curl_easy_setopt(curl_, CURLOPT_WRITEFUNCTION, writeBody);
        const std::string proxy = envOr("TEAMPASS_PROXY_URL", kDefaultProxy);
        if (proxy != "direct") curl_easy_setopt(curl_, CURLOPT_PROXY, proxy.c_str());
    }
    ~Session() { if (curl_) curl_easy_cleanup(curl_); }
    Session(const Session&) = delete;
    Session& operator=(const Session&) = delete;

    Reply get(const std::string& url, const std::string& referer = {}) { return perform(url, nullptr, referer); }
    Reply postForm(const std::string& url, const std::string& body, const std::string& referer) { return perform(url, &body, referer); }

private:
    Reply perform(const std::string& url, const std::string* form, const std::string& referer) {
        Reply r;
        if (!curl_) { r.error = "curl_easy_init failed"; return r; }
        if (!onTeamPass(url)) { r.error = "not a TeamPass address"; return r; }
        curl_easy_setopt(curl_, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl_, CURLOPT_WRITEDATA, &r.body);
        curl_easy_setopt(curl_, CURLOPT_REFERER, referer.empty() ? nullptr : referer.c_str());
        if (form) {
            curl_easy_setopt(curl_, CURLOPT_POST, 1L);
            curl_easy_setopt(curl_, CURLOPT_POSTFIELDSIZE, static_cast<long>(form->size()));
            curl_easy_setopt(curl_, CURLOPT_POSTFIELDS, form->data());
        } else {
            curl_easy_setopt(curl_, CURLOPT_HTTPGET, 1L);
        }
        const CURLcode rc = curl_easy_perform(curl_);
        if (rc != CURLE_OK) r.error = curl_easy_strerror(rc);
        else curl_easy_getinfo(curl_, CURLINFO_RESPONSE_CODE, &r.status);
        return r;
    }

    CURL* curl_;
};

std::string why(const Session::Reply& r) {
    return r.error.empty() ? "HTTP " + std::to_string(r.status) : r.error;
}

} // namespace

TeamPassRoster::Result TeamPassRoster::fetch(const std::string& siteSlug, const std::string& externalTeamId, const std::string& credentialsKey) {
    Result out;
    const std::string email = envOr(credentialsKey + "_EMAIL"), password = envOr(credentialsKey + "_PASSWORD");
    if (email.empty() || password.empty()) {
        out.error = "the league site login is not set on the server (" + credentialsKey + "_EMAIL / " + credentialsKey + "_PASSWORD)";
        return out;
    }

    Session web;
    const std::string loginUrl = std::string(kAppBase) + kLoginPath;
    const std::string teamUrl  = std::string(kAppBase) + "/" + urlEncode(siteSlug) + "/Team/" + urlEncode(externalTeamId);

    auto page = web.get(loginUrl);
    if (!page.ok()) { out.error = "the league site did not answer (" + why(page) + ")"; return out; }
    LoginForm form;
    if (!parseLoginForm(page.body, &form)) { out.error = "the league site's sign-in page has changed"; return out; }

    std::string body;
    for (const auto& [name, value] : form.fields) body += urlEncode(name) + "=" + urlEncode(value) + "&";
    body += std::string(kUserField) + "=" + urlEncode(email) + "&" + kPassField + "=" + urlEncode(password) + "&" + kSubmitField + "=";
    auto signedIn = web.postForm(form.action, body, loginUrl);
    if (!signedIn.ok()) { out.error = "sign-in to the league site failed (" + why(signedIn) + ")"; return out; }

    auto team = web.get(teamUrl, loginUrl);
    if (!team.ok()) { out.error = "the team page did not load (" + why(team) + ")"; return out; }
    const std::string pdfUrl = printableRosterUrl(team.body);
    if (pdfUrl.empty()) {
        out.error = "the league site refused the sign-in, or that login is not staff on this team";
        return out;
    }

    auto pdf = web.get(pdfUrl, teamUrl);
    if (!pdf.ok()) { out.error = "the roster did not download (" + why(pdf) + ")"; return out; }
    if (pdf.body.rfind("%PDF", 0) != 0) { out.error = "the league site sent something that is not a roster PDF"; return out; }

    out.pdf = std::move(pdf.body);
    out.ok = true;
    std::cerr << "[TeamPassRoster] " << siteSlug << " team " << externalTeamId << ": " << out.pdf.size() << " bytes" << std::endl;
    return out;
}
