# Issue Triage — arzacore-Genesis

Status as of 2026-06-18. Based on upstream opengateware/openFPGA-Genesis
(18 open issues as of triage date).

## Fixed by upstream PR #34 ("it lives")

PR #34 (commit 63c9a7d, merged as `origin/fixes`) resolves the following
upstream issues. This build is based on that commit.

| Issue | Title / Summary |
|-------|----------------|
| #33 | 32X / SVP detection crash |
| #31 | Incorrect timing / sprite flicker in some titles |
| #28 | Audio clicks on region switch |
| #26 | Save-state load corrupts VRAM |
| #23 | Screen tearing on 256-wide mode |
| #21 | Composite blend option broken after v0.4.0 |
| (others) | Miscellaneous stability fixes bundled in PR #34 |

## Remaining open issues

### #24 — Hellfire: FM audio garbled

FM channels produce incorrect output on the Hellfire title.
Likely a YM2612 channel-mask or key-on timing edge case in jt12.
Not addressed in PR #34.

### #20 — Sonic the Hedgehog: palette / colour corruption

Specific colour bands appear wrong in Sonic 1 (Green Hill Zone background).
Potentially a CRAM-write timing issue. Tracked upstream; no fix yet.

### #22 — Save-states (feature request)

Request to implement proper save-state support (suspend/resume via APF
framework). This is a significant feature, not a bug. Not scheduled.

## Out of scope for this build

- PAL mode support (#various) — excluded by design; NTSC only.
- Sega CD / 32X emulation — outside the core's scope.
- YM2413 (Master System FM) — not wired in the Genesis APF port.

## Notes

- FX68K carries no explicit open-source license; included per
  community-distribution norm. Watch upstream for any license update.
- jt12 and jt89 are GPL-3.0 (Jose Tejada / Jotego); this build is
  therefore GPL-3.0 as a whole.
