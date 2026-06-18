# Gameboy/Game Boy Color for Analogue Pocket
Ported from the original core developed at https://github.com/MiSTer-devel/Gameboy_MiSTer

Please report any issues encountered to this repo. Issues will be upstreamed as necessary.

## Installation
To install the core, copy the `Assets`, `Cores`, and `Platform` folders over to the root of your SD card. Please note that Finder on macOS automatically _replaces_ folders, rather than merging them like Windows does, so you have to manually merge the folders.

Place the GBC bios in `/Assets/gbc/common` named "gbc_bios.bin", the GB bios in `/Assets/gb/common` named "gb_bios.bin", and the SGB bios in `/Assets/gb/common` named "sgb_boot.bin".


## Usage
ROMs should be placed in `/Assets/gbc/common`, and `/Assets/gb/common`

## Features

### Supported
* Real-Time Clock
* Fastforward
* Original Gameboy display modes
* Super Gameboy Emulation
* Custom Borders (SGB)
* Custom Palettes (SGB)
* Enhance GBA features
* Save States and Sleep
* External Cartridges

### In Progress
¯\\_(ツ)_/¯

## Credits

arzacore-GBC is a rebuild of [budude2/openfpga-GBC](https://github.com/budude2/openfpga-GBC), itself a port of the [Gameboy_MiSTer](https://github.com/MiSTer-devel/Gameboy_MiSTer) core by the MiSTer-devel contributors. Source: https://github.com/arzafran/arzacore-GBC

It ships two cores — `arzacore.GBC` (Game Boy Color) and `arzacore.GB` (Game Boy / Super Game Boy). They install as fresh arzacore cores and do not import saves from the budude2 cores. This build includes fixes for link-cable trading (#89), audio pops (#60), the Wisdom Tree mapper (#55), and fast-forward screen tearing (#11).
