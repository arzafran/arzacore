# Root-Cause Analysis: Issue #89 — Pokemon Trading Broken Since v1.4.0

**Repository:** budude2/openfpga-GBC  
**Issue:** https://github.com/budude2/openfpga-GBC/issues/89  
**Regression introduced:** commit `562fd9b` ("feat: play cartridge support for GB/GBC"), released in v1.4.0  
**Classification:** CONFIG REGRESSION (not an HDL regression)

---

## Summary

The `cartridge_adapter` field in `pkg/gbc/Cores/budude2.GBC/core.json` was changed from `0` to `"0x01000000"` when play-cartridge support was added. This single change altered the Analogue Pocket's cart slot power behavior: the cart slot (and its voltage supply) is now only powered on when the user explicitly selects "Play Cartridge" mode, rather than always being on. The 5V rail from the cart slot is the same supply that powers the link port's level translators for GBC-voltage serial communication. With that supply off during normal SD-ROM operation, the link port level translators are unpowered and serial communication fails — causing the "Friend not ready" error in Pokemon Gold/Silver/Crystal trading.

---

## Root Cause in Detail

### The `cartridge_adapter` bit semantics (from Analogue developer docs)

| Bit | Meaning |
|-----|---------|
| 31  | Leave cart power **off** always |
| 30  | Turn cart power **on** always |
| 24  | Enable "Play Cartridge" option in Asset browser |
| 17  | Enforce strict adapter ID check |
| 16  | Enforce soft adapter ID check |
| 7:0 | Adapter ID code |

The power-on rule when **bit 31 is clear** and **bit 30 is clear**:
> "Turn on cart power **if bit 24 is not set**, or if it is set **AND the user selects the 'Play Cartridge' option**."

### Before v1.4.0 — `cartridge_adapter: 0`

- No bits set → bit 24 is not set → cart power is **always on**, unconditionally.
- The Pocket's PIC32 keeps the cart slot and its voltage rail active at all times.
- The voltage rail (switchable 3.3V/5V mechanically per `apf_top.v:52–54` and `core_top.sv:19–20`) is live, so the link port level translators have power.
- GBC-speed serial trading works at both 3.3V and 5V, but the level translators must be powered.

### After v1.4.0 — `cartridge_adapter: "0x01000000"` (bit 24 set, bits 30/31 clear)

- Bit 24 set, bit 30 clear → cart power turns on **only** when user explicitly selects "Play Cartridge" in the Asset browser.
- In the normal SD-ROM boot path (the vast majority of usage), cart power stays **OFF**.
- The link port level translators share the same cart-slot voltage supply. With that supply off, the translators are un-biased and the SI/SO/SCK signals cannot be driven or received at the correct logic level.
- Serial transfers initiated by the GBC CPU go nowhere; the remote device sees no valid clock/data, producing the "Friend not ready" / link timeout symptom.

### HDL path — confirmed unchanged

The HDL serial path in `core_top.sv` is **not** responsible for this regression:

```
// core_top.sv lines 957–969
wire sc_int_clock_out, ser_clk_out, ser_clk_in;

always_comb begin
  port_tran_so_dir  = 1'b1;           // SO always driven as output
  port_tran_si_dir  = 1'b0;           // SI always input
  ser_clk_in        = port_tran_sck;  // SCK always read
  port_tran_sck_dir = sc_int_clock_out; // SCK driven when we are master

  if (sc_int_clock_out) begin
    port_tran_sck = ser_clk_out;
  end else begin
    port_tran_sck = 1'bZ;
  end
end
```

The FPGA correctly drives `port_tran_so` (line 1032) and reads `port_tran_si` (line 1030). The `link.v` module (lines 93–130) correctly handles both internal-clock (master) and external-clock (slave) modes. There is no muxing of link signals with cartridge signals. The physical link port pins are entirely separate from the cart bus pins.

The `cart_physical_mode` flag (line 512, derived from `osnotify_adapter_play`) gates only the cart bus (`cart_tran_bank0`–`bank3`, lines 782–796), never the link port signals.

### The mechanical voltage switch (physical hardware context)

