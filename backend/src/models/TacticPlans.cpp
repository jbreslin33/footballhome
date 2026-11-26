#include "TacticPlans.h"
#include "TaxonomySync.h"

#include <iostream>

#include "../database/Database.h"

#include <tactics/TacticGeometry.hpp>   // shared/ — the same rules the game engine plays

#include <stdexcept>

using nlohmann::json;

namespace {

// A slot's number is formation_slot_roles.number — what the game engine
// reads — else positions_json's position_id (the shirt number in every
// formation since mig 611; the old seed rows carry role ids there, which
// repeat).  One row per number.
constexpr const char* kSlotsSql =
    "SELECT DISTINCT ON (num) num AS pid, x, y FROM ("
    "  SELECT COALESCE(r.number, (p->>'position_id')::int) AS num, (p->>'slot')::int AS slot, "
    "         (p->>'x')::float8 AS x, (p->>'y')::float8 AS y "
    "    FROM formations f CROSS JOIN LATERAL jsonb_array_elements(f.positions_json) p "
    "    LEFT JOIN formation_slot_roles r ON r.formation_code = f.code AND r.slot = (p->>'slot')::int "
    "   WHERE f.id = $1::int) s "
    " WHERE num BETWEEN 1 AND 11 ORDER BY num, slot";

// A formation's slots as {position_id, x, y} (club scheme, y up from our goal).
json formationSpots(Database* db, long long formationId) {
    json out = json::array();
    for (const auto& r : db->query(kSlotsSql, {std::to_string(formationId)}))
        out.push_back({{"position_id", r["pid"].as<int>()}, {"x", r["x"].as<double>()}, {"y", r["y"].as<double>()}});
    return out;
}

// Theirs attack down the pitch: mirror both axes (their right = our left).
json mirrored(const json& spots) {
    json out = json::array();
    for (const auto& s : spots)
        out.push_back({{"number", s["position_id"]}, {"x", 100.0 - s["x"].get<double>()}, {"y", 100.0 - s["y"].get<double>()}});
    return out;
}

// ── Shared geometry (shared/tactics/TacticGeometry.hpp) ────────────────
// The backend's only job here is filling the library's plain structs from
// the plan's rows; the rules themselves are the library's.
namespace tg = fh::tactics;

std::optional<double> optNum(const pqxx::field& f) {
    if (f.is_null()) return std::nullopt;
    return f.as<double>();
}

// Kinds, our formation spots and the block's keeper depth.
tg::PlanFrame planFrame(Database* db, long long formationId, const std::string& block) {
    tg::PlanFrame f;
    for (const auto& r : db->query(
             "SELECT code, rule, dist_m::float8 AS dist_m, press_m::float8 AS press_m, lane_t::float8 AS lane_t FROM tactic_job_kinds"))
        f.kinds[r["code"].as<std::string>()] = {r["code"].as<std::string>(), r["rule"].as<std::string>(),
                                                r["dist_m"].as<double>(), optNum(r["press_m"]), optNum(r["lane_t"])};
    for (const auto& r : db->query(kSlotsSql, {std::to_string(formationId)}))
        f.home[r["pid"].as<int>()] = {r["x"].as<double>(), r["y"].as<double>()};
    auto gk = db->query("SELECT gk_y::float8 AS gk_y, back_y::float8 AS back_y, front_y::float8 AS front_y "
                        "FROM tactic_block_heights WHERE code = $1", {block});
    if (!gk.empty()) {
        f.gkY = gk[0]["gk_y"].as<double>();
        f.backY = optNum(gk[0]["back_y"]);    // the block's depth band (mig 1185)
        f.frontY = optNum(gk[0]["front_y"]);
    }
    return f;
}

std::map<std::string, tg::RestartLaw> restartLaws(Database* db) {
    std::map<std::string, tg::RestartLaw> out;
    for (const auto& r : db->query(
             "SELECT code, our_max_y::float8 AS our_max_y, zone_min_x::float8 AS zone_min_x, "
             "       zone_max_x::float8 AS zone_max_x, zone_min_y::float8 AS zone_min_y FROM tactic_restarts"))
        out[r["code"].as<std::string>()] = {optNum(r["our_max_y"]), optNum(r["zone_min_x"]), optNum(r["zone_max_x"]), optNum(r["zone_min_y"])};
    return out;
}

// A state as the API carries it: { ball_with, restart, opponents: [{number,x,y}],
// jobs: [{position_id,kind,targets,target_b,partner_position_id,stance}] }.
tg::State stateFromJson(const json& st, const std::map<std::string, tg::RestartLaw>& laws) {
    tg::State s;
    s.ballWith = st.value("ball_with", 1);
    if (st.contains("restart") && st["restart"].is_string()) {
        const auto it = laws.find(st["restart"].get<std::string>());
        if (it != laws.end()) s.law = it->second;
    }
    for (const auto& o : st.value("opponents", json::array()))
        s.opponents.push_back({o.at("number").get<int>(), {o.at("x").get<double>(), o.at("y").get<double>()}});
    for (const auto& j : st.value("jobs", json::array())) {
        tg::Job job;
        job.position = j.at("position_id").get<int>();
        job.kind = j.at("kind").get<std::string>();
        for (const auto& t : j.value("targets", json::array())) job.targets.push_back(t.get<int>());
        if (j.contains("target_b") && j["target_b"].is_number_integer()) job.targetB = j["target_b"].get<int>();
        if (j.contains("partner_position_id") && j["partner_position_id"].is_number_integer()) job.partner = j["partner_position_id"].get<int>();
        if (j.contains("stance") && j["stance"].is_string()) job.stance = j["stance"].get<std::string>();
        s.jobs.push_back(std::move(job));
    }
    return s;
}

// { ball: {x,y}, players: [{position_id,x,y}], free: [n], doubled: [n] }
json solutionJson(const tg::Solution& sol) {
    json out = {{"ball", {{"x", sol.ball.x}, {"y", sol.ball.y}}}, {"players", json::array()},
                {"free", sol.freeMen}, {"doubled", sol.doubledMen}};
    for (const auto& p : sol.players)
        out["players"].push_back({{"position_id", p.position}, {"x", p.at.x}, {"y", p.at.y}});
    return out;
}

}  // namespace

