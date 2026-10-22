#pragma once
#include <memory>
#include <string>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// Organization — anything with a footballhome.org/<slug> page (migration
// 632).  Owner 2026-10-22: one site, paths not subdomains; clubs and
// leagues are organizations, subclassed by KIND (Club, later League) —
// never by a particular club.  What differs between two clubs is data
// (rows), not classes.
//
// publicPage() is what GET /api/orgs/<slug> serves to signed-out
// visitors, so a subclass adds public facts only — never people.
// ────────────────────────────────────────────────────────────────────────────
class Organization {
public:
    virtual ~Organization() = default;

    int id() const { return id_; }
    const std::string& slug() const { return slug_; }
    const std::string& name() const { return name_; }

    virtual const char* kind() const = 0;

    // slug / name / kind + the page's headings (message_templates
    // kind='org_page') and buttons (organization_page_links).
    virtual nlohmann::json publicPage() const;

protected:
    Organization(Database* db, int id, std::string slug, std::string name);

    Database* db_;

private:
    nlohmann::json pageCopy() const;
    nlohmann::json pageLinks() const;

    int id_;
    std::string slug_;
    std::string name_;
};

// footballhome.org/<slug> → the organization behind it.  Only clubs have
// pages so far; a League subclass arrives with the first league page.
class OrganizationRegistry {
public:
    // nullptr when no organization owns the slug (or it has no page kind).
    static std::unique_ptr<Organization> fromSlug(const std::string& slug);
};
