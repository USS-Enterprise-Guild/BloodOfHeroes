# Blood of Heroes

Blood of Heroes is a strict World of Warcraft 1.12.1 addon build.
The addon target interface is `11200` (WoW 1.12.1).

## Slash Commands

- `/blood toggle`  
  Enables or disables Blood of Heroes markers and nearby minimap updates.
- `/blood range <yards>`  
  Overrides nearby minimap detection radius with a fixed yard value.
- `/blood range reset`  
  Clears the manual override and returns nearby minimap detection to zoom-based range.

## Behavior

- World map rendering is focused on Eastern Plaguelands (EPL) and Western Plaguelands (WPL) data.
- Nearby minimap markers are shown when the player is in EPL/WPL and hidden outside those zones.
