#!/usr/bin/env bash
# Deploy built GB/GBC cores onto a connected Analogue Pocket SD card.
#
# The Pocket exposes no host control API — it only mounts its microSD as USB
# mass storage (on the Pocket: Tools -> "USB SD Access"). This script merges the
# core folders onto that card WITHOUT clobbering your existing Assets/Saves
# (macOS Finder *replaces* same-named folders; rsync merges them).
#
# Usage:
#   scripts/deploy_to_pocket.sh <source> [sd_volume]
#     <source>    a dir containing gbc/ and gb/ package folders (e.g. ./pkg),
#                 OR a dir that itself contains Assets/ Cores/ Platforms/,
#                 OR one or more core .zip files (pass the dir holding them).
#     [sd_volume] path to the mounted SD (default: auto-detect under /Volumes)
#
# Examples:
#   scripts/deploy_to_pocket.sh ./pkg
#   scripts/deploy_to_pocket.sh /tmp/gbc-rom/cores /Volumes/POCKET
set -euo pipefail

SRC="${1:?source dir required}"
SD="${2:-}"

die() { echo "error: $*" >&2; exit 1; }

# --- locate the SD card -------------------------------------------------------
detect_sd() {
  for v in /Volumes/*; do
    [ -d "$v" ] || continue
    case "$v" in */Macintosh\ HD) continue;; esac
    # A Pocket card has these top-level dirs.
    if [ -d "$v/Cores" ] && [ -d "$v/Assets" ] && [ -d "$v/Platforms" ]; then
      echo "$v"; return 0
    fi
  done
  return 1
}
if [ -z "$SD" ]; then
  SD="$(detect_sd)" || die "no Pocket SD found under /Volumes. On the Pocket: Tools -> USB SD Access, then retry (or pass the volume path)."
fi
[ -d "$SD/Cores" ] || die "$SD does not look like a Pocket SD (no Cores/ dir)."
echo "Pocket SD: $SD"

# --- stage the source into a temp tree with Assets/Cores/Platforms ------------
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

stage_pkg_dir() {  # a dir with Assets/ Cores/ Platforms/
  rsync -a "$1"/Assets "$1"/Cores "$1"/Platforms "$STAGE"/ 2>/dev/null || true
}

shopt -s nullglob
if [ -d "$SRC/gbc" ] || [ -d "$SRC/gb" ]; then
  for sub in "$SRC"/gbc "$SRC"/gb; do [ -d "$sub" ] && stage_pkg_dir "$sub"; done
elif [ -d "$SRC/Cores" ]; then
  stage_pkg_dir "$SRC"
else
  zips=("$SRC"/*.zip)
  [ ${#zips[@]} -gt 0 ] || die "no gbc/gb dirs, no Assets/Cores/Platforms, and no .zip files under $SRC"
  for z in "${zips[@]}"; do echo "unzip $z"; unzip -o -q "$z" -d "$STAGE"; done
fi

[ -d "$STAGE/Cores" ] || die "nothing staged — check the source layout."

# --- guard: refuse to deploy a package with no bitstream ----------------------
if ! find "$STAGE/Cores" -name '*.rbf_r' -size +0c | grep -q .; then
  die "staged Cores/ has no non-empty .rbf_r — you probably staged the git repo (bitstream is gitignored). Use a CI artifact or local build output."
fi

echo "=== will merge onto $SD ==="
find "$STAGE" -maxdepth 3 -name '*.rbf_r' -exec ls -la {} \;

# --- merge (NOT replace) ------------------------------------------------------
# -rt (no perms/owner/symlinks): exFAT can't store those, and macOS ships an
# old rsync without --info. Recursive + mtimes is all the card needs.
rsync -rt --stats "$STAGE"/Assets "$STAGE"/Cores "$STAGE"/Platforms "$SD"/
sync

echo "=== deployed bitstreams on card ==="
find "$SD/Cores" -name '*.rbf_r' -newermt '-2 minutes' -exec ls -la {} \; 2>/dev/null || \
  find "$SD/Cores" -name '*.rbf_r' -exec ls -la {} \;

# --- eject so it's safe to unplug --------------------------------------------
diskutil eject "$SD" >/dev/null 2>&1 && echo "ejected $SD — safe to unplug." \
  || echo "deployed; eject manually before unplugging."