json TacticPlans::lookups() {
    auto* db = Database::getInstance();
    json out = {{"moments", json::array()}, {"blocks", json::array()}, {"kinds", json::array()}, {"stances", json::array()}};
    out["restarts"] = json::array();
    // Law zones (mig 1145, game session): the box opponents are kept out of.
    const auto num = [](const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.as<double>()); };
    for (const auto& r : db->query(
             "SELECT code, label, law, our_max_y::float8 AS our_max_y, zone, zone_min_x::float8 AS zone_min_x, "
             "       zone_max_x::float8 AS zone_max_x, zone_min_y::float8 AS zone_min_y FROM tactic_restarts ORDER BY code"))
        out["restarts"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()},
                                   {"law", r["law"].as<std::string>()}, {"our_max_y", num(r["our_max_y"])},
                                   {"zone", r["zone"].is_null() ? json(nullptr) : json(r["zone"].as<std::string>())},
                                   {"zone_min_x", num(r["zone_min_x"])}, {"zone_max_x", num(r["zone_max_x"])},
                                   {"zone_min_y", num(r["zone_min_y"])}});
    out["shortcuts"] = shortcuts();
    for (const auto& r : db->query("SELECT code, label FROM tactic_job_stances ORDER BY sort_order"))
        out["stances"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()}});
    for (const auto& r : db->query("SELECT code, title FROM game_moments ORDER BY sort_order"))
        out["moments"].push_back({{"code", r["code"].as<std::string>()}, {"title", r["title"].as<std::string>()}});
    for (const auto& r : db->query("SELECT code, label, gk_y::float8 AS gk_y FROM tactic_block_heights ORDER BY sort_order"))
        out["blocks"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()},
                                 {"gk_y", r["gk_y"].as<double>()}});
    for (const auto& r : db->query(
             "SELECT k.code, k.concept_id, c.name AS concept, c.title AS concept_title, c.cue_answer, c.family, c.moment, k.rule, "
             "       k.label, k.target_a_label, k.target_b_label, k.partner_label, "
             "       k.dist_m::float8 AS dist_m, k.press_m::float8 AS press_m, k.multi_a, k.lane_t::float8 AS lane_t "
             "  FROM tactic_job_kinds k JOIN game_concepts c ON c.id = k.concept_id ORDER BY k.sort_order")) {
        out["kinds"].push_back({{"code", r["code"].as<std::string>()},
                                {"concept_id", r["concept_id"].as<int>()},
                                {"concept", r["concept"].as<std::string>()},
                                {"concept_title", r["concept_title"].as<std::string>()},
                                {"cue", r["cue_answer"].as<std::string>()},
                                {"label", r["label"].as<std::string>()},
                                {"target_a_label", r["target_a_label"].is_null() ? json(nullptr) : json(r["target_a_label"].as<std::string>())},
                                {"rule", r["rule"].as<std::string>()},
                                {"family", r["family"].as<std::string>()},
                                {"moment", r["moment"].as<std::string>()},
                                {"target_b_label", r["target_b_label"].is_null() ? json(nullptr) : json(r["target_b_label"].as<std::string>())},
                                {"partner_label", r["partner_label"].is_null() ? json(nullptr) : json(r["partner_label"].as<std::string>())},
                                {"dist_m", r["dist_m"].as<double>()},
                                {"press_m", r["press_m"].is_null() ? json(nullptr) : json(r["press_m"].as<double>())},
                                {"multi_a", r["multi_a"].as<bool>()},
                                {"lane_t", r["lane_t"].is_null() ? json(nullptr) : json(r["lane_t"].as<double>())}});
    }
    return out;
}

json TacticPlans::list() {
    auto* db = Database::getInstance();
    json out = json::array();
    for (const auto& r : db->query(
             "SELECT p.id, f.code AS us, o.code AS them, p.block_height, b.label AS block_label, "
             "       (SELECT count(*) FROM tactic_states s WHERE s.plan_id = p.id AND s.copied_from IS NULL) AS steps "
             "  FROM tactic_plans p JOIN formations f ON f.id = p.formation_id "
             "  JOIN formations o ON o.id = p.opponent_formation_id "
             "  JOIN tactic_block_heights b ON b.code = p.block_height "
             " ORDER BY f.code, o.code, b.sort_order, p.id"))
        out.push_back({{"id", r["id"].as<long long>()}, {"us", r["us"].as<std::string>()}, {"them", r["them"].as<std::string>()},
                       {"block", r["block_height"].as<std::string>()}, {"block_label", r["block_label"].as<std::string>()},
                       {"steps", r["steps"].as<int>()}});
    return out;
}

