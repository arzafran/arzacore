# arzacore-Genesis

A Sega Genesis / Mega Drive core for the Analogue Pocket, built from the
**ericlewis/openfpga-genesis** fork (opengateware/openFPGA-Genesis).

This build includes all fixes from upstream PR #34 ("it lives") which resolves
seven+ known bugs. CI compiles and releases automatically on every push to
`main`.

## Install

Copy the contents of `dist/` to the root of your Pocket's SD card.
The core will appear under **Cores > arzacore.Genesis**.

## Credits

arzacore-Genesis is a rebuild of ericlewis/openfpga-genesis
(opengateware/openFPGA-Genesis), a Pocket port of fpgagen/Genesis_MiSTer.

- **Upstream core**: Eric Lewis (ericlewis)
- **FM synthesis (jt12, jt89)**: Jose Tejada (Jotego) — GPL-3.0
- **FX68K M68000 soft-core**: Jorge Cwik — no explicit license; included per
  community-distribution norm (widely used in MiSTer and Pocket cores)
- **fpgagen base**: Torlus (Gregory Estrade) — BSD
- **MiSTer improvements**: sorgelig, srg320, MiSTer-devel contributors
- **APF glue / data-table**: agg23
- **Composite mode**: Kitrinx
- Thanks to tpwrules for timing research

Licensed **GPL-3.0**. Source: https://github.com/arzafran/arzacore-Genesis

> **Note on FX68K**: Jorge Cwik's FX68K does not carry an explicit open-source
> license in this repository. It is included here following the community norm
> for Pocket/MiSTer cores; if you redistribute, check upstream for any updated
> license terms.

## Building from source

The GitHub Actions workflow (`.github/workflows/build.yml`) builds this core
automatically. It uses the `raetro/quartus:21.1` Docker image.

To install a fresh build, copy `dist/` to your Pocket SD card. The core folder
is named `arzacore.Genesis` — it will not conflict with an existing
`ericlewis.Genesis` install.
