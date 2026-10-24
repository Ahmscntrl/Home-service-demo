# Goose Chaos — Roblox

Asymmetric multiplayer: up to 6 **geese** terrorize a village: scare the
villagers, steal their things, bank loot in their nests and work through a
prank to-do list. One **groundskeeper** (a player, or the computer when you
play alone) catches geese, puts items back and raids nests. Halfway through
he lets the **dog** out. Geese can also steal from each other's nests.

This is the Roblox port of the web prototype in `../goose-chaos/`.

## Open it in Roblox Studio (quickest)

1. Open **`GooseChaos.rbxl`** in Roblox Studio (File → Open from File).
2. Press **Play** (F5). You'll be a goose and the computer plays the groundskeeper.
3. To test with a real groundskeeper: **Test → Clients and Servers → 2 players → Start**.
   One client is picked as the groundskeeper each round.

`GooseChaos.rbxl` is built from the `src/` scripts, so edits in Studio and
edits here can drift. For ongoing development use Rojo (below), or copy
scripts back into `src/`.

## Develop with Rojo (recommended)

1. Install the [Rojo Studio plugin](https://create.roblox.com/store/asset/13916111004) and the Rojo CLI
   (`cargo install rojo` or download from <https://github.com/rojo-rbx/rojo/releases>).
2. In this folder run `rojo serve`.
3. In Studio open any empty place, click the Rojo plugin → **Connect**.
4. Edit the `.luau` files; Studio updates live.
5. `rojo build -o GooseChaos.rbxl` rebuilds the place file.

Type-check: `luau-lsp analyze --definitions=globalTypes.d.luau --sourcemap=sourcemap.json src`
(definitions file from the luau-lsp repo; `rojo sourcemap -o sourcemap.json` makes the sourcemap).

## Controls

| Goose | Key | Touch |
|---|---|---|
| Move | WASD | joystick |
| Grab item / steal from a nest | **E** on the item | tap the prompt |
| Drop item | **Q** | DROP button |
| HONK (stuns the groundskeeper within 18 studs) | **Space** | HONK button |
| Sprint (drains stamina) | **Shift** | RUN button |
| Bank an item | walk onto your own nest while carrying | |

| Groundskeeper | How |
|---|---|
| Catch a goose | touch it (it's sent to its nest, loses what it carries) |
| Put an item back | **E** on it |
| Raid a nest | walk onto it: the most valuable item goes home |

## Rules

- Rounds are 3 minutes with a short intermission between them.
- Four villagers wander the green; some carry items. Honk near one and they
  panic and drop what they hold. 5 points per scare.
- Every goose has a prank list (steal the hat, scare 3 villagers, keys in the
  pond, honk him 3 times, 4 things in your nest). Each prank pays 40–60 and
  finishing the list pays +150.
- Goose score = value of items in your nest at the end + 10 per honk that
  stunned him + scares + prank bonuses.
- Groundskeeper score = 25 per catch + 15 per item put back + 10 per dog catch.
- At 1:30 the dog is let out. It is faster than you, knocks the item out of
  your beak, and a honk stuns it for 2 seconds.
- After a catch a goose gets 3 seconds of safety (a force field).
- Dropping the keys in the pond is a prank worth bonus points.
- A dropped item returns home by itself after 20 seconds.
- The groundskeeper walks faster for every item that is banked.

All the numbers live in `src/shared/Config.luau`.

## Layout

```
default.project.json        Rojo project (maps src/ into the place)
GooseChaos.rbxl             built place file
src/shared/Config.luau      tuning numbers
src/shared/ItemDefs.luau    the 9 stealable items
src/shared/Remotes.luau     RemoteEvents, created on the server
src/server/MapBuilder.luau  builds the village from parts (no assets needed)
src/server/Items.luau       grab / carry / bank / steal / return
src/server/Nav.luau         shared pathfinding mover for NPCs
src/server/Rig.luau         builds animated R15 NPC bodies
src/server/Costumes.luau    goose/groundskeeper looks, stun and honk effects
src/server/Villagers.luau   wandering villagers that panic when honked at
src/server/Dog.luau         the dog
src/server/NpcKeeper.luau   computer groundskeeper
src/shared/Tasks.luau       the prank list
src/server/Main.server.luau round loop, roles, honking, catching, scoring
src/client/Controls.client.luau  keys + touch buttons
src/client/HUD.client.luau       timer, role, stamina, scoreboard, toasts
```

## Next steps

- Better goose look (a proper goose mesh instead of a dressed-up avatar).
- Villagers that pick items back up and carry them around more.
- Real goose honk and scream sounds (built-in Roblox sounds are placeholders; swap IDs in Config.SOUNDS).
- Cosmetics shop: hats, honk sounds, trails.
- DataStore for persistent wins and best scores.