json TacticPlans::taxonomy() {
    // Every load checks the engine's C++ against the database first (and refreshes the page's
    // copy of the code if it changed): what comes back is current, with the time of the check.
    try { TaxonomySync::run(); } catch (const std::exception& e) { std::cerr << "TaxonomySync: " << e.what() << std::endl; }
    auto* db = Database::getInstance();
    const auto r = db->query(R"SQL(
        SELECT json_build_object(
          'moments',    (SELECT json_agg(json_build_object('code', code, 'title', title) ORDER BY sort_order) FROM game_moments),
          'principles', (SELECT json_agg(json_build_object('id', id, 'moment', moment, 'parent_id', parent_id, 'title', title,
                                                           'description', description) ORDER BY sort_order, id) FROM game_principles),
          'concepts',   (SELECT json_agg(json_build_object(
                             'id', c.id, 'name', c.name, 'title', c.title, 'family', c.family, 'moment', c.moment,
                             'cue', c.cue_answer, 'definition', c.definition, 'principle_id', c.principle_id,
                             'status', c.status, 'lacking', c.lacking, 'taught_from', c.taught_from,
                             'job',  (SELECT k.code FROM tactic_job_kinds k WHERE k.concept_id = c.id ORDER BY k.sort_order LIMIT 1),
                             'rule', (SELECT k.rule FROM tactic_job_kinds k WHERE k.concept_id = c.id ORDER BY (k.rule = 'home'), k.sort_order LIMIT 1),
                             'act',  (SELECT a.code FROM game_engine_acts a WHERE a.concept_id = c.id ORDER BY a.code LIMIT 1),
                             'act_note', (SELECT a.note FROM game_engine_acts a WHERE a.concept_id = c.id ORDER BY a.code LIMIT 1),
                             'sources', (SELECT count(*) FROM game_concept_sources s WHERE s.concept_id = c.id))
                           ORDER BY c.title) FROM game_concepts c),
          'rules',      (SELECT json_agg(json_build_object('code', code, 'label', label) ORDER BY sort_order) FROM tactic_job_rules),
          'techniques', (SELECT json_agg(json_build_object('id', id, 'parent_id', parent_id, 'node', node, 'title', title, 'how', how)
                                         ORDER BY sort_order, id) FROM game_techniques),
          'roles',      (SELECT json_agg(json_build_object('code', code, 'title', title)) FROM game_roles),
          'measures',   (SELECT json_agg(json_build_object('code', code, 'title', title)) FROM game_measures),
          'laws',       (SELECT json_agg(json_build_object('number', number, 'title', title, 'summary', summary) ORDER BY number) FROM game_ref_laws),
          'engine',     (SELECT json_agg(json_build_object('kind', kind, 'code', code, 'title', title, 'note', note, 'definition', definition, 'wire', wire_index, 'parent', parent) ORDER BY kind, sort_order)
                           FROM game_engine_terms),
          'links',      (SELECT json_agg(json_build_object('from', concept_id, 'to', other_id, 'kind', kind)) FROM game_concept_links),
          'jobs',       (SELECT json_agg(json_build_object('code', code, 'concept_id', concept_id, 'label', label, 'rule', rule,
                                                           'dist_m', dist_m, 'press_m', press_m, 'lane_t', lane_t) ORDER BY sort_order) FROM tactic_job_kinds),
          'behaviours', (SELECT json_agg(json_build_object('code', code, 'file', file, 'line', line, 'symbol', symbol, 'class', class_name,
                                                           'tag', tag, 'who', who, 'what', what, 'status', status, 'concept_id', concept_id,
                                                           'other', other_concepts, 'suggested', suggested, 'confidence', confidence,
                                                           'read', is_read, 'in_sim', in_sim) ORDER BY file, line) FROM game_engine_behaviours),
          'classes',    (SELECT json_agg(json_build_object('name', name, 'file', file, 'from', line_start, 'to', line_end, 'parent', parent,
                                                           'doc', doc, 'kind', kind) ORDER BY name) FROM game_engine_classes),
          -- 📜 Principles of play (migs 1929–1935): the common ground with its popularity, every source's own
          -- words linked to it, the sources with their school, and the federation register.
          'play_principles', (SELECT json_agg(json_build_object('id', p.id, 'code', p.code, 'title', p.title, 'aka', p.aka,
                                 'definition', p.definition, 'is_not', p.is_not, 'level', p.level, 'side', p.side, 'parent_id', p.parent_id,
                                 'sources', pop.sources, 'overlaps', pop.overlap_sources, 'schools', pop.schools,
                                 'verdict', p.owner_verdict, 'note', p.owner_note, 'decided_by', pop.decided_by,
                                 'model_principles', ch.model_principles, 'concepts', ch.concepts, 'engine', ch.engine_behaviours, 'in_sim', ch.in_sim)
                                 ORDER BY pop.sources DESC, pop.schools DESC, p.sort_order)
                               FROM game_play_principles p JOIN game_principle_popularity pop ON pop.id = p.id
                               JOIN game_taxonomy_chain ch ON ch.id = p.id),
          'principle_entries', (SELECT json_agg(json_build_object('id', t.id, 'source_id', t.source_id, 'term', t.term, 'lang', t.lang,
                                 'level', t.level, 'side', t.side, 'verified', t.verified, 'principle_id', l.principle_id, 'relation', l.relation)
                                 ORDER BY t.source_id, t.id)
                               FROM game_source_principles t LEFT JOIN game_common_principle_links l ON l.term_id = t.id),
          'sources',    (SELECT json_agg(json_build_object('id', s.id, 'code', s.code, 'kind', s.kind, 'title', s.title, 'url', s.url,
                                 'verified', s.verified, 'school', (SELECT string_agg(sc.school, ', ') FROM game_source_schools sc WHERE sc.source_id = s.id)))
                               FROM game_sources s WHERE EXISTS (SELECT 1 FROM game_source_principles t WHERE t.source_id = s.id)
                                  OR EXISTS (SELECT 1 FROM game_source_formations t WHERE t.source_id = s.id)
                                  OR EXISTS (SELECT 1 FROM game_source_styles t WHERE t.source_id = s.id)
                                  OR EXISTS (SELECT 1 FROM game_models t WHERE t.source_id = s.id)),
          'federations', (SELECT json_agg(json_build_object('name', name, 'confederation', confederation, 'status', principles_status,
                                 'source_id', source_id, 'url', url, 'note', note) ORDER BY confederation, name) FROM game_federations),
          -- 🧩 Formations (mig 1938): the named systems with popularity, every source's name for them, our board layouts.
          'formation_families', (SELECT json_agg(json_build_object('id', g.id, 'code', g.code, 'title', g.title, 'aka', g.aka, 'phase', g.phase,
                                 'back', g.back, 'parent_id', g.parent_id, 'definition', g.definition, 'sources', pop.sources, 'uses', pop.uses,
                                 'boards', pop.boards, 'sim_teams', pop.sim_teams, 'verdict', g.owner_verdict, 'decided_by', pop.decided_by)
                                 ORDER BY pop.sources DESC, pop.uses DESC, g.sort_order)
                               FROM game_formation_families g JOIN game_formation_popularity pop ON pop.id = g.id),
          'formation_entries', (SELECT json_agg(json_build_object('source_id', e.source_id, 'name', e.name, 'context', e.context, 'uses', e.uses_n,
                                 'verified', e.verified, 'family_id', l.family_id, 'relation', l.relation) ORDER BY e.uses_n DESC NULLS LAST, e.id)
                               FROM game_source_formations e JOIN game_formation_family_links l ON l.entry_id = e.id),
          'boards',     (SELECT json_agg(json_build_object('code', code, 'name', name, 'family_id', family_id) ORDER BY sort_order) FROM formations),
          -- 🎨 Playing styles (mig 1939): the axes, the named styles and their profiles, every source's words.
          'style_dimensions', (SELECT json_agg(json_build_object('id', d.id, 'code', d.code, 'moment', d.moment, 'title', d.title, 'low', d.low_label,
                                 'high', d.high_label, 'definition', d.definition, 'measure', d.measure, 'sources', dp.sources, 'named', dp.in_named_styles)
                                 ORDER BY d.sort_order) FROM game_style_dimensions d JOIN game_style_dimension_popularity dp ON dp.id = d.id),
          'styles',     (SELECT json_agg(json_build_object('id', g.id, 'code', g.code, 'title', g.title, 'aka', g.aka, 'era', g.era, 'parent_id', g.parent_id,
                                 'definition', g.definition, 'sources', pop.sources, 'overlaps', pop.overlap_sources, 'verdict', g.owner_verdict,
                                 'profile', (SELECT json_agg(json_build_object('dimension_id', pr.dimension_id, 'value', pr.value)) FROM game_style_profiles pr WHERE pr.style_id = g.id))
                                 ORDER BY pop.sources DESC, g.sort_order) FROM game_styles g JOIN game_style_popularity pop ON pop.id = g.id),
          'style_entries', (SELECT json_agg(json_build_object('source_id', e.source_id, 'name', e.name, 'context', e.context, 'verified', e.verified,
                                 'style_id', l.style_id, 'relation', l.relation, 'dimension_id', dl.dimension_id, 'value', dl.value) ORDER BY e.id)
                               FROM game_source_styles e LEFT JOIN game_style_links l ON l.entry_id = e.id LEFT JOIN game_style_dimension_links dl ON dl.entry_id = e.id),
          -- 🗺 Game models (mig 1940): whose, style, shape, the plan per moment, the principles it puts first.
          'game_models', (SELECT json_agg(json_build_object('id', gm.id, 'name', gm.name, 'kind', gm.kind, 'note', gm.note, 'era', gm.era,
                                 'source_id', gm.source_id, 'style_id', gm.style_id, 'family_id', gm.formation_family_id, 'verified', gm.verified,
                                 'moments', (SELECT json_agg(json_build_object('moment', mm.moment, 'plan', mm.plan, 'citation', mm.citation)) FROM game_model_moments mm WHERE mm.model_id = gm.id),
                                 'principles', (SELECT json_agg(json_build_object('principle_id', mp.principle_id, 'moment', mp.moment, 'emphasis', mp.emphasis, 'words', mp.own_words)) FROM game_model_principles mp WHERE mp.model_id = gm.id),
                                 'settings', (SELECT json_agg(json_build_object('dimension_id', ss.dimension_id, 'value', ss.value)) FROM game_model_style_settings ss WHERE ss.model_id = gm.id),
                                 'concepts', (SELECT count(*) FROM game_model_concepts gc WHERE gc.model_id = gm.id))
                                 ORDER BY gm.sort_order) FROM game_models gm),
          'commit',     (SELECT max(commit) FROM game_engine_sources),
          'sync',       (SELECT json_build_object('checked_at', extract(epoch FROM checked_at), 'changed_at', extract(epoch FROM changed_at),
                                                   'in_sync', in_sync, 'tagged', tagged, 'listed', listed, 'db_rows', db_rows, 'diff', diff,
                                                   'game_built_at', extract(epoch FROM game_built_at),
                                                   'game_stale', game_built_at IS NOT NULL AND source_newest_at > game_built_at + interval '1 minute',
                                                   'now', extract(epoch FROM now()))
                           FROM taxonomy_sync WHERE id = 1)
        )::text AS doc)SQL");
    if (r.empty() || r[0]["doc"].is_null()) return json::object();
    return json::parse(r[0]["doc"].as<std::string>());
}

