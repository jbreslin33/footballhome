# Player body — Quaternius "Universal Base Characters" (Standard, Aug 2025)

`body_male.gltf` / `.bin` and the textures here are the pack's Superhero male body
(12.5k triangles, a 65-bone humanoid skeleton), unchanged except: texture paths renamed,
textures resized to 1024 px (colour/roughness as JPEG), the two image paths that pointed at
files missing from the pack (`*_Normal_png.png`) pointed at the real normal maps.

Models by Quaternius — https://quaternius.com/packs/universalbasecharacters.html —
licensed CC0 1.0 (public domain dedication). Credit given as thanks, not required.

The hair (`hair_parted`, `hair_buzzed`, `hair_beard`) is the pack's "Origin at 0" glTF hairstyles,
modelled in the body's own space; their texture paths renamed to the shared hair1_* files.

Used by `frontend/js/game/bodies.js` (graphics tier 2, 2026-11-11).
