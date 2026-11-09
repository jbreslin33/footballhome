// game/src/server/Rooms.cpp — see Rooms.hpp.

#include "server/Rooms.hpp"

#include "core/Clock.hpp"

#include <algorithm>
#include <cstdio>

namespace fh::game::server {

namespace {

// %XX and '+' decoded (a team name like "West Ham United" arrives as West%20Ham%20United).
std::string urlDecode(const std::string& s) {
    std::string out;
    for (std::size_t i = 0; i < s.size(); ++i) {
        if (s[i] == '+') { out.push_back(' '); continue; }
        if (s[i] == '%' && i + 2 < s.size()) {
            auto hex = [](char c) { return c >= '0' && c <= '9' ? c - '0' : c >= 'a' && c <= 'f' ? c - 'a' + 10 : c >= 'A' && c <= 'F' ? c - 'A' + 10 : -1; };
            const int a = hex(s[i + 1]), b = hex(s[i + 2]);
            if (a >= 0 && b >= 0) { out.push_back(static_cast<char>(a * 16 + b)); i += 2; continue; }
        }
        out.push_back(s[i]);
    }
    return out;
}

}  // namespace

std::optional<PracticeAsk> parsePracticeAsk(const std::string& request_path) {
    const auto q = request_path.find('?');
    if (q == std::string::npos) return std::nullopt;
    PracticeAsk ask;
    bool practice = false;
    std::size_t at = q + 1;
    while (at <= request_path.size()) {
        std::size_t amp = request_path.find('&', at);
        if (amp == std::string::npos) amp = request_path.size();
        const std::string kv = request_path.substr(at, amp - at);
        const auto eq = kv.find('=');
        const std::string k = kv.substr(0, eq);
        const std::string v = eq == std::string::npos ? "" : urlDecode(kv.substr(eq + 1));
        if (k == "trainer") practice = v == "1";
        else if (k == "home") ask.home = v;
        else if (k == "away") ask.away = v;
        else if (k == "gk" && (v == "home" || v == "away")) ask.goal_kick = v;
        at = amp + 1;
    }
    if (!practice) return std::nullopt;
    return ask;
}

RoomRouter::RoomRouter(net::ws::WebSocketTransport& real, GameServer::Config live, std::uint16_t live_speed_pct,
                       PracticeConfigFn practice, std::size_t max_practice)
    : real_{real}, practice_{std::move(practice)}, max_practice_{max_practice} {
    auto room = std::make_unique<Room>(real_);
    room->server = std::make_unique<GameServer>(std::move(live), room->transport);
    if (live_speed_pct > 0) room->server->setSpeedPct(live_speed_pct);
    room->next = room->beat = clock::now();
    room->was_pct = room->server->speedPct();
    rooms_.emplace(0, std::move(room));
    real_.setOnConnect([this](ClientId id, const auth::JwtClaims& c) { onConnect(id, c); });
    real_.setOnDisconnect([this](ClientId id) { onDisconnect(id); });
    real_.setOnMessage([this](ClientId id, std::span<const std::uint8_t> b) { onMessage(id, b); });
}

void RoomRouter::onConnect(ClientId id, const auth::JwtClaims& c) {
    int r = 0;
    if (auto ask = parsePracticeAsk(real_.requestPath(id))) {
        if (practiceRooms() >= max_practice_) {
            std::printf("fh-game: practice refused (%zu rooms open)\n", practiceRooms());
            real_.disconnect(id);
            return;
        }
        auto cfg = practice_ ? practice_(*ask) : std::nullopt;
        if (!cfg) {
            std::printf("fh-game: practice refused: unknown team(s) '%s' v '%s'\n", ask->home.c_str(), ask->away.c_str());
            real_.disconnect(id);
            return;
        }
        r = next_room_++;
        auto room = std::make_unique<Room>(real_);
        room->server = std::make_unique<GameServer>(std::move(*cfg), room->transport);
        room->next = room->beat = clock::now();
        room->was_pct = room->server->speedPct();
        rooms_.emplace(r, std::move(room));
        std::printf("fh-game: practice room %d for client %llu\n", r, static_cast<unsigned long long>(id));
    }
    room_of_[id] = r;
    rooms_.at(r)->transport.join(id, c);
}

void RoomRouter::onDisconnect(ClientId id) {
    const auto it = room_of_.find(id);
    if (it == room_of_.end()) return;
    const int r = it->second;
    room_of_.erase(it);
    auto rit = rooms_.find(r);
    if (rit == rooms_.end()) return;
    rit->second->transport.leave(id);
    if (r != 0 && rit->second->transport.clientCount() == 0) {
        rooms_.erase(rit);   // the practice room closes with its last viewer
        std::printf("fh-game: practice room %d closed\n", r);
    }
}

void RoomRouter::onMessage(ClientId id, std::span<const std::uint8_t> b) {
    const auto it = room_of_.find(id);
    if (it == room_of_.end()) return;
    if (auto rit = rooms_.find(it->second); rit != rooms_.end()) rit->second->transport.message(id, b);
}

void RoomRouter::step() {
    const auto period = std::chrono::microseconds{1'000'000 / core::kTickRate};
    const auto beat = std::chrono::milliseconds{200};
    // The earliest thing due: a running room's next tick, a paused room's heartbeat.
    auto now = clock::now();
    auto due = now + beat;
    for (const auto& [_, room] : rooms_) due = std::min(due, room->server->speedPct() > 0 ? room->next : room->beat + beat);
    const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(due - now).count();
    real_.poll(static_cast<int>(ms > 0 ? ms : 0));   // callbacks may open or close rooms
    now = clock::now();
    for (auto& [_, room] : rooms_) {
        GameServer& s = *room->server;
        const std::uint16_t pct = s.speedPct();
        if (pct != room->was_pct) { room->was_pct = pct; room->next = now; }   // a new speed starts now
        if (pct == 0) {
            if (now >= room->beat + beat) { s.heartbeat(); room->beat = now; }
            continue;
        }
        if (now < room->next) continue;
        s.tickOnce();
        room->next += period * 100 / pct;
        if (room->next < now) room->next = now;   // fell behind — no catch-up burst
    }
}

}  // namespace fh::game::server
