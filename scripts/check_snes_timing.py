#!/usr/bin/env python3
"""SNES timing regression gate for arzacore CI.

Parses a Quartus .sta.summary file, extracts worst-case Setup and Hold slack
across all functional clock domains and timing corners, then compares against
a committed per-variant baseline to detect regressions.

Background:
  The SNES core fails setup timing at the Slow/85C pessimistic corner — this is
  a known-benign condition (the hardware runs fine). This gate is NOT an absolute
  pass/fail; it checks only that timing has not meaningfully WORSENED relative to
  the committed baseline.

JTAG exclusion:
  Any clock whose name contains 'altera_reserved_tck' is excluded. That domain
  is the JTAG TCK pin, non-functional during normal Pocket operation; its timing
  is noisy and waived by convention in FPGA design flows.

Usage:
    python3 scripts/check_snes_timing.py --check <variant> <path/to/snes_pocket.sta.summary>
    python3 scripts/check_snes_timing.py --write-baseline <variant> <path/to/snes_pocket.sta.summary>

    <variant> is one of: main, pal, spc

    --check        Parse, compare to baseline, print table, exit 0 (pass) / 1 (regression).
    --write-baseline  Parse and write/update that variant's entry in timing_baseline.json.
                   Use this after an intentional timing change to rebaseline.
"""
import json
import os
import re
import sys

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

# Resolve baseline relative to repo root (two directories up from scripts/).
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_REPO_ROOT = os.path.dirname(_SCRIPT_DIR)
BASELINE_PATH = os.path.join(_REPO_ROOT, "cores", "snes", "timing_baseline.json")

VALID_VARIANTS = ("main", "pal", "spc")

# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------

# Pattern for each 3-line record in the summary:
#   Type  : <corner> Model <check> '<clock>'
#   Slack : <value>
#   TNS   : <value>
_RECORD_RE = re.compile(
    r"^Type\s+:\s+(.+?)\s+Model\s+(Setup|Hold)\s+'(.+?)'\s*$",
    re.MULTILINE,
)
_SLACK_RE = re.compile(r"^Slack\s*:\s*([+-]?\d+\.\d+)", re.MULTILINE)

# JTAG TCK domain — excluded (non-functional, noisy; standard practice waives it).
_JTAG_MARKER = "altera_reserved_tck"


def parse_sta_summary(path: str) -> dict:
    """Return {'setup': float, 'hold': float} worst slack across all functional clocks/corners.

    Reads all 3-line records from the Quartus .sta.summary file and returns the
    global minimum slack for Setup and Hold checks, excluding the JTAG TCK domain.
    """
    with open(path, "r") as fh:
        text = fh.read()

    # Walk through records: find each "Type" line, then grab the next "Slack" line.
    # We iterate line-by-line keeping state so we can correlate the two.
    worst_setup = float("inf")
    worst_hold = float("inf")

    lines = text.splitlines()
    i = 0
    while i < len(lines):
        m = _RECORD_RE.match(lines[i])
        if m:
            _corner, check_type, clock_name = m.group(1), m.group(2), m.group(3)
            # Skip JTAG TCK domain.
            if _JTAG_MARKER in clock_name:
                i += 1
                continue
            # Look for "Slack :" on the very next non-empty line.
            j = i + 1
            while j < len(lines) and lines[j].strip() == "":
                j += 1
            if j < len(lines):
                sm = _SLACK_RE.match(lines[j])
                if sm:
                    slack = float(sm.group(1))
                    if check_type == "Setup":
                        if slack < worst_setup:
                            worst_setup = slack
                    elif check_type == "Hold":
                        if slack < worst_hold:
                            worst_hold = slack
        i += 1

    if worst_setup == float("inf") or worst_hold == float("inf"):
        raise ValueError(
            f"Could not extract Setup and/or Hold slack from '{path}'. "
            "Check that the file is a valid Quartus .sta.summary."
        )

    return {"setup": round(worst_setup, 3), "hold": round(worst_hold, 3)}


# ---------------------------------------------------------------------------
# Baseline I/O
# ---------------------------------------------------------------------------


def load_baseline() -> dict:
    """Load and return the baseline JSON, or an empty dict if it doesn't exist yet."""
    if not os.path.exists(BASELINE_PATH):
        return {}
    with open(BASELINE_PATH, "r") as fh:
        return json.load(fh)


def save_baseline(data: dict) -> None:
    """Write the baseline JSON with stable formatting."""
    os.makedirs(os.path.dirname(BASELINE_PATH), exist_ok=True)
    with open(BASELINE_PATH, "w") as fh:
        json.dump(data, fh, indent=2, sort_keys=True)
        fh.write("\n")


# ---------------------------------------------------------------------------
# Gate logic
# ---------------------------------------------------------------------------


