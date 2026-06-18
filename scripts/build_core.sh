#!/usr/bin/env bash
# Compile one core in the raetro/quartus:21.1 Docker image, bit-reverse its
# bitstream, and package its Pocket core zip(s) into cores/<core>/_dist/.
# Usage: scripts/build_core.sh <gbc|nes|snes|genesis|gba> [version]
set -euo pipefail

CORE="${1:?core required}"
VER="${2:-dev}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
IMG=raetro/quartus:21.1

# compile <docker-workdir> <quartus args...>
compile() { local wd="$1"; shift; docker run --rm -v "$ROOT:/build" -w "/build/$wd" "$IMG" "$@"; }
# rev <in.rbf> <out>
rev() { test -f "$1" || { echo "::error::missing bitstream $1"; exit 1; }; python3 scripts/reverse_bitstream.py "$1" "$2"; }
# pack <package-root-dir> <zip-basename>
pack() { mkdir -p "cores/$CORE/_dist"; ( cd "$1" && zip -qr "$ROOT/cores/$CORE/_dist/${2}_${VER}.zip" Assets Cores Platforms ); }

case "$CORE" in
  gbc)
    compile cores/gbc/src quartus_sh --flow compile ap_core.qpf
    rev cores/gbc/src/output_files/ap_core.rbf cores/gbc/pkg/gbc/Cores/arzacore.GBC/gbc.rbf_r
    rev cores/gbc/src/output_files/ap_core.rbf cores/gbc/pkg/gb/Cores/arzacore.GB/gb.rbf_r
    pack cores/gbc/pkg/gbc arzacore.GBC
    pack cores/gbc/pkg/gb  arzacore.GB
    ;;
  nes)
    compile cores/nes quartus_sh --flow compile projects/nes_pocket.qpf
    rev cores/nes/projects/output_files/nes_pocket.rbf cores/nes/pkg/pocket/Cores/arzacore.NES/nes.rev
    pack cores/nes/pkg/pocket arzacore.NES
    ;;
  snes)
    # main/pal bundle CX4+GSU+SA1+DSP and currently overflow the device (see CLAUDE.md).
    for pair in "main ntsc" "pal pal" "spc ntsc_spc"; do
      set -- $pair
      compile cores/snes quartus_sh -t generate.tcl "$2"
      rev cores/snes/projects/output_files/snes_pocket.rbf "cores/snes/pkg/Cores/arzacore.SNES/snes_${1}.rev"
    done
    pack cores/snes/pkg arzacore.SNES
    ;;
  genesis)
    compile cores/genesis/src/fpga quartus_sh --flow compile ap_core
    rev cores/genesis/src/fpga/output_files/ap_core.rbf cores/genesis/dist/Cores/arzacore.Genesis/bitstream.rbf_r
    pack cores/genesis/dist arzacore.Genesis
    ;;
  gba)
    compile cores/gba quartus_sh -t generate.tcl
    rev cores/gba/src/fpga/build/output_files/ap_core.rbf cores/gba/pkg/Cores/arzacore.GBA/bitstream.rbf_r
    pack cores/gba/pkg arzacore.GBA
    ;;
  *) echo "::error::unknown core '$CORE'"; exit 1 ;;
esac

echo "=== built $CORE ==="
ls -la "cores/$CORE/_dist/"
