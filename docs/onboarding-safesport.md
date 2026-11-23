# SafeSport for men's players (mig 1740)

Owner 2026-11-23: "safesport added to the todo list for every player and
place to upload their certificate" — U.S. Soccer requires it of every adult
on a team with a player under 18, and both men's teams have one. Men only
for now.

Built on the 🎓 onboarding checklist (mig 1526 / 1538: steps, uploads, the
club's ✅ check, renewals) as a third stage, `player`. Nobody is added by
hand:

- `onboarding_people` (view) = `person_onboarding` rows (volunteer / paid)
  plus every live `team_persons` player on an active team of a section
  listed in `onboarding_stage_sections` (track `player` when not on a staff
  track).
- `onboarding_stage_sections`: player → Mens. Add a row to cover another
  section.
- `onboarding_steps.min_age`: a step only for people that old (SafeSport =
  18; no birth date on file = shown).
- Step `safesport`: renews every 12 months, link and wording in the row.

The player sees "⛔ Required — 1 to do: SafeSport" in the 🚦 band, opens it,
takes the course from the link and uploads the certificate (🟡). A club
admin checks it on `#onboarding` → ⚽ Players (✅ Checked / ↩ Redo, or
uploads one a player sent another way). Player files are never emailed on,
so the compliance purge window does not delete them.

Code: `backend/src/models/Onboarding.cpp` (`kStepsSql`, `onPath`),
`frontend/js/components/onboarding-checklist.js`,
`frontend/js/screens/onboarding.js` (`OnboardingScreen`, ⚽ Players pill).