def check(variant: str, sta_path: str) -> int:
    """Compare parsed timing against baseline. Returns 0 (pass) or 1 (regression)."""
    measured = parse_sta_summary(sta_path)
    baseline = load_baseline()

    if variant not in baseline.get("variants", {}):
        print(
            f"ERROR: variant '{variant}' not found in baseline ({BASELINE_PATH}).\n"
            f"       Run --write-baseline first to establish a baseline.",
            file=sys.stderr,
        )
        return 1

    vb = baseline["variants"][variant]
    tols = baseline.get("tolerances", {"setup": 1.0, "hold": 0.15})
    tol_setup = tols["setup"]
    tol_hold = tols["hold"]

    bl_setup = vb["setup"]
    bl_hold = vb["hold"]

    setup_margin = measured["setup"] - (bl_setup - tol_setup)
    hold_margin = measured["hold"] - (bl_hold - tol_hold)

    setup_pass = setup_margin >= 0
    hold_pass = hold_margin >= 0
    overall = setup_pass and hold_pass

    # Human-readable table.
    status = "PASS" if overall else "FAIL"
    print(f"\nSNES timing regression gate — variant: {variant}")
    print(f"  Baseline source: {BASELINE_PATH}")
    print(f"  Tolerances: setup={tol_setup} ns, hold={tol_hold} ns")
    print()
    print(
        f"  {'Check':<8}  {'Measured':>10}  {'Baseline':>10}  {'Threshold':>11}  {'Margin':>9}  {'Result'}"
    )
    print(f"  {'-'*8}  {'-'*10}  {'-'*10}  {'-'*11}  {'-'*9}  {'-'*6}")

    def row(name, measured_val, baseline_val, tol, margin, passed):
        threshold = baseline_val - tol
        res = "PASS" if passed else "FAIL"
        return (
            f"  {name:<8}  {measured_val:>10.3f}  {baseline_val:>10.3f}"
            f"  {threshold:>11.3f}  {margin:>+9.3f}  {res}"
        )

    print(row("Setup", measured["setup"], bl_setup, tol_setup, setup_margin, setup_pass))
    print(row("Hold", measured["hold"], bl_hold, tol_hold, hold_margin, hold_pass))
    print()
    print(f"  Overall: {status}")

    if not overall:
        print()
        if not setup_pass:
            delta = measured["setup"] - bl_setup
            print(
                f"  REGRESSION: Setup slack regressed by {delta:+.3f} ns "
                f"(measured {measured['setup']:.3f}, baseline {bl_setup:.3f}, "
                f"tolerance {tol_setup:.2f} ns)."
            )
        if not hold_pass:
            delta = measured["hold"] - bl_hold
            print(
                f"  REGRESSION: Hold slack regressed by {delta:+.3f} ns "
                f"(measured {measured['hold']:.3f}, baseline {bl_hold:.3f}, "
                f"tolerance {tol_hold:.2f} ns)."
            )
        print(
            "\n  To rebaseline after an intentional timing change, run:\n"
            f"    python3 scripts/check_snes_timing.py --write-baseline {variant} <sta.summary>"
        )

    print()
    return 0 if overall else 1


def write_baseline(variant: str, sta_path: str) -> int:
    """Parse timing and write/update the variant's entry in the baseline JSON."""
    measured = parse_sta_summary(sta_path)
    data = load_baseline()

    # Preserve existing structure; add/update this variant.
    if "variants" not in data:
        data["variants"] = {}

    data["variants"][variant] = {
        "setup": measured["setup"],
        "hold": measured["hold"],
    }

    # Tolerances block — tunable; only written if not already present so manual
    # edits survive a rebaseline of just one variant.
    if "tolerances" not in data:
        # tol_setup=1.0 ns absorbs typical fitter-seed run-to-run noise on setup.
        # tol_hold=0.15 ns is tighter (hold is deterministic; noise is very small).
        # Increase these values if benign fitter variation trips the gate.
        data["tolerances"] = {"setup": 1.0, "hold": 0.15}

    if "_provenance" not in data:
        data["_provenance"] = (
            "Generated by scripts/check_snes_timing.py --write-baseline. "
            "Source: CI run 27785489710, date 2026-06-18. "
            "Re-run --write-baseline after intentional timing changes."
        )

    save_baseline(data)
    print(
        f"Wrote baseline for variant '{variant}': "
        f"setup={measured['setup']:.3f} ns, hold={measured['hold']:.3f} ns"
    )
    print(f"  -> {BASELINE_PATH}")
    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def usage() -> None:
    print(
        f"Usage:\n"
        f"  {sys.argv[0]} --check <variant> <sta.summary>\n"
        f"  {sys.argv[0]} --write-baseline <variant> <sta.summary>\n"
        f"\n"
        f"<variant> is one of: {', '.join(VALID_VARIANTS)}",
        file=sys.stderr,
    )


def main() -> int:
    args = sys.argv[1:]
    if len(args) != 3 or args[0] not in ("--check", "--write-baseline"):
        usage()
        return 1

    mode, variant, sta_path = args

    if variant not in VALID_VARIANTS:
        print(
            f"ERROR: unknown variant '{variant}'. Must be one of: {', '.join(VALID_VARIANTS)}",
            file=sys.stderr,
        )
        return 1

    if not os.path.isfile(sta_path):
        print(f"ERROR: file not found: {sta_path}", file=sys.stderr)
        return 1

    if mode == "--check":
        return check(variant, sta_path)
    else:
        return write_baseline(variant, sta_path)


if __name__ == "__main__":
    raise SystemExit(main())
