// game/src/server/Rooms.hpp
//
// Tactics trainer step 2 (docs/tactics-trainer.md, DESIGN §8.166): one process, one
// socket, several matches. The live match is room 0 — everyone on "/game" joins it, as
// before. "/game?trainer=1&home=<team>&away=<team>" opens a practice room of the
// viewer's own: two Premier League sides from a goal kick, frozen until they play it,
// theirs to pause, slow and step without touching the live match. It closes when they
// leave.
//
// A RoomTransport is the INetworkTransport one GameServer sees: the real transport's
// sends and closes for its own members only. The router owns the real callbacks and
// hands each client to their room.

#pragma once

#include "net/INetworkTransport.hpp"
#include "net/WebSocketTransport.hpp"
#include "server/GameServer.hpp"

#include <chrono>
#include <functional>
#include <map>
#include <memory>
#include <optional>
#include <set>
#include <string>

namespace fh::game::server {

class RoomTransport final : public net::INetworkTransport {
public:
    explicit RoomTransport(net::INetworkTransport& real) : real_{real} {}
    void setOnConnect(OnConnectFn f) override { on_connect_ = std::move(f); }
    void setOnDisconnect(OnDisconnectFn f) override { on_disconnect_ = std::move(f); }
    void setOnMessage(OnMessageFn f) override { on_message_ = std::move(f); }
    bool send(ClientId id, std::span<const std::uint8_t> b) override { return members_.count(id) && real_.send(id, b); }
    void disconnect(ClientId id) override { if (members_.count(id)) real_.disconnect(id); }
    std::size_t clientCount() const override { return members_.size(); }
    void poll(int) override {}   // the router polls the real transport

    void join(ClientId id, const auth::JwtClaims& c) { members_.insert(id); if (on_connect_) on_connect_(id, c); }
    void leave(ClientId id) { if (!members_.erase(id)) return; if (on_disconnect_) on_disconnect_(id); }
    void message(ClientId id, std::span<const std::uint8_t> b) { if (members_.count(id) && on_message_) on_message_(id, b); }

private:
    net::INetworkTransport& real_;
    std::set<ClientId> members_;
    OnConnectFn on_connect_;
    OnDisconnectFn on_disconnect_;
    OnMessageFn on_message_;
};

// What a practice link asks for, from the request target's query.
struct PracticeAsk {
    std::string home, away;
    std::string goal_kick = "away";   // whose goal kick it starts from: "home" / "away"
};
std::optional<PracticeAsk> parsePracticeAsk(const std::string& request_path);

class RoomRouter {
public:
    using clock = std::chrono::steady_clock;
    // Builds a practice room's config for an ask (teams loaded from the DB), or nothing
    // if the ask names a team that isn't there.
    using PracticeConfigFn = std::function<std::optional<GameServer::Config>(const PracticeAsk&)>;

    RoomRouter(net::ws::WebSocketTransport& real, GameServer::Config live, std::uint16_t live_speed_pct,
               PracticeConfigFn practice, std::size_t max_practice = 4);

    // One pass of the loop: poll the socket, tick every room that is due at its own
    // speed. Returns when a tick or a heartbeat is done (or ~200 ms passed).
    void step();
    GameServer& live() { return *rooms_.at(0)->server; }
    std::size_t practiceRooms() const { return rooms_.size() - 1; }

private:
    struct Room {
        explicit Room(net::INetworkTransport& real) : transport{real} {}
        RoomTransport transport;               // outlives the server (declared first)
        std::unique_ptr<GameServer> server;
        clock::time_point next{};
        clock::time_point beat{};
        std::uint16_t was_pct = 0;
    };
    void onConnect(ClientId id, const auth::JwtClaims& c);
    void onDisconnect(ClientId id);
    void onMessage(ClientId id, std::span<const std::uint8_t> b);

    net::ws::WebSocketTransport& real_;
    PracticeConfigFn practice_;
    std::size_t max_practice_;
    std::map<int, std::unique_ptr<Room>> rooms_;   // 0 = the live match
    std::map<ClientId, int> room_of_;
    int next_room_ = 1;
};

}  // namespace fh::game::server
