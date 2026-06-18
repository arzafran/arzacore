# Issue Triage — arzacore-NES

Inherited open issues from agg23/openFPGA-NES. None are fixed here; documented for awareness.

## High-Priority

| # | Title | Type | Notes |
|---|-------|------|-------|
| #70 | Save-state crash | Bug | Core crashes on save-state load for certain mappers. Likely state-machine desync. Do not fix until mapper save-state code is audited. |
| #57 | Galaxian flickering / corruption | Bug | Sprite-related rendering artifact on Galaxian. Possibly mapper 0 OAM edge case. |
| #37 | Rad Racer state-leak | Bug | Resuming from sleep in Rad Racer (mapper 3) leaves audio/video state dirty. |
| #32 | OAM sprite limit glitch | Bug | Extra-sprites option interacts badly with certain games; 16-sprite-per-line mode causes incorrect priority. |

## Lower-Priority / Informational

| # | Category | Notes |
|---|----------|-------|
| #69–#33 (remaining ~8) | Mapper compat / feature requests | Mix of game-specific mapper bugs and feature asks (PAL timing, VRC7 audio). Upstream MiSTer core is the reference; changes should be upstreamed first. |

## Scope Note

These issues are inherited from the upstream agg23 port. arzacore-NES does not modify RTL, so all RTL bugs carry forward unchanged. Fix candidates should be patched in `rtl/` and submitted upstream before being applied here.