The Analogue Pocket's cart slot uses a PIC32-controlled mechanical switch that selects between 3.3V (GBA default) and 5V (GBC mode) — as documented in comments at `apf_top.v:52–54` and `core_top.sv:19–20`:

```
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32
```

When `cartridge_adapter: 0` kept cart power always on, the Pocket's firmware would also power and bias the level translators on the link port (they share the 5V supply). A physical GBC cartridge further enables the full 5V level — but even the 3.3V state with cart power on is sufficient for GBA-link-cable-level (3.3V) trading. The root issue is that with `0x01000000`, the supply is off entirely in SD-ROM mode, collapsing link port signal levels to indeterminate/floating.

---

## Evidence

| Evidence | Location |
|----------|----------|
| `cartridge_adapter` changed from `0` to `"0x01000000"` | commit `562fd9b`, `pkg/gbc/Cores/budude2.GBC/core.json:23` |
| Same change in GB core | commit `562fd9b`, `pkg/gb/Cores/budude2.GB/core.json:23` |
| Bit 24 semantics: power only on if user selects Play Cartridge | Analogue developer docs, hardware section |
| Value `0` semantics: cart power always on (bit 24 not set) | Analogue developer docs, hardware section |
| HDL link signals not gated by `cart_physical_mode` | `core_top.sv:957–969`, `core_top.sv:1027–1032` |
| `cart_physical_mode` only gates cart bus bank signals | `core_top.sv:782–796`, `core_top.sv:720–728` |
| Mechanical voltage switch comment | `apf_top.v:52–54`, `core_top.sv:19–20` |
| `osnotify_adapter_play` → `cart_physical_mode` path | `core_bridge_cmd.v:455–458`, `core_top.sv:512` |

---

## Proposed Fix

### Option A — Preferred: set bit 30 ("always on") alongside bit 24

Change `pkg/gbc/Cores/budude2.GBC/core.json` line 23 and `pkg/gb/Cores/budude2.GB/core.json` line 23:

```diff
-        "cartridge_adapter": "0x01000000"
+        "cartridge_adapter": "0x41000000"
```

`0x41000000` = bit 30 (cart power always on) + bit 24 (Play Cartridge option enabled).

**Effect:** The cart slot voltage supply stays on at all times — restoring pre-1.4.0 behavior for link port level translators — while the Play Cartridge option in the Asset browser remains available. Physical cartridge users retain full functionality. SD-ROM users get working link-cable trading again.

**Trade-off:** "Cart power always on" draws a small but nonzero amount of current from the cart slot supply rail even with no cartridge inserted. This was the state before v1.4.0 (since `0` also kept power on), so this restores the original power profile rather than introducing a new cost. The pre-1.4.0 core was shipping this behavior for the entire product's lifespan before the regression.

### Option B — Minimal rollback: revert to `0` (no physical cart support)

```diff
-        "cartridge_adapter": "0x01000000"
+        "cartridge_adapter": 0
```

This restores exact pre-1.4.0 behavior including always-on cart power, but **disables the Play Cartridge option** (removes bit 24). Not recommended if physical cartridge support is a desired feature.

---

## Related Issues Likely Caused by the Same Root Cause

- **Issue #84** (Mole Mania multiplayer not working): Same link port serial failure mechanism — external-clock slave mode also requires powered level translators.
- **Issue #88** (SGB colorization with physical cartridge): When the user explicitly uses Play Cartridge mode, `cart_physical_mode` is true and the cart power is on — so this may have a different cause (voltage level timing, SGB boot sequence), but the power regression could be a contributing factor depending on when power comes up relative to SGB detection.

---

## What Was NOT the Cause

- No HDL changes to `link.v` were made in commit `562fd9b` or surrounding commits.
- No muxing of link port pins with cart bus pins was introduced.
- The `serial_data_in`/`serial_data_out`/`serial_clk_in`/`serial_clk_out` signals are routed correctly to `port_tran_si`, `port_tran_so`, `port_tran_sck` throughout all versions.
- The issue is purely in the APF OS-level behavior triggered by the JSON config value, not in synthesized logic.
