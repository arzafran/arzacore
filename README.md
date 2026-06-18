# arzacore

Analogue Pocket FPGA cores, forked and maintained by arzacore. Each core under
[`cores/`](cores/) is a GPL fork of an upstream openFPGA core, rebuilt with a
shared CI pipeline and packaged as `arzacore.*` cores.

These are **independent forks**: arzacore owns and refactors them going forward.
Credit to the upstream authors is preserved per core (see each `cores/<name>/`
and [`NOTICE`](NOTICE)).

## Cores

| Core | Folder | Platform | Upstream | License |
|---|---|---|---|---|
| Game Boy Color + Game Boy | [`cores/gbc`](cores/gbc) | `gbc`, `gb` | budude2/openfpga-GBC → Gameboy_MiSTer | GPL |
| NES | [`cores/nes`](cores/nes) | `nes` | agg23/openFPGA-NES → NES_MiSTer | GPL‑3.0 |
| SNES | [`cores/snes`](cores/snes) | `snes` | agg23/openfpga-snes → SNES_MiSTer | GPL‑3.0 |
| Genesis | [`cores/genesis`](cores/genesis) | `genesis` | opengateware/openFPGA-Genesis → fpgagen | GPL‑3.0 |
| GBA | [`cores/gba`](cores/gba) | `gba` | mincer-ray/openfpga-GBA → GBA_MiSTer | GPL‑2.0 |

`cores/gbc` builds **two** Pocket cores (`arzacore.GBC` and `arzacore.GB`) from one bitstream.

## Building

All cores compile with Intel/Altera **Quartus Prime 21.1** (Cyclone V `5CEBA4F23C8`).
Quartus does not run on macOS — builds happen in **GitHub Actions** via the
`raetro/quartus:21.1` Docker image. CI compiles each core, bit-reverses the
`.rbf` into the Pocket `.rbf_r`, and publishes a per-core release zip.

- Push changes under `cores/<name>/` → CI builds only that core.
- Tag `<name>-vX.Y.Z` → CI publishes a release for that core.

Bitstreams are **not** committed (see `.gitignore`); they are produced by CI.

## Installing on the Pocket

Download a core's release zip and merge its `Assets`/`Cores`/`Platforms` onto your
SD card, or use [`scripts/deploy_to_pocket.sh`](scripts/deploy_to_pocket.sh) while
the Pocket is in **Tools → USB SD Access** mode.

## License

Each core retains its upstream GPL license (see `cores/<name>/LICENSE`). As GPL
forks that distribute builds, this repository is public and preserves source +
attribution. See [`NOTICE`](NOTICE) for the per-core credit chain.
