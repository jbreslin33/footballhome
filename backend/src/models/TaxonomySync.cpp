#include "TaxonomySync.h"

#include "../database/Database.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <regex>
#include <set>
#include <sstream>
#include <string>
#include <vector>

#include <sys/stat.h>

namespace fs = std::filesystem;

namespace {

// Relative to ENGINE_SRC, as game_engine_behaviours.file names them.
const char* const kDirs[] = {"game/src/ai", "game/src/ai/concepts", "game/src/core", "game/src/server",
                             "game/src/teach", "shared/tactics"};

struct Klass { std::string name, file, parent, doc, kind; int from = 0, to = 0; };
struct Func { int line = 0; std::string owner, method; };

std::vector<std::string> split(const std::string& body) {
    std::vector<std::string> lines;
    std::stringstream ss(body);
    for (std::string l; std::getline(ss, l);) lines.push_back(l);
    return lines;
}

std::string trim(const std::string& s) {
    const auto a = s.find_first_not_of(" \t\r"), b = s.find_last_not_of(" \t\r");
    return a == std::string::npos ? "" : s.substr(a, b - a + 1);
}

// A line without string / char literals and // comments, for brace counting.
std::string codeOnly(const std::string& line) {
    static const std::regex str(R"("(?:\\.|[^"\\])*")"), chr(R"('(?:\\.|[^'\\])')");
    std::string s = std::regex_replace(std::regex_replace(line, str, "\"\""), chr, "''");
    const auto c = s.find("//");
    return c == std::string::npos ? s : s.substr(0, c);
}

// 1-based last line of the brace block that opens on line `start` (1-based).
int blockEnd(const std::vector<std::string>& lines, int start) {
    int depth = 0;
    bool seen = false;
    for (std::size_t i = start - 1; i < lines.size(); ++i)
        for (const char ch : codeOnly(lines[i])) {
            if (ch == '{') { ++depth; seen = true; }
            else if (ch == '}') { --depth; if (seen && depth == 0) return static_cast<int>(i) + 1; }
        }
    return static_cast<int>(lines.size());
}

std::string docAbove(const std::vector<std::string>& lines, int start) {
    std::vector<std::string> out;
    for (int i = start - 2; i >= 0 && trim(lines[i]).rfind("//", 0) == 0; --i) out.push_back(trim(trim(lines[i]).substr(2)));
    std::string doc;
    for (auto it = out.rbegin(); it != out.rend(); ++it) doc += (doc.empty() ? "" : "\n") + *it;
    return doc;
}

std::uint64_t fnv(std::uint64_t h, const std::string& s) {
    for (const unsigned char c : s) { h ^= c; h *= 1099511628211ull; }
    return h;
}

}  // namespace

bool TaxonomySync::run() {
    const char* env = std::getenv("ENGINE_SRC");
    const fs::path root = env && *env ? env : "/engine";
    std::error_code ec;
    if (!fs::is_directory(root / "game/src/ai", ec)) return false;
    auto* db = Database::getInstance();

    // ── read the source ──
    std::map<std::string, std::string> files;   // rel path → body
    std::uint64_t hash = 1469598103934665603ull;
    double newest = 0;
    for (const char* d : kDirs) {
        if (!fs::is_directory(root / d, ec)) continue;
        std::vector<fs::path> names;
        for (const auto& e : fs::directory_iterator(root / d, ec)) {
            const std::string ext = e.path().extension().string();
            if (e.is_regular_file() && (ext == ".hpp" || ext == ".cpp")) names.push_back(e.path());
        }
        std::sort(names.begin(), names.end());
        for (const auto& p : names) {
            std::ifstream in(p, std::ios::binary);
            const std::string body((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
            const std::string rel = std::string(d) + "/" + p.filename().string();
            files[rel] = body;
            hash = fnv(fnv(hash, rel), body);
            if (std::string(d).rfind("game/", 0) == 0) {
                struct stat st{};
                if (::stat(p.c_str(), &st) == 0) newest = std::max(newest, static_cast<double>(st.st_mtime));
            }
        }
    }
    std::set<std::string> listed;
    {
        std::ifstream in(root / "game/src/ai/behaviours.list");
        const std::string body((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
        hash = fnv(hash, body);
        for (const auto& raw : split(body)) {
            const std::string l = trim(raw);
            if (l.empty() || l[0] == '#') continue;
            std::stringstream ss(l);
            std::string code, flag;
            ss >> code >> flag;
            if (flag != "pending") listed.insert(code);
        }
    }

    // ── tags: `// [behaviour: code]` → the first line of code after it ──
    static const std::regex tagRe(R"(//\s*\[behaviour:\s*([a-z0-9_]+)\])");
    std::map<std::string, std::pair<std::string, int>> tags;
    for (const auto& [rel, body] : files) {
        const auto lines = split(body);
        for (std::size_t n = 0; n < lines.size(); ++n) {
            std::smatch m;
            if (!std::regex_search(lines[n], m, tagRe) || tags.count(m[1])) continue;
            std::size_t k = n + 1;
            while (k < lines.size() && (trim(lines[k]).rfind("//", 0) == 0 || trim(lines[k]).empty())) ++k;
            tags[m[1]] = {rel, static_cast<int>(k) + 1};
        }
    }

    std::set<std::string> rows;
    for (const auto& r : db->query("SELECT code FROM game_engine_behaviours")) rows.insert(r[0].as<std::string>());
    const auto was = db->query("SELECT COALESCE(source_hash, '') FROM taxonomy_sync WHERE id = 1");
    const std::string hashText = std::to_string(hash);
    const bool changed = was.empty() || was[0][0].as<std::string>() != hashText;

    // ── refresh the page's copy of the code, only when it changed ──
    if (changed) {
        static const std::regex classRe(R"(^\s*(class|struct)\s+(\w+)(?:\s+final)?\s*(?::\s*(?:public|protected|private)?\s*([\w:]+)(?:<[^>{]*>)?)?\s*\{)");
        static const std::regex funcRe(R"(^[\w:<>,&\*\s~]*?\b(\w+)::(~?\w+)\s*\([^;]*$)");
        static const std::regex aliasRe(R"(^\s*using\s+(\w+)\s*=\s*(\w+)\s*<)");
        std::vector<Klass> classes;
        std::map<std::string, std::vector<Func>> funcs;
        std::map<std::string, std::string> alias;
        for (const auto& [rel, body] : files) {
            const auto lines = split(body);
            for (std::size_t i = 0; i < lines.size(); ++i) {
                const std::string& line = lines[i];
                std::smatch m;
                if (std::regex_search(line, m, aliasRe)) alias[m[1]] = m[2];
                if (std::regex_search(line, m, classRe) && (trim(line).empty() || trim(line).back() != ';')) {
                    std::string parent = m[3].matched ? m[3].str() : "";
                    if (const auto c = parent.rfind("::"); c != std::string::npos) parent = parent.substr(c + 2);
                    const int n = static_cast<int>(i) + 1;
                    classes.push_back({m[2], rel, parent, docAbove(lines, n), m[1], n, blockEnd(lines, n)});
                    continue;
                }
                if (!line.empty() && line[0] != ' ' && line[0] != '\t' && line[0] != '/' && line[0] != '#' && line[0] != '}' &&
                    std::regex_search(line, m, funcRe))
                    funcs[rel].push_back({static_cast<int>(i) + 1, m[1], m[2]});
            }
        }
        std::set<std::string> known;
        for (auto& c : classes) {
            if (const auto a = alias.find(c.parent); a != alias.end()) c.parent = a->second;
            known.insert(c.name);
        }
        db->query("DELETE FROM game_engine_classes");
        db->query("DELETE FROM game_engine_sources");
        for (const auto& [rel, body] : files)
            db->query("INSERT INTO game_engine_sources (file, commit, line_count, body) VALUES ($1, '', $2::int, $3)",
                      {rel, std::to_string(split(body).size()), body});
        std::set<std::pair<std::string, std::string>> seen;
        for (const auto& c : classes) {
            if (!seen.insert({c.name, c.file}).second) continue;
            db->query("INSERT INTO game_engine_classes (name, file, line_start, line_end, parent, doc, kind) "
                      "VALUES ($1, $2, $3::int, $4::int, NULLIF($5, ''), NULLIF($6, ''), $7)",
                      {c.name, c.file, std::to_string(c.from), std::to_string(c.to), known.count(c.parent) ? c.parent : "", c.doc, c.kind});
        }
        // Each behaviour sits where its tag is: the innermost class round it, else the Class::method above.
        for (const auto& [code, at] : tags) {
            const auto& [rel, line] = at;
            std::string symbol, cname;
            const Klass* inner = nullptr;
            for (const auto& c : classes)
                if (c.file == rel && c.from <= line && line <= c.to && (!inner || c.to - c.from < inner->to - inner->from)) inner = &c;
            if (inner) {
                symbol = cname = inner->name;
            } else {
                const Func* above = nullptr;
                for (const auto& f : funcs[rel]) if (f.line <= line) above = &f;
                if (above) { symbol = above->owner + "::" + above->method; if (known.count(above->owner)) cname = above->owner; }
            }
            db->query("UPDATE game_engine_behaviours SET file = $2, line = $3::int, symbol = NULLIF($4, ''), class_name = NULLIF($5, '') WHERE code = $1",
                      {code, rel, std::to_string(line), symbol, cname});
        }
    }

    // ── the verdict, with its time ──
    std::set<std::string> tagged;
    for (const auto& [code, _] : tags) tagged.insert(code);
    const auto minus = [](const std::set<std::string>& a, const std::set<std::string>& b) {
        std::vector<std::string> out;
        std::set_difference(a.begin(), a.end(), b.begin(), b.end(), std::back_inserter(out));
        return out;
    };
    const nlohmann::json diff = {
        {"tag_not_listed", minus(tagged, listed)},      // in the code, not in behaviours.list
        {"listed_not_tagged", minus(listed, tagged)},   // in the list, tagged nowhere
        {"code_not_db", minus(listed, rows)},           // in the engine, no database row
        {"db_not_code", minus(rows, listed)},           // a database row for nothing in the engine
    };
    bool inSync = true;
    for (const auto& [_, v] : diff.items()) inSync = inSync && v.empty();
    db->query(std::string("UPDATE taxonomy_sync SET checked_at = now(), ") + (changed ? "changed_at = now(), " : "") +
              "source_hash = $1, in_sync = $2::boolean, tagged = $3::int, listed = $4::int, db_rows = $5::int, diff = $6::jsonb, "
              "source_newest_at = to_timestamp($7::float8) WHERE id = 1",
              {hashText, inSync ? "true" : "false", std::to_string(tagged.size()), std::to_string(listed.size()),
               std::to_string(rows.size()), diff.dump(), std::to_string(newest)});
    return true;
}
