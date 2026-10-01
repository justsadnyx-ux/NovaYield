# NovaYield

**NovaYield** is a custom UI fork of [Infinite Yield](https://github.com/EdgeIY/infiniteyield) with a fresh "Midnight Aurora" theme. All 400+ commands are preserved — only the visual layer has been modified.

## Theme

- **Name:** Midnight Aurora
- **Backgrounds:** Deep navy (#121520, #1C2030, #2A3048)
- **Accents:** Cyan (#00C8FF) top border, Violet (#8250FF) bottom border
- **Fonts:** Gotham family (Bold/Regular/Light/Medium/Italic)
- **Hover effects:** Buttons lighten on mouseover

## Credits

Original Infinite Yield by:
**Edge // Zwolf // Moon // Sleaze // Toon // Peyton // ATP**

https://github.com/EdgeIY/infiniteyield

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/justsadnyx-ux/NovaYield/master/novayield-custom.lua"))()
```

## Features

All original IY features preserved:
- 400+ commands (fly, noclip, goto, esp, freecam, etc.)
- Plugin system (.iy files)
- Event binds (OnSpawn, OnChatted, OnDied, etc.)
- Keybinds (click TP, click delete, custom binds)
- Waypoints (save/load positions)
- Aliases (custom command shortcuts)
- Theme editor (color picker)
- Logs (chat logs, join logs)
- Save system (settings persist)

## Building

To rebuild after IY updates:

```bash
node build-novayield.mjs
```

This reads the original IY source and applies all UI customizations.

## License

MIT (same as original Infinite Yield)
