# Modding-in-FS25

Landing page for **Michal's InGame Mods** — a free script mod for *Farming Simulator 25* that removes speed limits, gives trailers absurd capacities, and puts 1156 hp in every big tractor. One zip, all config in a single Lua file.

🔗 **Live site:** https://michalaferber.github.io/Modding-in-FS25/

> Not sure a vehicle got patched? The mod logs everything to `log.txt` with a `MIGM:` prefix — before and after values, per vehicle, every load. Grep and know.

## Features

| Feature | Detail |
| --- | --- |
| **No speed limit** | Overrides `Vehicle.getSpeedLimit` so every tool works at any speed. Factory top speed gets a 2× multiplier; cruise control is capped at 200 km/h. |
| **Max capacity** | A pattern table matches vehicles by config-path substring and rewrites fill-unit capacity on load — up to 940,000 L. Fill mass is ignored by default so the physics engine survives. |
| **Max horsepower** | Scales torque at the source via `VehicleMotor.getTorqueCurveValue`, with explicit per-vehicle overrides (John Deere 9R/9RX, Case IH Steiger, CLAAS XERION 12, Volvo VNX 300, Mack Anthem — 1156 hp). |

## Install

1. Grab `FS25_MichalsInGameMods.zip` from the [latest release](https://github.com/MichalAFerber/Modding-in-FS25/releases/latest) (or the site's Download button) and drop it into your mods folder — `Documents\My Games\FarmingSimulator2025\mods\`. Don't extract it, and don't rename it (the filename is the mod name).
2. Enable it when loading your savegame.
3. Optional: grep `log.txt` for `MIGM:` to see exactly what got patched.

## Make it yours

Everything lives at the top of [`mod/scripts/MichalsInGameMods.lua`](mod/scripts/MichalsInGameMods.lua). Change the values, re-zip (or re-tag and let CI build it), done:

```lua
MIGM.TOP_SPEED_MULTIPLIER = 2.0   -- factory top speed x this
MIGM.CRUISE_MAX_KMH       = 200

MIGM.CAPACITY = {                 -- liters, matched by config-path substring
    ["pacesetter"] = 940000,      -- Wilson Pacesetter
    ["tdk301"]     = 60000,       -- add your own trailers here
}
MIGM.IGNORE_FILL_MASS = true      -- true = fill weight doesn't crush the physics

MIGM.HORSEPOWER = {               -- explicit per-vehicle overrides
    ["series9rx"] = 1156,         -- John Deere 9RX
    ["steiger"]   = 1156,         -- Case IH Steiger
    ["xerion"]    = 1156,         -- CLAAS XERION 12
}
```

Set `MIGM.DEBUG = true` to print every vehicle's exact config path to the log, then copy the distinctive part into the table.

## Known quirks

- **Singleplayer only.** The motor changes won't sync cleanly across clients.
- **Shop specs don't update.** Store pages read cached data; judge by feel or a HUD mod.
- **Unload speed is unchanged.** Tipping 940k liters still takes a while — that's the discharge rate, not the capacity.
- **Game patches can rename things.** If a GIANTS update breaks a hook, the log will tell you exactly where.

## This repository

Both the mod and its website live here.

| What | Where |
| --- | --- |
| **Mod source** | [`mod/`](mod/) — `modDesc.xml`, `scripts/MichalsInGameMods.lua`, icon |
| Landing page | [`index.html`](index.html) |
| Privacy Policy | [`privacy.html`](privacy.html) |
| Terms of Use | [`terms.html`](terms.html) |

### Releasing the mod

The site's Download button always points at the **latest GitHub Release** asset. To ship a version:

1. Bump `<version>` in [`mod/modDesc.xml`](mod/modDesc.xml) and merge to `main`.
2. Tag it: `git tag v1.1.0.0 && git push origin v1.1.0.0` (tag must match the modDesc version — CI enforces it).
3. [`build-mod.yml`](.github/workflows/build-mod.yml) validates `modDesc.xml`, zips `mod/` with `modDesc.xml` at the zip root, and attaches `FS25_MichalsInGameMods.zip` to the release. The download button picks it up automatically.

A manual run (`workflow_dispatch`) builds the zip as a workflow artifact without releasing.

### The website

- **No build step.** Each page is a self-contained HTML file (inline CSS + a few lines of vanilla JS for the theme toggle). To preview locally, open `index.html` in a browser.
- **Deploy:** feature branch → PR → merge to `main` → GitHub Pages publishes automatically via [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml).
- **Design:** JetBrains Mono display headings (self-hosted `woff2`, no Google Fonts), dark/light theme following `prefers-color-scheme` with a header toggle that persists your choice, and an Octocat repo link in the header and footer of every page.

### Privacy

The site collects **no personal data and sets no cookies**. It uses a self-hosted, privacy-friendly Plausible instance for aggregate analytics only. The mod itself runs entirely on your machine and never connects to the internet. Full details in the [Privacy Policy](privacy.html).

### Standards deviations

This is a **Class C micro-project** (FS25 mod) under the TGWAB Dev Standards, which changes a few defaults:

- **GitHub Pages, single-file HTML, no custom domain** — the standing home for Class C micro-projects (no Astro/Tailwind migration; the full §11/§12 SEO + plumbing kit does not apply).
- **Deployed via a GitHub Actions workflow** rather than the classic Jekyll branch build — chosen so Pages could self-enable on the first run without touching repository settings. The published output is the same static HTML.
- **CSP ships in a `<meta http-equiv>` tag** instead of a Cloudflare `_headers` file, because GitHub Pages can't serve custom response headers. This means `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, and CSP `frame-ancestors` can't be set here; the meta CSP still enforces `default-src 'none'` with a tight allow-list.

## Credits

| Component | Version | License |
| --- | --- | --- |
| [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) (via [Fontsource](https://fontsource.org/fonts/jetbrains-mono)) | 5.2.8 | [SIL OFL 1.1](fonts/JetBrainsMono-OFL.txt) |
| [Plausible Analytics](https://plausible.io/) (self-hosted, loaded at runtime) | — | AGPL-3.0 |
| GitHub Octocat mark | — | © GitHub, Inc. |

The brand mark / favicon ([`favicon.svg`](favicon.svg)) was created for this project. Full third-party notices are in [`NOTICE`](NOTICE).

## License

MIT — see [`LICENSE`](LICENSE). Third-party component notices live in [`NOTICE`](NOTICE). Do whatever you want with it: edit it, redistribute it, learn from it.

© 2026 | Created with ❤️ by [Michal Ferber](https://michalferber.dev/), aka [TechGuyWithABeard](https://techguywithabeard.com/).
