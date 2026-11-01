# MajesticBeasts

The user's own addon (not a patched third-party one), so there is no baseline/patch-commit convention. Edit freely. The workspace-level `E:\VScode\CLAUDE.md` covers paths, deploying and Midnight API pitfalls.

## Files

Load order is set in `MajesticBeasts.toc`: Data, Core, Craft, Map, UI.

- `Data.lua`: `ns.BEASTS`, one entry per beast. Coordinates are zone-map 0-100, `questID` is the hidden daily flag, and `points` is the Skinning spec points needed for the recipe. Keep the README's location table in sync when this changes.
- `Core.lua`: shared helpers on `ns` (lure info, availability, distance, waypoints), the arrival alert, SavedVariables defaults and slash commands.
- `Craft.lua`: reagent counts and crafting the lure through `C_TradeSkillUI`.
- `Map.lua` / `Map.xml`: world map pin mixin and data provider, plus the shared beast tooltip (`ns.AddBeastTooltip`).
- `UI.lua`: the main window, built lazily on first toggle.

## Things to keep

- **The arrival alert only runs on Skinning characters.** `UpdateArrivalTicker` in Core.lua starts or cancels the 1s ticker based on `MajesticBeastsDB.alert` and `ns.HasSkinning()`. It's re-checked on `PLAYER_LOGIN`, on `SKILL_LINES_CHANGED` and from `/majestic alert`. Don't go back to starting an unconditional ticker in `ADDON_LOADED`, because profession info isn't reliable that early anyway.
- **Do position work once per tick.** `CheckArrival` reads the player's world position once and calls `DistanceFrom` for each beast. Lure spots' world positions are cached in `beastWorld`. Use `ns.GetDistance` only for one-off lookups.
- `ns.SKINNING` (393) is the single place the Skinning ID lives. It's the skill line for `GetProfessionInfo` and the profession ID for `OpenTradeSkill`.
- `MajesticBeastsPinMixin:SetPassThroughButtons` must stay a no-op, or opening the map in combat raises ADDON_ACTION_BLOCKED.
- Crafting must come from a hardware click. It also only works while Skinning is the loaded trade skill, which is why the first click may just open Skinning.

## Checking changes

- `luac -p Core.lua Craft.lua Map.lua UI.lua Data.lua`
- There are no automated tests. Behaviour has to be checked in game after deploying and `/reload`; errors land in `!BugGrabber.lua` (see the workspace CLAUDE.md).
- Update README.md when user-visible behaviour, tooltip lines, status text or commands change. It documents each of these.
