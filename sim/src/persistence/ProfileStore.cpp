// footballhome sim - ProfileStore implementation
// See ProfileStore.hpp and DESIGN.md §16.6, §22.12.

#include "persistence/ProfileStore.hpp"

#include "common/M0Attributes.hpp"

#include <cstring>
#include <utility>

namespace fh::sim::persistence {

namespace {

// AttributeSet / ConceptSet / RecognitionSet codecs work in
// std::vector<std::uint8_t>. ProfileBlob uses std::vector<std::byte>.
// Copy via memcpy — trivially the same 1-byte layout, but strict-
// aliasing-safe and free of reinterpret_cast.
std::vector<std::byte> toByteVec(const std::vector<std::uint8_t>& src)
{
    std::vector<std::byte> out(src.size());
    if (!src.empty()) {
        std::memcpy(out.data(), src.data(), src.size());
    }
    return out;
}

std::vector<std::uint8_t> toU8Vec(const std::vector<std::byte>& src)
{
    std::vector<std::uint8_t> out(src.size());
    if (!src.empty()) {
        std::memcpy(out.data(), src.data(), src.size());
    }
    return out;
}

} // namespace

profile::PlayerProfile ProfileStore::loadOrCreate(PersonId person)
{
    auto blob_opt = db_.loadProfile(person);
    if (blob_opt.has_value()) {
        const auto& blob = *blob_opt;
        profile::PlayerProfile p;
        // M0: `attributes` column holds physical only. technical + mental
        // are M1+ and stay empty. See §21.5 loose end for the future
        // multi-category encoding.
        p.physical    = profile::AttributeSet  ::fromBytes(toU8Vec(blob.attributes));
        p.concepts    = profile::ConceptSet    ::fromBytes(toU8Vec(blob.concepts));
        p.recognition = profile::RecognitionSet::fromBytes(toU8Vec(blob.recognition));
        return p;
    }

    // First-touch: build M0 baseline, persist, return.
    profile::PlayerProfile p;
    p.physical = m0::defaultPhysical();
    p.concepts = m0::defaultConcepts();
    // technical, mental, recognition stay empty (M0).
    save(person, p);
    return p;
}

void ProfileStore::save(PersonId person, const profile::PlayerProfile& p)
{
    ProfileBlob blob;
    blob.attributes  = toByteVec(p.physical.toBytes());
    blob.concepts    = toByteVec(p.concepts.toBytes());
    blob.recognition = toByteVec(p.recognition.toBytes());
    db_.upsertProfile(person, blob);
}

} // namespace fh::sim::persistence