// The owner's verdict on one common-ground principle (mig 1933): adopt | reject | "" (back to popularity).
bool TacticPlans::setPrincipleVerdict(const std::string& code, const std::string& verdict, const std::string& note) {
    auto* db = Database::getInstance();
    const auto r = db->query(
        "UPDATE game_play_principles SET owner_verdict = NULLIF($2, ''), owner_note = $3 WHERE code = $1 RETURNING id",
        {code, verdict, note});
    return !r.empty();
}

json TacticPlans::source(const std::string& file, int from, int to) {
    auto* db = Database::getInstance();
    if (from < 1) from = 1;
    if (to < from) to = from;
    if (to - from > 400) to = from + 400;   // a class or a function, not a file
    const auto r = db->query(
        "SELECT commit, line_count, array_to_string((string_to_array(body, E'\\n'))[$2::int:$3::int], E'\\n') AS text "
        "  FROM game_engine_sources WHERE file = $1",
        {file, std::to_string(from), std::to_string(to)});
    if (r.empty()) return json::object();
    return {{"file", file}, {"from", from}, {"to", std::min(to, r[0]["line_count"].as<int>())},
            {"commit", r[0]["commit"].as<std::string>()}, {"text", r[0]["text"].is_null() ? "" : r[0]["text"].as<std::string>()}};
}

