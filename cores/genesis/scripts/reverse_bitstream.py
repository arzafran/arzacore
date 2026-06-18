#!/usr/bin/env python3
"""
reverse_bitstream.py  —  reverse the bit order in each byte of an RBF file.

Analogue Pocket requires the bitstream in reversed-bit form (.rbf_r).
This replaces the Windows-only reverse_bits.exe used in the original build.

Usage:
    python3 reverse_bitstream.py <input.rbf> <output.rbf_r>
"""

import sys


def reverse_bits_in_byte(b: int) -> int:
    result = 0
    for _ in range(8):
        result = (result << 1) | (b & 1)
        b >>= 1
    return result


# Pre-compute a look-up table for speed
REVERSE_TABLE = bytes(reverse_bits_in_byte(i) for i in range(256))


def reverse_bitstream(input_path: str, output_path: str) -> None:
    with open(input_path, "rb") as f:
        data = f.read()

    reversed_data = data.translate(REVERSE_TABLE)

    with open(output_path, "wb") as f:
        f.write(reversed_data)

    print(
        f"Reversed {len(data):,} bytes: {input_path} -> {output_path}"
    )


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.rbf> <output.rbf_r>", file=sys.stderr)
        sys.exit(1)
    reverse_bitstream(sys.argv[1], sys.argv[2])
