# game/ship — what goes live with the clean-slate game (G5.23, DESIGN §8.121)

`frontend/` here is the **fh-game.v2** browser client (staged: the live
`/srv/footballhome/frontend` is served straight from the repo, and the live
daemon still speaks v1). Ship in ONE step:

1. Live DB: apply migs 919+ (the PL load) and 1080-onward to `footballhome`.
2. Rebuild + restart the `footballhome_game` daemon from this commit.
3. Copy `game/ship/frontend/game.html` and `game/ship/frontend/js/game/*.js`
   over `frontend/` (bump the `?v=` on the four script tags), hard refresh.
4. Club backend: drop `PUT /api/game/player` and the attributes / level_band
   from `GET /api/game/roster` (GameRosterController / models/GameRoster) —
   nothing writes made-up attributes any more. Deploy the backend.
5. Delete this directory.