namespace {
// A table as the catalogue describes it: columns in order, each with its type, whether it
// is (part of) the primary key, and the table.column a single-column foreign key points to.
json tableInfo(Database* db, const std::string& table) {
    json cols = json::array();
    for (const auto& r : db->query(R"SQL(
            SELECT a.attname AS name, format_type(a.atttypid, a.atttypmod) AS type, a.attnotnull AS notnull,
                   EXISTS (SELECT 1 FROM pg_index i WHERE i.indrelid = a.attrelid AND i.indisprimary AND a.attnum = ANY (i.indkey)) AS pk,
                   EXISTS (SELECT 1 FROM pg_index i WHERE i.indrelid = a.attrelid AND i.indisunique AND NOT i.indisprimary
                              AND i.indnkeyatts = 1 AND a.attnum = i.indkey[0]) AS uniq,
                   (SELECT c.confrelid::regclass::text || '.' || af.attname FROM pg_constraint c
                      JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = c.confkey[1]
                     WHERE c.contype = 'f' AND c.conrelid = a.attrelid AND array_length(c.conkey, 1) = 1 AND c.conkey[1] = a.attnum
                     LIMIT 1) AS ref
              FROM pg_attribute a
             WHERE a.attrelid = to_regclass($1) AND a.attnum > 0 AND NOT a.attisdropped
             ORDER BY a.attnum)SQL", {table}))
        cols.push_back({{"name", r["name"].c_str()}, {"type", r["type"].c_str()}, {"notnull", r["notnull"].as<bool>()},
                        {"pk", r["pk"].as<bool>()}, {"unique", r["uniq"].as<bool>()},
                        {"ref", r["ref"].is_null() ? json(nullptr) : json(r["ref"].c_str())}});
    return {{"name", table}, {"columns", cols}};
}
}  // namespace

json TacticPlans::conceptDb(long long conceptId) {
    auto* db = Database::getInstance();
    const std::string id = std::to_string(conceptId);
    const auto row = db->query("SELECT row_to_json(c)::text AS j FROM game_concepts c WHERE c.id = $1::int", {id});
    if (row.empty()) return json::object();
    json out = {{"table", tableInfo(db, "game_concepts")}, {"row", json::parse(row[0]["j"].c_str())},
                {"points_to", json::array()}, {"pointed_at_by", json::array()}};
    // The rows this one points to (its foreign keys out).  Table and column names come from
    // the catalogue and go through format(%I), never from the request.
    for (const auto& col : out["table"]["columns"]) {
        if (col["ref"].is_null() || out["row"][col["name"].get<std::string>()].is_null()) continue;
        const std::string ref = col["ref"].get<std::string>(), table = ref.substr(0, ref.rfind('.')), refCol = ref.substr(ref.rfind('.') + 1);
        const auto sql = db->query("SELECT format('SELECT row_to_json(t)::text AS j FROM %s t WHERE t.%I::text = $1 LIMIT 1', to_regclass($1), $2::text) AS q",
                                   {table, refCol});
        const json& v = out["row"][col["name"].get<std::string>()];
        const auto r = db->query(sql[0]["q"].c_str(), {v.is_string() ? v.get<std::string>() : v.dump()});
        out["points_to"].push_back({{"column", col["name"]}, {"table", tableInfo(db, table)}, {"ref_column", refCol},
                                    {"row", r.empty() ? json(nullptr) : json::parse(r[0]["j"].c_str())}});
    }
    // Every table that points at game_concepts (by id or by name), with its rows for this concept.
    for (const auto& fk : db->query(R"SQL(
            SELECT c.conrelid::regclass::text AS tbl, a.attname AS col, af.attname AS ref_col,
                   format('SELECT count(*) AS n, (SELECT json_agg(x) FROM (SELECT * FROM %s t WHERE t.%I::text = $1 LIMIT 40) x)::text AS j FROM %s t WHERE t.%I::text = $1',
                          c.conrelid::regclass, a.attname, c.conrelid::regclass, a.attname) AS q
              FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = c.conkey[1]
              JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = c.confkey[1]
             WHERE c.contype = 'f' AND c.confrelid = 'game_concepts'::regclass AND array_length(c.conkey, 1) = 1
             ORDER BY 1, 2)SQL")) {
        const json& v = out["row"][fk["ref_col"].c_str()];
        const auto r = db->query(fk["q"].c_str(), {v.is_string() ? v.get<std::string>() : v.dump()});
        out["pointed_at_by"].push_back({{"table", tableInfo(db, fk["tbl"].c_str())}, {"column", fk["col"].c_str()},
                                        {"count", r[0]["n"].as<long long>()},
                                        {"rows", r[0]["j"].is_null() ? json::array() : json::parse(r[0]["j"].c_str())}});
    }
    return out;
}

json TacticPlans::shortcuts() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(
             "SELECT s.kind FROM tactic_job_shortcuts s JOIN tactic_job_kinds k ON k.code = s.kind "
             " WHERE s.on_list ORDER BY k.sort_order, s.kind"))
        out.push_back(r["kind"].as<std::string>());
    return out;
}

