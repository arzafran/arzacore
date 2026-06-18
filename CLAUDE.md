# arzacore — agent context

Monorepo of Analogue Pocket FPGA cores (GPL forks), owned and refactored by arzacore.
**No upstreaming** — these are arzacore's to change at will. Credit to upstream is kept.

## Hard toolchain reality (verify before promising builds)
- Cores compile with **Quartus Prime 21.1** (Altera/Intel), target **Cyclone V `5CEBA4F23C8`** (FBGA‑484, speed grade 8).
- **Quartus does not run on macOS.** Never attempt local compiles here. All builds run in **GitHub Actions** via the `raetro/quartus:21.1` Docker image.
- The Pocket loads a **bit-reversed** bitstream (`.rbf` → `.rbf_r`); reverse with `scripts/reverse_bitstream.py` (table-based, stdlib only).
- Bitstreams are gitignored — produced by CI, never committed.

## Cores

| Dir | Builds | Platform id(s) | Upstream | Quartus project | Notes |
|---|---|---|---|---|---|
| `cores/gbc` | `arzacore.GBC`, `arzacore.GB` | `gbc`,`gb` | budude2/openfpga-GBC | `src/ap_core.qpf` | one bitstream → two cores; carries fixes #89/#60/#55/#11 |
| `cores/nes` | `arzacore.NES` | `nes` | agg23/openFPGA-NES | `projects/nes_pocket.qpf` | packaging uses agg23 `pocketpublish`, reads core id from `gateware.json` author |
| `cores/snes` | `arzacore.SNES` | `snes` | agg23/openfpga-snes | `projects/snes_pocket.qpf` | near-capacity; fits with `OPTIMIZATION_TECHNIQUE AREA` (see below) |
| `cores/genesis` | `arzacore.Genesis` | `genesis` | opengateware/openFPGA-Genesis | `src/fpga/ap_core.qpf` | CI was built from scratch (upstream had none); based on upstream PR #34 "it lives"; FX68K has no explicit license |
| `cores/gba` | `arzacore.GBA` | `gba` | mincer-ray/openfpga-GBA | `src/fpga/build/gba_pocket.qpf` | large build; revision `gba_pocket` |

All rebranded: `core.json` `author=arzacore`, folder id `arzacore.<Console>`, `platform_id` kept functional so ROMs/saves resolve.

## Per-core build specifics
- **gbc**: compile `src/ap_core.qpf` (working dir `src/`, pre-flow writes `apf/build_id.v`); reverse to `pkg/gbc/Cores/arzacore.GBC/gbc.rbf_r` and `pkg/gb/Cores/arzacore.GB/gb.rbf_r` (same bitstream).
- **nes**: `quartus_sh --flow compile projects/nes_pocket.qpf`; reverse `projects/output_files/nes_pocket.rbf`; `pocketpublish` builds the staging path as `{author}.{core}` from `gateware.json` — keep its `author` = `arzacore` or packaging breaks.
- **snes**: `quartus_sh -t generate.tcl <type>`. `build_core.sh` builds `main→ntsc`, `pal→pal`, `spc→ntsc_spc` (the upstream `sa1gsu`/`pal_sa1gsu` matrix entries map to undefined types and no-op — dropped). `ntsc`/`pal` bundle CX4+GSU+SA1+DSP and are near device capacity.
- **genesis**: compile `ap_core` (working dir `src/fpga`); reverse to `dist/Cores/arzacore.Genesis/bitstream.rbf_r`.
- **gba**: `generate.tcl` builds revision `gba_pocket`; reverse `src/fpga/build/output_files/ap_core.rbf` → `pkg/Cores/arzacore.GBA/bitstream.rbf_r`.

## SNES fit (solved)
The `ntsc`/`pal` variants bundle CX4+GSU+SA1+DSP and originally failed "can't fit in device"
(Error 11802) under the upstream `OPTIMIZATION_TECHNIQUE SPEED`. Fixed in
`cores/snes/projects/snes_pocket.qsf` by switching to **`OPTIMIZATION_TECHNIQUE AREA`** and
disabling `PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION`/`RETIMING` (both cost area). All three
variants now fit and build green. Keep `NUM_PARALLEL_PROCESSORS 4` (fast). If a future change
pushes it back over capacity, the next levers are a fitter seed sweep or trimming a coprocessor.
Note: upstream agg23's own CI is red here — they ship a locally-built bitstream; the AREA fix is arzacore-specific.

## CI
Root `.github/workflows/build.yml`: detects which `cores/<name>/` changed (dorny/paths-filter) and matrix-builds those via `scripts/build_core.sh <core>` (one dispatcher; per-core compile working dir + reverse target + package). Per-core release on tag `<name>-vX.Y.Z`. `workflow_dispatch` input `core` builds one or `all`.

**SNES timing gate**: The SNES core fails setup timing at the pessimistic Slow/85C corner — this is benign; the hardware runs fine. CI enforces a regression gate (not an absolute pass/fail): `scripts/check_snes_timing.py --check <variant>` compares worst-case Setup and Hold slack against per-variant baselines in `cores/snes/timing_baseline.json` (tolerances: setup ±1.0 ns, hold ±0.15 ns to absorb fitter-seed noise). The JTAG TCK domain (`altera_reserved_tck`) is excluded — it is non-functional during Pocket operation. The gate runs after timing reports are uploaded so reports are always captured even when the gate trips. When a timing change is intentional, rebaseline with `python3 scripts/check_snes_timing.py --write-baseline <variant> <sta.summary>` and commit the updated `timing_baseline.json`.

## Deploy / test on hardware
`scripts/deploy_to_pocket.sh <core-package-dir>` merges onto the Pocket SD (Tools → USB SD Access; mounts as `/Volumes/Analogue`, exFAT). Behavioral tests (trading, audio, video) need eyes on the Pocket — the device exposes no host control. Save bugs are inspectable via the SD card.

## Conventions
- Keep each core's GPL `LICENSE` + upstream credit (README/NOTICE). Refactor freely otherwise.
- Don't commit bitstreams or Quartus scratch (`.gitignore` covers it).
- When unsure a fix is correct, CI compile-verifies synthesis + timing; behavior still needs the Pocket.
