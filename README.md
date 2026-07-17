# Modding-in-FS25

Landing page for **Michal's InGame Mods** — a free script mod for *Farming Simulator 25* that removes speed limits, gives trailers absurd capacities, and puts 1156 hp in every big tractor. One zip, all config in a single Lua file.

🔗 **Live site:** https://michalaferber.github.io/Modding-in-FS25/

> Not sure a vehicle got patched? The mod logs everything to `log.txt` with a `MIGM:` prefix — before and after values, per vehicle, every load. Grep and know.

## Features

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

## This repository (the website)

This repo hosts the static landing page for the mod, plus a Privacy Policy and Terms of Use.

| Page | File |
| --- | --- |
| Landing page | [`index.html`](index.html) |
| Privacy Policy | [`privacy.html`](privacy.html) |
| Terms of Use | [`terms.html`](terms.html) |

### How it works / deploy

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

The brand mark / favicon ([`favicon.svg`](favicon.svg)) was created for this project.

## License

MIT — see [`LICENSE`](LICENSE), which also carries the bundled-component notices. Do whatever you want with it: edit it, redistribute it, learn from it.

© 2026 | Created with ❤️ by [Michal Ferber](https://michalferber.dev/), aka [TechGuyWithABeard](https://techguywithabeard.com/).
