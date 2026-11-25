#include "TicketOrderSync.h"

#include <algorithm>
#include <chrono>
#include <iostream>
#include <mutex>
#include <thread>

#include "../database/Database.h"
#include "LeagueAppsService.h"

using json = nlohmann::json;

namespace {
std::mutex gTicketSyncMutex;

std::string text(const json& j, const char* key) {
    if (!j.contains(key) || j[key].is_null()) return "";
    if (j[key].is_string()) return j[key].get<std::string>();
    return j[key].dump();
}
}  // namespace

json TicketOrderSync::refreshIfStale(bool force) {
    std::lock_guard<std::mutex> lock(gTicketSyncMutex);
    auto* db = Database::getInstance();
    if (!force) {
        auto fresh = db->query("SELECT 1 FROM ticket_order_sync_state "
                               " WHERE last_run_at > now() - interval '2 minutes'");
        if (!fresh.empty()) return {{"ran", false}};
    }
    db->query("UPDATE ticket_order_sync_state SET last_run_at = now()");

    // Products sold as tickets.
    auto products = db->query("SELECT id, la_product_id FROM ticket_products "
                              " WHERE is_active AND la_product_id IS NOT NULL");
    if (products.empty()) return {{"ran", true}, {"newTickets", 0}};

    int created = 0;
    try {
        auto& la = LeagueAppsService::getInstance();
        const std::string site = std::to_string(la.getSiteId());
        long long lastUpdated = 0, lastId = 0;
        for (int page = 0; page < 20; ++page) {
            auto r = la.rawGet("sites/" + site + "/export/product-orders?program-id=0&last-updated="
                               + std::to_string(lastUpdated) + "&last-id=" + std::to_string(lastId));
            if (r.status != 200) throw std::runtime_error("product-orders HTTP " + std::to_string(r.status) + " " + r.error);
            json batch = json::parse(r.body);
            if (!batch.is_array() || batch.empty()) break;
            for (const auto& o : batch) {
                if (text(o, "status") != "OPEN_PAID") continue;
                const std::string orderId = text(o, "productOrderId");
                const std::string productId = text(o, "productId");
                if (orderId.empty() || productId.empty()) continue;
                auto known = db->query("SELECT 1 FROM tickets WHERE la_product_order_id = $1::bigint", {orderId});
                if (!known.empty()) continue;
                auto product = db->query("SELECT id FROM ticket_products WHERE is_active AND la_product_id = $1", {productId});
                if (product.empty()) continue;

                // The buyer.  Contact from the members API, once per holder.
                const std::string userId = text(o, "userId");
                std::string holderId;
                if (!userId.empty()) {
                    auto h = db->query("SELECT id, (email IS NULL AND phone IS NULL) AS bare FROM ticket_holders WHERE la_user_id = $1::bigint", {userId});
                    std::string email, phone;
                    if (h.empty() || h[0]["bare"].as<bool>()) {
                        auto m = la.rawGet("sites/" + site + "/members/" + userId);
                        if (m.status == 200) {
                            try { json mj = json::parse(m.body); email = text(mj, "email"); phone = text(mj, "mobilePhone"); }
                            catch (...) {}
                        }
                    }
                    auto up = db->query(
                        "INSERT INTO ticket_holders (la_user_id, person_id, first_name, last_name, email, phone) "
                        "VALUES ($1::bigint, "
                        "        (SELECT id FROM persons WHERE la_user_id = $6 "
                        "          UNION SELECT person_id FROM person_la_user_ids WHERE la_user_id = $6 LIMIT 1), "
                        "        NULLIF($2, ''), NULLIF($3, ''), NULLIF($4, ''), NULLIF($5, '')) "
                        "ON CONFLICT (la_user_id) DO UPDATE SET "
                        "   first_name = COALESCE(EXCLUDED.first_name, ticket_holders.first_name), "
                        "   last_name  = COALESCE(EXCLUDED.last_name, ticket_holders.last_name), "
                        "   email      = COALESCE(EXCLUDED.email, ticket_holders.email), "
                        "   phone      = COALESCE(EXCLUDED.phone, ticket_holders.phone), "
                        "   person_id  = COALESCE(ticket_holders.person_id, EXCLUDED.person_id), "
                        "   updated_at = now() "
                        "RETURNING id",
                        {userId, text(o, "firstName"), text(o, "lastName"), email, phone, userId});
                    holderId = up[0]["id"].c_str();
                }
                int quantity = 1;
                try { quantity = std::max(1, o.value("quantity", 1)); } catch (...) {}
                db->query(
                    "INSERT INTO tickets (product_id, holder_id, source_code, admits, amount, la_product_order_id, created_at) "
                    "VALUES ($1::int, NULLIF($2, '')::int, 'leagueapps', $3::int, COALESCE(NULLIF($4, '')::numeric, 0), $5::bigint, "
                    "        COALESCE(to_timestamp(NULLIF($6, '')::bigint / 1000.0), now())) "
                    "ON CONFLICT (la_product_order_id) DO NOTHING",
                    {product[0]["id"].c_str(), holderId, std::to_string(quantity), text(o, "orderTotal"), orderId,
                     text(o, "orderDate")});
                ++created;
            }
            const auto& tail = batch.back();
            long long lu = tail.value("lastUpdated", 0LL), li = tail.value("productOrderId", 0LL);
            if (lu == lastUpdated && li == lastId) break;
            lastUpdated = lu; lastId = li;
            if (batch.size() < 1000) break;
        }
        db->query("UPDATE ticket_order_sync_state SET last_error = NULL");
    } catch (const std::exception& e) {
        std::cerr << "[TicketOrderSync] " << e.what() << std::endl;
        db->query("UPDATE ticket_order_sync_state SET last_error = $1", {std::string(e.what()).substr(0, 500)});
        return {{"ran", true}, {"newTickets", created}, {"error", e.what()}};
    }
    if (created) std::cerr << "[TicketOrderSync] new tickets: " << created << std::endl;
    return {{"ran", true}, {"newTickets", created}};
}

void TicketOrderSync::startLoop() {
    std::thread([]() {
        for (;;) {
            try { refreshIfStale(); }
            catch (const std::exception& e) { std::cerr << "[TicketOrderSync loop] " << e.what() << std::endl; }
            std::this_thread::sleep_for(std::chrono::minutes(5));
        }
    }).detach();
}