bool TacticPlans::setShortcut(const std::string& kind, bool on, long long byUserId) {
    auto* db = Database::getInstance();
    if (db->query("SELECT 1 FROM tactic_job_kinds WHERE code = $1", {kind}).empty()) return false;
    db->query("INSERT INTO tactic_job_shortcuts (kind, on_list, changed_by_user_id, changed_at) VALUES ($1, $2::boolean, NULLIF($3, '0')::int, now()) "
              "ON CONFLICT (kind) DO UPDATE SET on_list = EXCLUDED.on_list, changed_by_user_id = EXCLUDED.changed_by_user_id, changed_at = now()",
              {kind, on ? "true" : "false", std::to_string(byUserId)});
    return true;
}

json TacticPlans::find(long long formationId, long long opponentFormationId,
                       const std::string& moment, const std::string& block) {
    auto* db = Database::getInstance();
    json out = {{"plan", nullptr}, {"states", json::array()},
                {"our_positions", formationSpots(db, formationId)},
                {"opponent_base", mirrored(formationSpots(db, opponentFormationId))}};
    auto plan = db->query(
        "SELECT id FROM tactic_plans WHERE formation_id = $1::int AND opponent_formation_id = $2::int "
        "   AND moment = $3 AND block_height = $4",
        {std::to_string(formationId), std::to_string(opponentFormationId), moment, block});
    if (plan.empty()) return out;
    const std::string planId = plan[0]["id"].as<std::string>();
    out["plan"] = {{"id", plan[0]["id"].as<long long>()}};

    const tg::PlanFrame frame = planFrame(db, formationId, block);
    const auto laws = restartLaws(db);
    const json opponentBase = out["opponent_base"];
    for (const auto& s : db->query(
             "SELECT id, parent_state_id, ball_with, restart, CASE WHEN copied_from IS NOT NULL THEN (COALESCE(copied_from->'source', '{}'::jsonb) || jsonb_build_object('ours', copied_from->'ours', 'ball', copied_from->'ball'))::text END AS copied FROM tactic_states WHERE plan_id = $1::int "
             " ORDER BY parent_state_id IS NOT NULL, id", {planId})) {
        const std::string sid = s["id"].as<std::string>();
        json st = {{"id", s["id"].as<long long>()},
                   {"parent_state_id", s["parent_state_id"].is_null() ? json(nullptr) : json(s["parent_state_id"].as<long long>())},
                   {"ball_with", s["ball_with"].as<int>()},
                   {"restart", s["restart"].is_null() ? json(nullptr) : json(s["restart"].as<std::string>())},
                   {"copied_from", s["copied"].is_null() ? json(nullptr) : json::parse(s["copied"].as<std::string>())},
                   {"opponents", json::array()}, {"jobs", json::array()}};
        for (const auto& o : db->query(
                 "SELECT number, x::float8 AS x, y::float8 AS y FROM tactic_state_opponents WHERE state_id = $1::int ORDER BY number", {sid}))
            st["opponents"].push_back({{"number", o["number"].as<int>()}, {"x", o["x"].as<double>()}, {"y", o["y"].as<double>()}});
        for (const auto& j : db->query(
                 "SELECT j.position_id, j.kind, j.target_b, j.partner_position_id, j.stance, "
                 "       COALESCE((SELECT json_agg(t.number ORDER BY t.ord, t.number) FROM tactic_job_targets t "
                 "                  WHERE t.state_id = j.state_id AND t.position_id = j.position_id)::text, '[]') AS targets "
                 "  FROM tactic_jobs j WHERE j.state_id = $1::int ORDER BY j.position_id", {sid}))
            st["jobs"].push_back({{"position_id", j["position_id"].as<int>()}, {"kind", j["kind"].as<std::string>()},
                                  {"targets", json::parse(j["targets"].as<std::string>())},
                                  {"stance", j["stance"].as<std::string>()},
                                  {"target_b", j["target_b"].is_null() ? json(nullptr) : json(j["target_b"].as<int>())},
                                  {"partner_position_id", j["partner_position_id"].is_null() ? json(nullptr) : json(j["partner_position_id"].as<int>())}});
        // A state with no stored men plays against their formation mirrored.
        json asSolved = st;
        if (asSolved["opponents"].empty()) asSolved["opponents"] = opponentBase;
        st["solved"] = solutionJson(tg::Solver().solve(stateFromJson(asSolved, laws), frame));
        out["states"].push_back(std::move(st));
    }
    return out;
}

json TacticPlans::solve(long long formationId, const std::string& block, const json& state) {
    auto* db = Database::getInstance();
    return solutionJson(tg::Solver().solve(stateFromJson(state, restartLaws(db)), planFrame(db, formationId, block)));
}

