# Issue Triage

Open issues from upstream (mincer-ray/openfpga-GBA) carried forward for tracking. All are feature requests; none are regressions or build blockers.

---

## #23 — TATE Mode (Portrait/Rotated Display)

**Type:** Feature request  
**Status:** Open, not started

Request to support TATE (vertical/portrait) display mode for games that use a rotated screen orientation. The Analogue Pocket hardware supports screen rotation via the `video.json` scaler configuration. Implementation would require adding a rotated scaler mode entry and wiring up a menu option to toggle it. No HDL changes required; purely a firmware/pkg change.

---

## #17 — Cartridge Load (Physical Cart Support)

**Type:** Feature request  
**Status:** Open, not started

Request to support loading from a physical GBA cartridge via the Analogue Pocket's cartridge slot or Dock adapter. This would require significant core additions to handle cartridge bus timing, memory mapper detection, and save write-back for physical media. Dependent on Analogue publishing cartridge adapter documentation or a community reverse-engineering effort.

---

## #9 — Link Cable (Full Serial / Multi-Player)

**Type:** Feature request  
**Status:** Partial (2-player mode merged); full support open

The core currently supports 2-player serial link for multiplayer games. Remaining requested modes include: normal serial accessories (printers, etc.), 3-player and 4-player Multiboot, GameCube Link, GBA Wireless Adapter emulation, and Single Pak download play. Each mode requires separate protocol handling in the core. No timeline; complexity is high.
