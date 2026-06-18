# Issue Triage

Triage of the ~27 open issues inherited from [agg23/openfpga-snes](https://github.com/agg23/openfpga-snes) as of the arzacore fork. This document is reference only — no fixes are applied here.

## Top Priority

| # | Title | Notes |
|---|-------|-------|
| #110 | DKC save bug | Donkey Kong Country save data corruption / loss. High user impact; affects the most-played SNES titles in the library. |
| #59 | Sleep/savestates not supported | Architectural limitation shared with MiSTer and Analogue Super NT; upstream MiSTer discussion confirms no near-term path. Tracked here for completeness. |
| #106 | Port MiSTer changes | Upstream MiSTer SNES core (srg320) has accumulated fixes and feature additions since the last sync. Needs a diff/cherry-pick pass. |
| #107 | NHL freeze | NHL series games hang during gameplay. Likely a timing or memory-map regression. |
| #105 | RPG glitches | Visual or logic glitches in RPG titles (exact games TBD from issue thread). May overlap with #106 upstream fixes. |

## Other Open Issues (lower priority)

The remaining ~22 open issues cover a mix of: game-specific compatibility bugs, controller edge cases, video output quirks, expansion chip edge cases (BSX, SPC7110), and feature requests (MSU support, Super Game Boy). Review the GitHub issue tracker for current state; many may be resolved by a MiSTer upstream sync (#106).

## Process

1. Verify each issue still reproduces on the arzacore build before triaging as confirmed.
2. Cross-reference with MiSTer SNES release notes to identify issues already fixed upstream.
3. Open new issues on the arzacore-SNES tracker for confirmed reproducible bugs; close or link upstream as appropriate.