long long TacticPlans::create(long long formationId, long long opponentFormationId,
                              const std::string& moment, const std::string& block, long long byUserId) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto ok = tx->exec_params(
            "SELECT EXISTS (SELECT 1 FROM formations WHERE id = $1::int) "
            "   AND EXISTS (SELECT 1 FROM formations WHERE id = $2::int) "
            "   AND EXISTS (SELECT 1 FROM game_moments WHERE code = $3::text) "
            "   AND EXISTS (SELECT 1 FROM tactic_block_heights WHERE code = $4::text) AS ok",
            formationId, opponentFormationId, moment, block);
        if (!ok[0]["ok"].as<bool>()) { db->rollback(tx); return 0; }
        auto ins = tx->exec_params(
            "INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height, created_by_user_id) "
            "VALUES ($1, $2, $3, $4, $5) ON CONFLICT (formation_id, opponent_formation_id, moment, block_height) DO NOTHING RETURNING id",
            formationId, opponentFormationId, moment, block, byUserId);
        if (ins.empty()) {
            auto ex = tx->exec_params(
                "SELECT id FROM tactic_plans WHERE formation_id = $1 AND opponent_formation_id = $2 AND moment = $3 AND block_height = $4",
                formationId, opponentFormationId, moment, block);
            db->commit(tx);
            return ex[0]["id"].as<long long>();
        }
        const long long planId = ins[0]["id"].as<long long>();
        // Out of possession the root is their keeper placing the ball: a goal
        // kick (Law 16, tactic_restarts — mig 1142).
        auto st = tx->exec_params(
            "INSERT INTO tactic_states (plan_id, ball_with, restart) "
            "VALUES ($1, 1, CASE WHEN $2::text = 'out_of_possession' THEN 'goal_kick' END) RETURNING id", planId, moment);
        const long long rootId = st[0]["id"].as<long long>();
        // Out of possession, their GK on the ball = their build-out from a
        // goal kick (tactic_buildout_shapes, mig 1129: CBs split inside the
        // box, full-backs high and wide).  Otherwise, or with no shape for
        // that formation, their formation mirrored: their right on our left.
        auto shaped = moment == "out_of_possession"
            ? tx->exec_params(
                  "INSERT INTO tactic_state_opponents (state_id, number, x, y) "
                  "SELECT $1, number, x, y FROM tactic_buildout_shapes WHERE formation_id = $2 RETURNING number",
                  rootId, opponentFormationId)
            : pqxx::result{};
        if (shaped.empty())
            tx->exec_params(
                std::string("INSERT INTO tactic_state_opponents (state_id, number, x, y) "
                            "SELECT $2::int, pid, 100 - x, 100 - y FROM (") + kSlotsSql + ") q "
                "ON CONFLICT DO NOTHING",
                opponentFormationId, rootId);
        db->commit(tx);
        return planId;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

long long TacticPlans::addState(long long parentStateId, int ballWith) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto parent = tx->exec_params("SELECT plan_id FROM tactic_states WHERE id = $1", parentStateId);
        if (parent.empty()) { db->rollback(tx); return 0; }
        const long long planId = parent[0]["plan_id"].as<long long>();
        auto ins = tx->exec_params(
            "INSERT INTO tactic_states (plan_id, parent_state_id, ball_with) VALUES ($1, $2, $3) "
            "ON CONFLICT (plan_id, parent_state_id, ball_with) WHERE copied_from IS NULL DO NOTHING RETURNING id",
            planId, parentStateId, ballWith);
        long long id;
        if (ins.empty()) {
            id = tx->exec_params("SELECT id FROM tactic_states WHERE plan_id = $1 AND parent_state_id = $2 AND ball_with = $3 AND copied_from IS NULL",
                                 planId, parentStateId, ballWith)[0]["id"].as<long long>();
        } else {
            id = ins[0]["id"].as<long long>();
            tx->exec_params("INSERT INTO tactic_state_opponents (state_id, number, x, y) "
                            "SELECT $1, number, x, y FROM tactic_state_opponents WHERE state_id = $2", id, parentStateId);
            tx->exec_params("INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance) "
                            "SELECT $1, position_id, kind, target_b, partner_position_id, stance FROM tactic_jobs WHERE state_id = $2", id, parentStateId);
            tx->exec_params("INSERT INTO tactic_job_targets (state_id, position_id, number, ord) "
                            "SELECT $1, position_id, number, ord FROM tactic_job_targets WHERE state_id = $2", id, parentStateId);
            tx->exec_params("UPDATE tactic_plans SET updated_at = now() WHERE id = $1", planId);
        }
        db->commit(tx);
        return id;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

bool TacticPlans::putState(long long stateId, const json& body) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto st = tx->exec_params("SELECT plan_id FROM tactic_states WHERE id = $1", stateId);
        if (st.empty()) { db->rollback(tx); return false; }
        tx->exec_params("DELETE FROM tactic_state_opponents WHERE state_id = $1", stateId);
        tx->exec_params("DELETE FROM tactic_jobs WHERE state_id = $1", stateId);
        for (const auto& o : body.at("opponents"))
            tx->exec_params("INSERT INTO tactic_state_opponents (state_id, number, x, y) VALUES ($1, $2, $3, $4)",
                            stateId, o.at("number").get<int>(), o.at("x").get<double>(), o.at("y").get<double>());
        for (const auto& j : body.at("jobs")) {
            const bool hasB = j.contains("target_b") && j["target_b"].is_number_integer();
            const bool hasP = j.contains("partner_position_id") && j["partner_position_id"].is_number_integer();
            const std::string kind = j.at("kind").get<std::string>();
            const auto& targets = j.at("targets");
            auto k = tx->exec_params("SELECT multi_a, target_a_label IS NULL AS names_nobody FROM tactic_job_kinds WHERE code = $1", kind);
            if (k.empty()) throw std::runtime_error("unknown job kind: " + kind);
            // A kind with no target label (line-hold, compact-block, the 'home'
            // rule) names nobody; every other kind needs at least one man.
            if (targets.empty() && !k[0]["names_nobody"].as<bool>())
                throw std::runtime_error("job " + kind + " needs one of their men");
            if (!k[0]["multi_a"].as<bool>() && targets.size() > 1)
                throw std::runtime_error("job " + kind + " takes one man");
            const int pid = j.at("position_id").get<int>();
            tx->exec_params(
                "INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance) "
                "VALUES ($1, $2, $3, CASE WHEN $4::boolean THEN $5::smallint END, CASE WHEN $6::boolean THEN $7::smallint END, $8)",
                stateId, pid, kind, hasB, hasB ? j["target_b"].get<int>() : 0,
                hasP, hasP ? j["partner_position_id"].get<int>() : 0, j.value("stance", std::string("goal_side")));
            int ord = 1;
            for (const auto& t : targets)
                tx->exec_params("INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES ($1, $2, $3, $4)",
                                stateId, pid, t.get<int>(), ord++);
        }
        tx->exec_params("UPDATE tactic_plans SET updated_at = now() WHERE id = $1", st[0]["plan_id"].as<long long>());
        db->commit(tx);
        return true;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

