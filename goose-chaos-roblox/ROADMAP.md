# Goose Chaos — Roadmap

One phase at a time. Each phase ends with a playtest and a decision:
move on, or fix what the playtest showed. Numbers live in
`src/shared/Config.luau`; tweak them freely between phases.

## Phase 0 — Prototype ✅ (done)

Web prototype proved the loop. Roblox port runs: round loop, geese vs
groundskeeper (player or NPC), items, nests, honk stun, villagers to
scare, prank list, the dog, terrain map, costumes, HUD.

## Phase 1 — Feel (current)

Goal: a solo round against the NPC is fun and fair. Nothing new; make
what exists feel good.

- [x] Balance: 470–320 in a won round with 3 catches. Good enough.
- [x] Verify the "caught with an item" bug is gone.
- [x] Real sounds: honk, scream, bark are real assets; the rest are
      built-in stand-ins (see Config.SOUNDS).
- [x] Goose feel: honk neck-stretch, waddle, sprint feathers.
- [x] Round-end results screen.
- [ ] Playtest the feel pass; fix anything that looks wrong.

Done when: you play three rounds in a row and want a fourth.

## Phase 2 — Multiplayer

Goal: 2–6 real players, one of them the groundskeeper.

- [ ] Player groundskeeper kit: net throw (short cooldown, stuns a goose
      so he can walk up and catch it), whistle that calls the dog to him.
- [ ] Stealing from other geese's nests feels good: pop + toast to the
      victim, small cooldown, the thief's nest glows briefly.
- [ ] Lobby with role vote ("I want to be the groundskeeper").
- [ ] Spectator camera for players who join mid-round.
- [ ] Test with Studio's 3-player local server, then a private server.

Done when: a 4-player session has at least one "did you see that" moment
per round.

## Phase 3 — Look

Goal: it looks like a real game in a thumbnail.

- [ ] Proper goose model (mesh, rigged, idle/waddle/honk animations).
- [ ] Groundskeeper and villager outfits from the catalog (shirts, pants,
      hats) instead of body colors.
- [ ] Map polish: a second house, a market stall, a well, a church with a
      bell you can ring, benches, lamp posts, a greenhouse.
- [ ] Day/evening lighting shift over the round.
- [ ] Icon + thumbnail for the game page.

## Phase 4 — Progression (what brings players back)

- [ ] DataStore: wins, total loot, best score, pranks completed.
- [ ] Unlockable animals with different abilities (raccoon opens bins and
      doors, cat knocks things off tables, seagull flies short hops).
- [ ] Cosmetics shop: hats, honk sounds, trails. Robux + earned coins.
- [ ] Daily prank list with bonus rewards.
- [ ] Leaderboards in the lobby.

## Phase 5 — Content and launch

- [ ] Second map (seaside town or school).
- [ ] Seasonal events (wedding, farmers' market, Halloween).
- [ ] Badges.
- [ ] Private servers.
- [ ] Publish, soft launch to friends, watch retention and tune.

## Later / ideas parking lot

- Two groundskeepers on big servers.
- Goose-only chaos mode: no groundskeeper, geese steal from each other.
- Villagers with routines (the postman delivers, the picnic at 1:00).
