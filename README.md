# Modding-in-FS25

Landing page for **Michal's InGame Mods** — a free script mod for *Farming Simulator 25* that removes speed limits, gives trailers absurd capacities, and puts 1156 hp in every big tractor. One zip, all config in a single Lua file.

🔗 **Live site:** https://michalaferber.github.io/Modding-in-FS25/

> Not sure a vehicle got patched? The mod logs everything to `log.txt` with a `MIGM:` prefix — before and after values, per vehicle, every load. Grep and know.

## What the mod does

| Feature | Detail |
| --- | --- |
| **No speed limit** | Overrides `Vehicle.getSpeedLimit` so every tool works at any speed. Factory top speed gets a 2× multiplier; cruise control is capped at 200 km/h. |
| **Max capacity** | A pattern table matches vehicles by config-path substring and rewrites fill-unit capacity on load — up to 940,000 L. Fill mass is ignored by default so the physics engine survives. |
| **Max horsepower** | Scales torque at the source via `VehicleMotor.getTorqueCurveValue`, matched by shop category + brand, so current and future large tractors from John Deere, Case IH, CLAAS, and Fendt are all covered. |

## Install

1. Drop `FS25_MichalsInGameMods.zip` into your mods folder — `Documents\My Games\FarmingSimulator2025\mods\`. Don't extract it, and don't rename it (the filename is the mod name).
2. Enable it when loading your savegame.
3. Optional: grep `log.txt` for `MIGM:` to see exactly what got patched.

## Make it yours

Everything lives at the top of `scripts/MichalsInGameMods.lua` inside the zip. Change the values, re-zip, done:

```lua
MIGM.TOP_SPEED_MULTIPLIER = 2.0   -- physics gets comedic above ~3.0
MIGM.CRUISE_MAX_KMH       = 200

MIGM.CAPACITY = {
    ["pacesetter"] = 940000,   -- match by config-path substring
    ["tdk301"]     = 60000,    -- add your own trailers here
}
MIGM.IGNORE_FILL_MASS = true   -- false = realistic 730-ton comedy

MIGM.BIG_TRACTOR_HP = 1156
MIGM.BIG_TRACTOR_BRANDS = { JOHNDEERE=true, CASEIH=true, CLAAS=true, FENDT=true }
```

Set `MIGM.DEBUG = true` to print every vehicle's exact config path to the log, then copy the distinctive part into the table.

## Known quirks

- **Singleplayer only.** The motor changes won't sync cleanly across clients.
- **Shop specs don't update.** Store pages read cached data; judge by feel or a HUD mod.
- **Unload speed is unchanged.** Tipping 940k liters still takes a while — that's the discharge rate, not the capacity.
- **Game patches can rename things.** If a GIANTS update breaks a hook, the log will tell you exactly where.

## This repository

This repo hosts the static landing page ([`index.html`](index.html)) for the mod, served with **GitHub Pages**.

Deployment is automated by [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml): on every push to `main`, the workflow uploads the site and publishes it to GitHub Pages (the workflow enables Pages automatically on its first successful run). To preview locally, just open `index.html` in a browser — there is no build step.

> **Note:** the page's "Download the zip" button links to `FS25_MichalsInGameMods.zip` at the site root. Add that file to the repository (or point the link elsewhere) for the download to resolve.

## Credits

© 2026 | Created with ❤️ by [Michal Ferber](https://michalferber.dev), aka [TechGuyWithABeard](https://techguywithabeard.com)