json TacticPlans::copyFromGame(const json& b, long long byUserId) {
    auto* db = Database::getInstance();
    auto formationOf = [&](const std::string& team) -> long long {
        auto r = db->query("SELECT f.id FROM game_demo_teams t JOIN formations f ON f.code = t.formation_code "
                           " WHERE t.name = $1 LIMIT 1", {team});
        return r.empty() ? 0 : r[0]["id"].as<long long>();
    };
    const std::string usTeam = b.value("us_team", std::string()), themTeam = b.value("them_team", std::string());
    const long long us = formationOf(usTeam), them = formationOf(themTeam);
    if (!us) return {{"error", "No formation for team: " + usTeam}};
    if (!them) return {{"error", "No formation for team: " + themTeam}};
    const std::string moment = b.value("moment", std::string("out_of_possession"));
    // The block from where the ball is, in our frame (y 0 = our goal line):
    // in their third we're pressing high, in ours we're in a low block.
    const double ballY = b.at("ball").at("y").get<double>();
    const std::string block = ballY >= 66.7 ? "high" : ballY >= 33.3 ? "mid" : "low";
    const long long planId = create(us, them, moment, block, byUserId);
    if (!planId) return {{"error", "Unknown formation, moment or block."}};

    // Their man on the ball, else the one nearest it.
    int ballWith = b.contains("ball_with") && b["ball_with"].is_number_integer() ? b["ball_with"].get<int>() : 0;
    if (ballWith < 1 || ballWith > 11) {
        const double bx = b["ball"]["x"].get<double>() * 0.68, by = ballY * 1.05;
        double best = 1e18;
        for (const auto& o : b.at("opponents")) {
            const double dx = o["x"].get<double>() * 0.68 - bx, dy = o["y"].get<double>() * 1.05 - by, d = dx * dx + dy * dy;
            if (d < best) { best = d; ballWith = o["number"].get<int>(); }
        }
    }

    auto tx = db->beginTransaction();
    try {
        auto root = tx->exec_params("SELECT id FROM tactic_states WHERE plan_id = $1 AND parent_state_id IS NULL", planId);
        if (root.empty()) { db->rollback(tx); return {{"error", "Plan has no root."}}; }
        const long long rootId = root[0]["id"].as<long long>();
        const json copied = {{"source", b.value("source", json::object())}, {"ball", b["ball"]},
                             {"ours", b.value("ours", json::array())}, {"by_user_id", byUserId}};
        auto st = tx->exec_params(
            "INSERT INTO tactic_states (plan_id, parent_state_id, ball_with, copied_from) "
            "VALUES ($1, $2, $3, $4::jsonb || jsonb_build_object('at', now())) RETURNING id",
            planId, rootId, ballWith, copied.dump());
        const long long stateId = st[0]["id"].as<long long>();
        for (const auto& o : b.at("opponents"))
            tx->exec_params("INSERT INTO tactic_state_opponents (state_id, number, x, y) VALUES ($1, $2, $3, $4)",
                            stateId, o.at("number").get<int>(), o.at("x").get<double>(), o.at("y").get<double>());
        int jobs = 0;
        json skipped = json::array();
        for (const auto& m : b.value("ours", json::array())) {
            const int pid = m.value("position_id", 0);
            if (pid < 2 || pid > 11 || !m.contains("concept_id") || !m["concept_id"].is_number_integer()) continue;
            bool hasTarget = m.contains("target") && m["target"].is_number_integer() &&
                             m["target"].get<int>() >= 1 && m["target"].get<int>() <= 11;
            int target = hasTarget ? m["target"].get<int>() : 0;
            // The concept's kind that fits: one naming nobody when there is no
            // target, one taking a man when there is.
            auto k = tx->exec_params(
                "SELECT code FROM tactic_job_kinds WHERE concept_id = $1 AND (target_a_label IS NULL) = $2 "
                " ORDER BY sort_order, code LIMIT 1", m["concept_id"].get<int>(), !hasTarget);
            // A press with no man named presses the man on the ball.
            if (k.empty() && !hasTarget) {
                k = tx->exec_params("SELECT code FROM tactic_job_kinds WHERE concept_id = $1 AND rule = 'press' "
                                    " ORDER BY sort_order, code LIMIT 1", m["concept_id"].get<int>());
                if (!k.empty()) { hasTarget = true; target = ballWith; }
            }
            if (k.empty()) { skipped.push_back({{"position_id", pid}, {"concept_id", m["concept_id"]}}); continue; }
            tx->exec_params("INSERT INTO tactic_jobs (state_id, position_id, kind) VALUES ($1, $2, $3)",
                            stateId, pid, k[0]["code"].as<std::string>());
            if (hasTarget)
                tx->exec_params("INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES ($1, $2, $3, 1)",
                                stateId, pid, target);
            ++jobs;
        }
        tx->exec_params("UPDATE tactic_plans SET updated_at = now() WHERE id = $1", planId);
        db->commit(tx);
        auto codes = db->query("SELECT (SELECT code FROM formations WHERE id = $1::int) AS us, "
                               "       (SELECT code FROM formations WHERE id = $2::int) AS them",
                               {std::to_string(us), std::to_string(them)});
        return {{"plan_id", planId}, {"state_id", stateId}, {"us", codes[0]["us"].as<std::string>()},
                {"them", codes[0]["them"].as<std::string>()}, {"block", block}, {"ball_with", ballWith},
                {"jobs", jobs}, {"skipped", skipped}};
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

bool TacticPlans::deleteState(long long stateId) {
    auto* db = Database::getInstance();
    auto r = db->query("DELETE FROM tactic_states WHERE id = $1::int AND parent_state_id IS NOT NULL RETURNING id",
                       {std::to_string(stateId)});
    return !r.empty();
}
