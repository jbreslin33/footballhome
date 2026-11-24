#pragma once
// TaxonomySync — keeps ⚽ Football → 🧬 Taxonomy in step with the game engine's C++.
//
// Owner 2026-11-24: "the taxonomy needs to always check c++ and db and game etc when
// loading every time OR … have a sync button" · "with timestamp" · "a sync on load is fine
// and a sync button is fine".
//
// The backend sees the engine's source read-only at ENGINE_SRC (docker-compose mounts
// game/src and shared/tactics there).  run() — called by every load of the page and by its
// 🔄 Sync now — does, in a few milliseconds:
//
//   check     every `// [behaviour: code]` tag in the source, game/src/ai/behaviours.list
//             and game_engine_behaviours must name the same codes; the differences and the
//             time go to the one-row table taxonomy_sync, which the page shows
//   refresh   only when the source has changed since the last run (a hash): the page's copy
//             of it — game_engine_sources, game_engine_classes (class, parent, lines, the
//             comment above), and each behaviour's file / line / symbol / class, anchored on
//             its tag
//
// It never writes a behaviour's meaning (status, concept): that is a migration's.
// The image build's lint (game/scripts/check_behaviours.sh) and `make game-deploy`'s
// scripts/taxonomy/check_engine_sync.py enforce the same agreement before a deploy; this
// is the page telling the truth between deploys.
class TaxonomySync {
public:
    // False when the engine source is not mounted (the page then shows the last check).
    static bool run();
};
