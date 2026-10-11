# Majestic Beasts

A World of Warcraft: Midnight addon that shows where to place each skinning lure to summon the Majestic Beasts.

## Lure locations

| Beast | Lure | Zone | Coordinates |
|---|---|---|---|
| Gloomclaw | Majestic Eversong Lure | Eversong Woods | 41.95, 79.70 |
| Silverscale | Majestic Zul'Aman Lure | Zul'Aman | 47.55, 53.65 |
| Lumenfin | Majestic Harandar Lure | Harandar | 66.62, 47.84 |
| Umbrafang | Majestic Voidstorm Lure | Voidstorm | 54.13, 65.25 |
| Netherscythe | Grand Beast Lure | Voidstorm | 43.20, 82.82 |

Stand at the spot on foot until you get the **Sixth Sense** debuff, then use the lure. The debuff does not show while mounted.

## Features

- A window listing every beast with its lure, zone, coordinates, lures in your bags and live distance.
- Click a row to set a waypoint (TomTom if installed, otherwise the built-in map pin). Shift-click to put the location in chat.
- Pins on the zone and continent world maps.
- A sound and chat alert when you arrive at a lure spot.
- A Craft button per lure, enabled when you have the reagents. The first click of a session opens Skinning; click again to craft.

## How to use

1. Type `/majestic` (or pick **Majestic Beasts** from the addon compartment menu on the minimap) to open the window.
2. Click a beast's row to set a waypoint to its lure spot.
3. Fly there and **dismount**. When you are within 15 yards the addon plays a sound and prints a reminder in chat.
4. Wait for the **Sixth Sense** debuff, then use the lure from your bags.
5. Kill and skin the beast. Each lure can be used once per day; the lures do not share a cooldown.

If you don't have the lure, hover the **Craft** button to see what you're missing, or click it to make one.

## Mouse-over details

### Beast row (window) and map pin

Hovering a row in the window or a pin on the world map shows the same tooltip:

| Line | What it shows |
|---|---|
| Beast name | The beast the lure summons, e.g. Gloomclaw |
| Type | Cat, Turtle, Sporeglider, Shredclaw or Grand Beast |
| Lure | The lure item to use at this spot |
| Location | Zone and coordinates |
| In bags | How many of that lure you are carrying |
| Recipe unlock | Skinning specialization points needed to learn the lure (hidden for the Eversong lure, which is free) |
| Placement note | A landmark description of the spot, e.g. "under the large bridge by the small lake, not on top of it" |
| Reminder | Stand on foot until you get Sixth Sense, then use the lure |

The tooltip ends with the available clicks: click to set a waypoint, and (in the window) shift-click to put the location in your chat box.

### Row status text

The right side of each row shows, without hovering:

- **Lure ready in ...** - the lure item is on cooldown
- **You are here** - you are within 15 yards of the spot
- **N yds** - distance to the spot when you are on the same continent
- **No lure** - you have none in your bags and are too far away for a distance
- The lure icon is greyed out when you have none, and shows a count when you do.

### Craft button

Hovering **Craft** lists every reagent for that lure as `have / need`, green when you have enough and red when you don't. Counts include your bags, bank and warband bank. The button is greyed out until every reagent is covered.

Clicking it crafts one lure. The game only allows this while Skinning is loaded, so the first click of a session opens the Skinning window and a second click crafts. If you haven't learned the recipe, it tells you how many spec points it needs.

## Commands

- `/majestic` or `/mbeasts` - toggle the window
- `/majestic list` - print all lure spots to chat
- `/majestic pins` - toggle world map pins
- `/majestic alert` - toggle the arrival alert

## Install

Copy this folder to `World of Warcraft\_retail_\Interface\AddOns\MajesticBeasts`.
