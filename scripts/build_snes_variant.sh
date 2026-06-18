#!/usr/bin/env bash
# Compile ONE SNES variant and bit-reverse it to its .rev. Used by CI to build
# the three variants in parallel; scripts/build_core.sh snes still builds all
# three sequentially for local use.
# Usage: scripts/build_snes_variant.sh <main|pal|spc> [version]
set -euo pipefail

VARIANT="${1:?variant required: main | pal | spc}"
VER="${2:-dev}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
IMG="${QUARTUS_IMAGE:-raetro/quartus:21.1}"

case "$VARIANT" in
  main) BT=ntsc ;;
  pal)  BT=pal ;;
  spc)  BT=ntsc_spc ;;
  *) echo "::error::unknown SNES variant '$VARIANT' (expected main|pal|spc)"; exit 1 ;;
esac

docker run --rm -v "$ROOT:/build" -w /build/cores/snes "$IMG" quartus_sh -t generate.tcl "$BT"
test -f cores/snes/projects/output_files/snes_pocket.rbf || { echo "::error::snes_pocket.rbf not generated for $VARIANT"; exit 1; }

OUT="cores/snes/pkg/Cores/arzacore.SNES/snes_${VARIANT}.rev"
mkdir -p "$(dirname "$OUT")"
python3 scripts/reverse_bitstream.py cores/snes/projects/output_files/snes_pocket.rbf "$OUT"
echo "=== built SNES $VARIANT ($VER) ==="
ls -la "$OUT"
