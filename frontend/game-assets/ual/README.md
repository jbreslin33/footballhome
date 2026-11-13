# Player locomotion clips — Quaternius "Universal Animation Library" (Standard, v3.0, Jun 2026)

`locomotion.glb` holds four clips from the pack's `Unreal-Godot/UAL1_Standard.glb` (no root motion):
`Idle_Loop`, `Walk_Loop`, `Jog_Fwd_Loop`, `Sprint_Loop`. Only the node tree and those animations are kept,
with no meshes (`game/scripts/trim_ual_clips.py`). The rig matches the body in `../ubc/` bone for bone.
Read off the pack's root-motion file: walk 0.97 m/s (1.30 m a loop), jog 5.36 m/s (5.0 m), sprint
8.25 m/s (5.5 m).

Animations by Quaternius: https://quaternius.com/packs/universalanimationlibrary.html,
https://quaternius.itch.io/universal-animation-library. Licensed CC0 1.0 (public domain dedication).
Credit given as thanks, not required.

Used by `frontend/js/game/bodies.js` with `?bodies=anim` (G5.105, 2026-11-13).
