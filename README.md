# Threat Illustrator

Threat Illustrator is a small World of Warcraft addon for viewing nearby enemies and their threat toward you. It presents visible hostile nameplate units in a movable, scrollable panel, with each unit's name, health bar, and threat color.

## Use

1. Install the `ThreatIllustrator` folder in your WoW `Interface/AddOns` directory and enable the addon.
2. The panel appears by default on first run; later runs restore its saved visibility. Use `/ti` or `/threatillustrator` to show or hide it.
3. Drag the panel's title area to move it. Its position and whether it was visible are saved between sessions.

## What the panel shows

- The addon scans up to 40 visible nameplate unit tokens while you are in combat. It includes units that are attackable by you and have a threat status.
- Each row shows the enemy's name. The bar fill represents its current health relative to its maximum health.
- Bar color represents the threat status reported by the game. The current mapping is:

| Status | Color | Meaning |
| --- | --- | --- |
| 0 | Red | Low threat |
| 1 | Orange | High threat |
| 2 | Yellow | Primary target, not high threat |
| 3 | Green | Primary target and high threat |

The scan refreshes every 0.1 seconds during combat. When combat ends, scanning stops and the panel retains the most recent scan until it is refreshed again. The addon currently lists enemies attackable by you; it does not add enemies solely because they are attacking another party member. Rows do not currently target an enemy when clicked.

## Saved settings

WoW stores the panel's visibility and position in the `ThreatIllustratorDB` SavedVariable. The position is saved relative to the screen, so it can be restored if the screen dimensions change.
