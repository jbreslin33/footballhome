-- 1867 (2026-11-24) — 🗻 Solid 3D: easier hands.  Owner: "we need it easier to spin and zoom etc.
-- the controls are awkward".  The controls now work the same at every zoom (drag turns and moves,
-- wheel / pinch zooms at the pointer, right- or shift-drag pans, double-tap zooms in, keys); the
-- hint under the buttons says so.  Words only.
UPDATE message_templates
   SET body = 'Drag to turn and move up or down · scroll or pinch to zoom where you point · right-drag or shift-drag to slide · ctrl-drag to tilt · tap a level for its tables, double-tap to zoom in · keys ← → ↑ ↓ + − F'
 WHERE kind = 'apsl_pyramid' AND tier = 'shape_hint_solid';
