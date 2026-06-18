# openfpga-GBC Issue Triage

**Generated:** 2026-06-18  
**Repo:** budude2/openfpga-GBC (v1.4.0, core.json dated 2026-04-12)  
**Open issues triaged:** 32

---

## Summary Table

| # | Title (short) | Type | Status | Root-cause file(s) | Fixability | Action |
|---|---|---|---|---|---|---|
| 4 | Cartridge peripheral support | Feature | Still relevant | `src/gb/mappers/gb_camera.v`, `src/gb/mappers/mbc7.v`, `core_top.sv` | Needs-new-feature-HDL | Track upstream MiSTer camera support; rumble already wired |
| 11 | Screen tear after fast-forward | Bug | Still relevant | `src/gb/speedcontrol.vhd`, `src/gb/lcd.v` | Needs-hardware-test | Add vbuffer ptr reset on FF exit / investigate FASTFORWARDEND sync |
| 13 | Adjustable fast-forward speed | Feature | Still relevant | `src/gb/speedcontrol.vhd`, `interact.json` | Needs-new-feature-HDL | Add speed-select interact var + parameterize speedcontrol |
| 21 | Screen tearing (general) | Bug | Still relevant (same root as #11/#75) | `src/gb/lcd.v`, `src/gb/speedcontrol.vhd` | Needs-hardware-test | Investigate lcd vbuffer write-pointer desync |
| 25 | Severe flickering in fast-forward docked | Bug | Still relevant | `src/gb/speedcontrol.vhd`, `src/core/core_top.sv` (vblank path) | Needs-hardware-test | Dock vblank signal interacts with `sdram_autorefresh`; needs analysis |
| 31 | Audio buzz in Final Fantasy Adventure | Bug | Partially addressed (`No Audio Pops` option added) | `src/gb/gbc_snd.vhd` | Needs-hardware-test | Issue predates `audio_no_pops` flag; test if flag resolves it |
| 36 | Power Antenna LED stays on | Bug | Still relevant | `src/gb/link.v` (sc_start always active), `core_top.sv:960` | Fixable-by-source-edit | Drive `port_tran_so_dir=0` / hold serial pins Hi-Z when no transfer |
| 44 | Picross 2 visual artifacts | Bug | Still relevant | `src/gb/lcd.v`, possibly `src/gb/mappers/mbc1.v` | Needs-hardware-test | Likely timing/PPU edge case; needs save + ROM version info |
| 46 | GB Kiss / HuC IR support | Feature | Still relevant | `src/gb/mappers/huc1.v` (ir_en stub), `core_top.sv:224-225` | Needs-new-feature-HDL | IR hardware exists on Pocket; need to wire `port_ir_rx/tx` into huc1 |
| 49 | Oracle of Seasons/Ages audio distortion | Bug | Still relevant (known GB audio accuracy issue) | `src/gb/gbc_snd.vhd` | Needs-hardware-test | Upstream MiSTer issue; evaluate if DC blocker or LPF helps |
| 51 | Pokemon Red save corruption | Bug | Still relevant | `src/gb/save_handler.sv`, `src/gb/mappers/mbc1.v` | Needs-hardware-test | 30 KB file but MBC1 save is 8 KB; suspect partial-write or CRAM corruption |
| 52 | Color flash in Pokemon Blue battles (SGB) | Bug | Still relevant | `src/gb/sgb.v` / `src/core/core_top.sv:1165` | Needs-hardware-test | SGB palette packet glitch during battle transition; rare race |
| 55 | Wisdom Tree mapper expose via interact | Feature | Config-only / Already implemented | `src/gb/mappers/misc.v`, `src/gb/cart.v:242`, `interact.json` | Config-only | Add mapper_sel interact dropdown (mapper_sel hardcoded to 0 in core_top) |
| 58 | WRAM monitoring / UART debug output | Feature | Stale/won't-fix | `core_top.sv:266` (dbg_tx tied Z) | Not-a-code-issue | Out-of-scope platform debugging feature; suggest CheatEngine-style save export |
| 59 | Hotswap / coldswap game at runtime | Feature | Stale/won't-fix | APF framework limitation | Not-a-code-issue | APF doesn't support ROM hotswap without core reset |
| 60 | Audio pop after each sound (Pokemon Crystal) | Bug | Still relevant | `src/gb/gbc_snd.vhd` | Fixable-by-source-edit | `No Audio Pops` interact flag exists but defaults OFF; change default or document |
| 62 | Include .gbp palette + .sgb border assets | Feature | Config-only | `pkg/*/Cores/budude2.*/` JSON + Assets | Config-only | Copy assets from MiSTer GB repo into pkg/ tree; no HDL change |
| 63 | SGB BIOS lost after sleep/wake | Bug | Still relevant | `core_top.sv:483-488` (boot_settings reset on wake), `interact.json` | Fixable-by-source-edit | boot_settings triggers core reset on every write; SGB BIOS re-load needed |
| 67 | Turbo button | Feature | Still relevant | `core_top.sv:1145-1148` (joystick mapping) | Needs-new-feature-HDL | Add turbo-fire logic in joystick decode block |
| 68 | IR communication (Card Pop, TCG) | Feature | Still relevant | `core_top.sv:224-225` (IR disabled), `src/gb/mappers/huc1.v` | Needs-new-feature-HDL | Same as #46; IR hardware is physically present, wire needed |
| 70 | Custom palette not saving | Bug | Still relevant | `interact.json` (`persist:true` set, but palette slot is dataslot) | Needs-hardware-test | palette stored as dataslot file, not interact persist; save path may be missing |
| 74 | Up always held in docked mode | Bug | Still relevant | `core_top.sv:512` (synch_3 for cont1_key), `core_top.sv:1145` | Needs-hardware-test | Dock controller input sync; likely noise on dpad_up bit[0] from dock hardware |
| 75 | Fast-forward tearing + docked glitches | Bug | Still relevant (duplicate cluster of #11/#21/#25) | `src/gb/speedcontrol.vhd`, `src/gb/lcd.v` | Needs-hardware-test | See #11/#21/#25 |
| 76 | Timing constraints fail in v1.3.2 | Bug | Likely already fixed (v1.4.0 shipped) | `src/core/core_constraints.sdc` | Fixable-by-source-edit | Re-verify in v1.4.0; if still present, tighten SDC or add false paths |
| 77 | GBA RTC support (wrong repo) | Question | Stale/won't-fix | N/A | Not-a-code-issue | Wrong repo; refers to a separate GBA core project |
| 78 | Save file has extra 0.1 KB (RTC bytes) | Bug/Question | Config-only | `src/gb/save_handler.sv:103-109` (RTC_inuse appends 16 bytes) | Config-only | Document format: save_handler appends 16 bytes of RTC when `RTC_inuse`; strip in transfer tool |
| 79 | Screen filters differ from official Analogue | Question | Not-a-code-issue | `pkg/*/Cores/*/video.json` | Not-a-code-issue | Independent design choices for video.json scaler filters; no bug |
| 84 | Mole Mania multiplayer link fails | Bug | Still relevant | `src/gb/link.v`, `core_top.sv:959-969` | Needs-hardware-test | Two-Pocket link protocol issue; compare with spiritualized1997 link impl |
| 86 | Sleep/wake + save state crash from cartridge | Bug | Still relevant (v1.4.0 regression) | `core_top.sv:512` (`cart_physical_mode`), `core_top.sv:951` (reset wire) | Needs-hardware-test | `osnotify_adapter_play` → `cart_physical_mode` may lose state on sleep/wake |
| 87 | GeNiUs GB Backup Station black-bar logo | Bug | Likely stale/niche HW | `src/gb/cart.v` (header check), `src/gb/mappers/misc.v` | Needs-hardware-test | Non-standard cartridge; likely fails header/logo check that real DMG ignores |
| 88 | SGB colorization doesn't work from cartridge | Bug | Still relevant (v1.4.0) | `core_top.sv:983` (`isSGB`), `core_top.sv:1165` (`sgb_en`), dataslot ID 6 | Needs-hardware-test | Physical cart mode may not load SGB BIOS (dataslot 6 path); `cart_physical_mode` and SGB not jointly handled |
| 89 | Pokemon trading broken in v1.4.0 vs v1.3.3 | Bug | Still relevant (v1.4.0 regression) | `core_top.sv:959-969` (serial port dir logic), `core_top.sv:512` (cart_physical_mode) | Needs-hardware-test | v1.4.0 physical cart feature may affect link voltage / SO direction when cart present |

---

## Cross-Cutting Issue Groups

### Group A — Fast-Forward / Screen Tearing (#11, #21, #25, #75)

All four issues describe the same class of defect: visual desynchronization triggered by fast-forward, with a distinct dock-specific variant. The `speedcontrol.vhd` state machine (`FASTFORWARD` → `FASTFORWARDEND` transition, lines 100-128) drives the CPU clock enable at a different rate than the LCD pixel clock. The `lcd.v` write-pointer (`vbuffer_inptr`) is incremented on `pix_wr` which depends on `lcd_clkena` and `lcd_freeze`; if FF is exited mid-frame the pointer can be left at a non-zero offset for the next frame. In docked mode, the external `vblank` input (driven by the dock) can further desync the scan. The `sdram_autorefresh = !ff_on` line in `core_top.sv:737` also affects SDRAM timing during FF.

**Recommended fix direction:** Reset `vbuffer_inptr` to 0 at the start of every VSync (`lcd_vs`) unconditionally, not only on the `lcd_off` edge. This is a single-line change in `lcd.v` around line 73.

### Group B — Audio (#31, #49, #60)

- **#60 (audio pops)**: The `remove_pops` / `audio_no_pops` feature is already implemented in `gbc_snd.vhd` (lines 1648-1692) and exposed as the "No Audio Pops" interact checkbox (`interact.json` id 1006). The interact default is `0x00000000` (OFF). Simply changing the `defaultval` to `"0x00000080"` would make this the default, resolving #60 for most users.
- **#31 (FF Adventure buzz)**: The `remove_pops` flag inverts the DAC and changes mixer behavior; it is a trade-off (less accurate but fewer pops). The FF-specific buzzing is likely the same phenomenon. The existing flag should help; needs hardware confirmation.
- **#49 (Oracle audio)**: Known upstream accuracy issue. The DC blocker (`src/gb/audio/filters/dc_blocker.sv`) and IIR filter chain are in place but coefficients may need tuning for these games.

### Group C — Save Files / Persistence (#51, #52, #70, #78)

- **#78 (extra save bytes)**: Documented behaviour. `save_handler.sv:103-109` shows `datatable_data = save_size_bytes + 16` when `RTC_inuse`. The 16 extra bytes are 5 RTC words (timestamp + saved-time). This is correct design; users need a conversion tool, not a code change.
- **#70 (palette not saving)**: The interact entry for Custom Palette (`id 1002`) has `persist: true`. The `palette` register in `core_top.sv:934` is loaded from a dataslot (id 3), not from interact persist. If no `.gbp` file is loaded the register stays at the compile-time default. The interaction between `persist` and the dataslot-loaded palette needs verification.
- **#51 (Pokemon Red corruption)**: MBC1 with 8 KB SRAM; the 30 KB file the user saw suggests partial SDRAM write during a reset event. No code change can be made without the corrupted save file and reproduction steps.

### Group D — Link Cable / Serial (#36, #84, #89)

- **#36 (Power Antenna LED)**: `core_top.sv:960` sets `port_tran_so_dir = 1'b1` unconditionally. This drives SO high regardless of whether a transfer is in progress, activating the antenna LED on any GB-bus-sniffing accessory. Fix: drive `port_tran_so_dir = sc_int_clock_out` (only output when in master mode), matching `port_tran_sck_dir`.
- **#84 (Mole Mania)**: Two-Pocket link. The external-clock path in `link.v:113-129` has a subtle counter bug: `serial_counter` decrements on the falling edge (line 119) and the IRQ fires when `serial_counter == 0` (line 122) on the rising edge — but the `8 to 0` count gives 9 bits, not 8. This is a known MiSTer issue. Needs comparison against reference impl.
- **#89 (trading broken v1.4.0)**: Physical cart feature introduced in v1.4.0 sets `cart_physical_mode` via `osnotify_adapter_play`. The link serial pins use `port_tran_so_dir = 1'b1` always; when physical cart is inserted the Pocket switches the link port to 5V mode. But `backend_cart_rd/wr` paths gate on `~cart_physical_mode`, potentially interfering with the ROM backend while still doing link operations. Most likely the voltage level change from the cart presence changed link behaviour.

### Group E — Physical Cartridge / v1.4.0 Regressions (#86, #88, #89)

All three opened after v1.4.0 (2026-04-12) which introduced physical cartridge support. The `osnotify_adapter_play` → `cart_physical_mode` signal path (`core_top.sv:512`) is the common thread. #86 (sleep/wake crash) and #88 (SGB from cartridge) may share a root cause: the boot_settings reset sequence (`core_top.sv:485`) reloads with the written values but the physical cart state may interact with `isGBC` detection from the physical cart header vs. the saved boot_settings.

### Group F — IR Communication (#46, #68)

Both request HuC-1/HuC-3 IR and general GBC IR over the Pocket's hardware IR port. The hardware is present and pinned (`ap_core.qsf` lines 192-193). `core_top.sv:224-225` unconditionally disables it (`port_ir_tx = 0`, `port_ir_rx_disable = 1`). `huc1.v:96` already stubs `cram_do = 8'hC0` (no light) when `ir_en=1`. The fix requires: (1) un-stub port_ir in core_top, (2) connect `port_ir_rx` to the HuC-1 cram_do path, (3) route `ir_en` out of huc1 to core_top so the Pocket IR LED lights only when needed.

---

## Per-Issue Detail

### #4 — Cartridge Peripheral Support (rumble, camera, accelerometer)

**Type:** Feature request  
**Status:** Partially implemented (rumble exists); camera/accelerometer not implemented  
**Root cause:** `src/gb/mappers/gb_camera.v` exists but camera pixel sensor I/O is a stub returning dummy data. `src/gb/mappers/mbc7.v` handles the accelerometer mapper but the `joystick_analog_0` input is tied to `0` in `core_top.sv:888`. Rumble is fully wired via `rumbler` module and `rumble_en` flag.  
**Fixability:** Needs-new-feature-HDL (camera requires significant sensor simulation or real sensor wiring)  
**Action:** Acknowledge partial completion (rumble); camera simulation is complex and unlikely without upstream MiSTer support. Analog input for MBC7 could be connected to Pocket accelerometer if APF exposes it.

---

### #11 — Screen Tearing After Fast-Forward

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** `src/gb/speedcontrol.vhd:122-128` (`FASTFORWARDEND` state adds 15-cycle delay before returning to NORMAL) may leave the lcd write pointer misaligned. `lcd.v:69` increments `vbuffer_inptr` on every `pix_wr`; no reset occurs on FF exit.  
**Fixability:** Fixable-by-source-edit (but requires hardware test to confirm fix)  
**Action:** Add `vbuffer_inptr <= 0` in `lcd.v` on every rising edge of `lcd_vsync` (not only `lcd_off`).

---

### #13 — Adjustable Fast-Forward Speed

**Type:** Feature request  
**Status:** Still relevant  
**Root cause:** `speedcontrol.vhd` has no speed multiplier; it runs the CPU at maximum (every other cycle = ~2×). A real N× multiplier would require parameterising the `clkdiv` counter.  
**Fixability:** Needs-new-feature-HDL  
**Action:** Add a `ff_speed[1:0]` interact variable; in `speedcontrol.vhd` parameterize the inner clkdiv period for FASTFORWARD state.

---

### #21 — Screen Tearing (General)

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** Same as #11. Users also report it without FF, suggesting the vbuffer write-pointer can slip over time on vblank timing drift.  
**Fixability:** Needs-hardware-test  
**Action:** Consolidate with #11 investigation.

---

### #25 — Severe Flickering in Fast-Forward Docked

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** In docked mode the `vblank` input (hardware dock signal, `core_top.sv:125`) may be driven independently from the GB LCD vsync. `sdram_autorefresh = !ff_on` (`core_top.sv:737`) changes SDRAM refresh behavior during FF, potentially causing read corruption visible as flickering on the dock's display path.  
**Fixability:** Needs-hardware-test  
**Action:** Check if dock `vblank` is used in the video output chain; if so, gate FF mode from driving SDRAM refresh when dock is active.

---

### #31 — Audio Buzzing in Final Fantasy Adventure

**Type:** Bug  
**Status:** Partially addressed  
**Root cause:** `gbc_snd.vhd` DAC simulation. The "FF Sound" option referenced in the issue is the fast-forward sound toggle, not a game-specific option. The `remove_pops` / "No Audio Pops" flag (interact id 1006) was added later and is OFF by default.  
**Fixability:** Needs-hardware-test  
**Action:** Recommend testers enable "No Audio Pops"; if resolved, change `defaultval` to `"0x00000080"`.

---

### #36 — Power Antenna LED Always On

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** `core_top.sv:960` — `port_tran_so_dir = 1'b1` always. The GB link SO line is always driven, causing accessories that watch the serial bus (Power Antenna, Bug Sensor) to detect activity.  
**Fixability:** Fixable-by-source-edit  
**Action:** Change `port_tran_so_dir = 1'b1` to `port_tran_so_dir = sc_int_clock_out` (output only when GB is link master), matching `port_tran_sck_dir` which already uses `sc_int_clock_out`.

---

### #44 — Picross 2 Artifacts

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** Likely a PPU timing edge case in `lcd.v` or an MBC1 ROM banking edge case (`mappers/mbc1.v`) in the fan translation. Fan translations sometimes use unusual mapper configurations.  
**Fixability:** Needs-hardware-test  
**Action:** Request save state + ROM CRC to reproduce; compare against SameBoy.

---

### #46 — GB Kiss / HuC-1 IR Support

**Type:** Feature request  
**Status:** Still relevant  
**Root cause:** `core_top.sv:224-225` hard-disables IR. `huc1.v:96` returns `8'hC0` (no light) always. The Pocket has a hardware IR transceiver on pins H10/H11 (QSF lines 192-193).  
**Fixability:** Needs-new-feature-HDL  
**Action:** Requires wiring `port_ir_rx` → HuC-1 cram_do, `port_ir_tx` ← HuC-1 `ir_en`, and conditional enable in `core_top.sv`.

---

### #49 — Oracle of Seasons/Ages Audio Distortion

**Type:** Bug  
**Status:** Still relevant (known upstream issue)  
**Root cause:** `gbc_snd.vhd` MBC3/MBC5 game audio accuracy. These games use the noise channel and wave channel in ways that stress the GB APU simulation. Upstream MiSTer has the same issue.  
**Fixability:** Needs-hardware-test  
**Action:** Track upstream MiSTer for fixes; no local-only fix available.

---

### #51 — Pokemon Red Save Corruption

**Type:** Bug  
**Status:** Still relevant but unconfirmed  
**Root cause:** The reported 30 KB file size is suspicious for MBC1 (should be 8 KB). Possible SDRAM write partial-completion during unexpected reset, or a `bk_addr` mis-indexing in `save_handler.sv:128-134` for RAM mask `0x0F` (8 KB = addr mask).  
**Fixability:** Needs-hardware-test  
**Action:** Needs reproducible case; user should attach the save file.

---

### #52 — Color Change in Pokemon Blue (SGB)

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** SGB palette packet handling in `src/gb/sgb.v`. Battle transitions send new SGB palette commands; a timing race between the SGB packet decode and the lcd module's palette latch can cause a single-frame color glitch.  
**Fixability:** Needs-hardware-test  
**Action:** Track upstream MiSTer SGB module for fix; reproduce with screen capture.

---

### #55 — Wisdom Tree Mapper (Bible ROM)

**Type:** Feature request  
**Status:** Already implemented in HDL, but not exposed  
**Root cause:** `cart.v:242` — `wire wisdom_tree = (mapper_sel_r == 3'd1)`. `misc.v:68-69` implements the mapper. However `core_top.sv:846` passes `mapper_sel = 0`, so it is never selectable.  
**Fixability:** Config-only (interact.json change + one HDL constant change)  
**Action:** Add a "Mapper Override" interact dropdown with options None/Wisdom-Tree/Mani161, writing to a new boot_settings bit; pass the value from `boot_settings_s` into `cart_top.mapper_sel`.

---

### #58 — WRAM Monitoring / Debug Output

**Type:** Feature request  
**Status:** Stale / out of scope  
**Root cause:** `core_top.sv:266` — `assign dbg_tx = 1'bZ`. The UART is available on the debug header but intentionally unconnected.  
**Fixability:** Not-a-code-issue  
**Action:** Close as out-of-scope; UART debug is a developer tool not appropriate for release firmware.

---

### #59 — Hotswap / Coldswap ROM at Runtime

**Type:** Feature request  
**Status:** Stale / APF limitation  
**Root cause:** The APF framework requires a core reset to change the loaded dataslot; hotswap is not supported. Coldswap (alternative save file) requires APF save slot arbitration not exposed to core logic.  
**Fixability:** Not-a-code-issue  
**Action:** Close as APF framework limitation.

---

### #60 — Audio Pop After Each Sound

**Type:** Bug  
**Status:** Fix exists but not default-on  
**Root cause:** `gbc_snd.vhd:1648-1651` — when `remove_pops = '0'` (the default), DAC enable/disable transitions create step changes in the output. The `audio_no_pops` signal in `core_top.sv:529` is mapped to `run_settings_s[7]`, and interact id 1006 has `defaultval: "0x00000000"` (OFF).  
**Fixability:** Fixable-by-source-edit (one-line JSON change)  
**Action:** Change interact.json id 1006 `defaultval` from `"0x00000000"` to `"0x00000080"` in both `pkg/gb` and `pkg/gbc` to enable the pop-removal by default.

---

### #62 — Include .gbp Palette and .sgb Border Assets

**Type:** Feature request  
**Status:** Config-only  
**Root cause:** The feature code exists. The palette dataslot (id 3) and border dataslot (id 2) are fully wired. The MiSTer GB repo has these asset files.  
**Fixability:** Config-only  
**Action:** Copy `.gbp` palette files from MiSTer/MiSTer-devel/Game-Boy repo into `pkg/gb/Assets/` and `pkg/gbc/Assets/`. Update README.

---

### #63 — SGB BIOS State Lost After Sleep/Wake

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** `core_top.sv:485` — writing to `boot_settings` always triggers `reset_timer <= 1`. On wake, the APF framework writes boot_settings to restore state, which triggers a full core reset. After reset, the SGB BIOS dataslot (id 6) is not automatically reloaded; only the ROM is reloaded.  
**Fixability:** Fixable-by-source-edit (needs APF framework investigation)  
**Action:** Investigate whether the APF sleep/wake mechanism reloads all dataslots or only the main ROM slot; if not, request BIOS reload in the reset handler logic.

---

### #67 — Turbo Button

**Type:** Feature request  
**Status:** Still relevant  
**Root cause:** No turbo logic in `core_top.sv:1145-1148` joystick mapping.  
**Fixability:** Needs-new-feature-HDL  
**Action:** Add turbo-fire counter logic; map X/Y buttons to turbo A/B via interact option. Moderate complexity, self-contained.

---

### #68 — IR Communication (Card Pop, Pokemon TCG)

**Type:** Feature request  
**Status:** Still relevant (same as #46)  
**Root cause:** Same as #46. GBC general IR is controlled via register 0xFF56 (`RP` register). `gb.v` does not implement this register.  
**Fixability:** Needs-new-feature-HDL  
**Action:** Implement GB `RP` register (0xFF56) in `gb.v` and wire to `port_ir_rx/tx` in `core_top.sv`.

---

### #70 — Custom Palette Not Saving

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** The interact Custom Palette option (id 1002, `persist: true`) writes to `run_settings` at 0xF2000000 to select palette mode (Off/Auto/Force). The actual palette data lives in a `.gbp` file loaded as dataslot id 3, buffered into `palette[127:0]` in `core_top.sv:934-939`. If no `.gbp` file exists, the palette reverts to the hardcoded default `128'h828214517356305A5F1A3B4900000000`. The `persist` flag only remembers the mode selection, not the pixel data.  
**Fixability:** Needs-hardware-test  
**Action:** If user has no `.gbp` file, this is expected. If user has a `.gbp` file and palette still resets, it is a dataslot reload ordering bug on core start.

---

### #74 — Up Always Held in Docked Mode

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** `core_top.sv:1145` maps `cont1_key_s[0]` to dpad_up. In docked mode, the controller data comes from the dock's USB input. There may be a connector wiring / controller type issue where `cont1_key_s[31:28]` (type field) causes a different bit mapping, or the dock sends a spurious key. The `synch_3` synchronizer for `cont1_key` (`core_top.sv:504`) is fine for cross-domain sync.  
**Fixability:** Needs-hardware-test  
**Action:** Check if issue is dock-controller-type-specific or universal; add `cont1_key_s[31:28] == 4'h1` type check before applying mapping.

---

### #75 — Fast-Forward Tearing + Docked Glitches

**Type:** Bug  
**Status:** Duplicate of #11 / #21 / #25  
**Root cause:** See Group A analysis.  
**Action:** Resolve alongside #11; close as duplicate.

---

### #76 — Timing Constraints Not Met (v1.3.2)

**Type:** Bug  
**Status:** Likely already fixed (v1.4.0 shipped)  
**Root cause:** `src/core/core_constraints.sdc` timing constraints. Reporter says 1.3.1 was fine, 1.3.2 introduced a path that violated timing.  
**Fixability:** Fixable-by-source-edit  
**Action:** Verify that v1.4.0 build meets timing; if not, review `core_constraints.sdc` for any new paths added in 1.3.2-era commits.

---

### #77 — GBA RTC Support

**Type:** Question (wrong repo)  
**Status:** Stale / wrong repo  
**Root cause:** N/A — reporter is asking about GBA core, not GB/GBC.  
**Action:** Close with redirect to spiritualized1997/openfpga-GBA.

---

### #78 — Save File Extra 0.1 KB

**Type:** Question / Documentation  
**Status:** Config-only (by design)  
**Root cause:** `save_handler.sv:103-109` — when `RTC_inuse=1`, `datatable_data = save_size_bytes + 16` appends 16 bytes of RTC data (5 × 16-bit words: 2 timestamp + 3 saved-time). The file on SD is therefore `SRAM_size + 16 bytes`.  
**Fixability:** Config-only  
**Action:** Document the 16-byte RTC footer in README; provide a conversion note for users transferring saves.

---

### #79 — Screen Filters Differ from Official Analogue Core

**Type:** Question  
**Status:** Not-a-code-issue  
**Root cause:** `pkg/*/Cores/*/video.json` defines scaler filter selections. The official Analogue core uses proprietary filter parameters; this core uses independently authored parameters. Different by design.  
**Action:** Close as by-design; note in README.

---

### #84 — Mole Mania Multiplayer Not Working

**Type:** Bug  
**Status:** Still relevant  
**Root cause:** `src/gb/link.v`. The external-clock path (lines 113-129): `serial_counter` decrements on the negedge of the external clock (line 119) but the IRQ and counter reset check (`serial_counter == 0`) fires on the posedge (line 122-125). The initial counter value is 4'd8 giving 9 bit-slots (8..1..0), not 8. Additionally, `port_tran_so_dir = 1'b1` always, meaning the Pocket always drives SO — in a two-Pocket session the slave device also drives SO, causing a bus conflict.  
**Fixability:** Fixable-by-source-edit (partially)  
**Action:** Fix the always-driven SO issue (same fix as #36: only drive SO when master). Investigate whether serial_counter initial value should be 4'd7. Compare against spiritualized1997's link implementation which reportedly works.

---

### #86 — Sleep/Wake + Save State Crash from Cartridge

**Type:** Bug  
**Status:** Still relevant (v1.4.0 regression)  
**Root cause:** `core_top.sv:512` — `cart_physical_mode` is driven by `osnotify_adapter_play` via synch_3. On sleep/wake, APF re-sends settings. `core_top.sv:485` triggers a reset when `boot_settings` is written, which reinitializes `isGBC = \`isgbc` (always 1 in the GBC core, `core_top.sv:718`). However the physical cart might be a GB cart; the game's header GBC flag from the physical cart header is not re-checked post-reset, so the core may re-initialize in GBC mode for a DMG cart.  
**Fixability:** Needs-hardware-test  
**Action:** Investigate whether isGBC detection from the physical cart header (`cart.v` isGBC_game) feeds back correctly after sleep/wake reset.

---

### #87 — GeNiUs GB Backup Station Black Bar

**Type:** Bug  
**Status:** Niche hardware, likely won't-fix  
**Root cause:** `cart.v` header parsing / logo check. The GeNiUs device is a non-standard cart with its own controller. The Nintendo logo check in the GB CPU bootrom normally fails for non-Nintendo carts, but the BIOS in this core may handle it differently from hardware. With v1.4.0 physical cart support, the electrical bus interface may have changed the logo read sequence.  
**Fixability:** Needs-hardware-test  
**Action:** Low priority niche hardware; request more details on what changed v1.3.x → v1.4.0 for this device.

---

### #88 — SGB Colorization Not Available from Cartridge

**Type:** Bug  
**Status:** Still relevant (v1.4.0)  
**Root cause:** `core_top.sv:983` — `isSGB = sgb_en & ~isGBC`. SGB BIOS is dataslot id 6, loaded via `sgb_boot_download`. In physical cart mode (`cart_physical_mode=1`), the `isSGB_game` flag comes from the cart header read via the physical bus (`cart.v:isSGB_game`). However "Load SGB BIOS" triggers a target_dataslot_read for id 6 which requires the file to exist as a separate dataslot file on the SD card, and the error "Missing 'Cartridge' ID[1]" suggests the APF framework is trying to access dataslot id 1 (the ROM slot) as a cartridge slot while in physical cart mode — conflicting with the adapter mode.  
**Fixability:** Needs-hardware-test  
**Action:** Investigate whether in `cart_physical_mode`, dataslot id 1 (ROM) conflicts with the adapter framework. May need to provide a separate dataslot for SGB BIOS that does not collide with the ROM dataslot.

---

### #89 — Pokemon Trading Broken in v1.4.0

**Type:** Bug  
**Status:** Still relevant (v1.4.0 regression)  
**Root cause:** `core_top.sv:959-960` — `port_tran_so_dir = 1'b1` always; `port_tran_si_dir = 1'b0` always. In v1.4.0, physical cart support was added, changing the cartridge bus signals. The reporter notes that inserting a physical GB/GBC cart switches the link port to 5V. When `cart_physical_mode = 1`, `backend_cart_rd = ~cart_physical_mode & cart_rd = 0`, so the SDRAM backend is bypassed. The serial port direction logic in `core_top.sv:959-969` is unchanged, but the presence of the physical cart changes the Pocket's hardware mux for the link cable voltage rail. Without a cart inserted, the link port runs at 3.3V (GBA compatible); with a GB/GBC cart the hardware switches to 5V. With a ROM loaded (no physical cart, `cart_physical_mode=0`) the port is 3.3V, which may explain the regression.  
**Fixability:** Needs-hardware-test  
**Action:** Test whether trading works in v1.4.0 with no physical cart; if so, the regression is in `cart_physical_mode` detection. Check if `osnotify_adapter_play` is being incorrectly asserted when only a ROM is loaded.

---

## Top 5 Recommended Fixes (ranked by value × mergeability × verifiability)

### Rank 1 — #60: Enable "No Audio Pops" by Default
**Files:** `pkg/gb/Cores/budude2.GB/interact.json`, `pkg/gbc/Cores/budude2.GBC/interact.json`  
**Change:** `defaultval: "0x00000000"` → `defaultval: "0x00000080"` for interact id 1006 in both files.  
**Why top:** Affects every user who plays any game. The fix is already implemented in HDL (`gbc_snd.vhd` lines 1648-1651). Verified by simply playing Pokemon Crystal. Zero HDL compile required. High impact, zero risk.

### Rank 2 — #36 / #84: Fix Serial Port SO Direction
**File:** `src/core/core_top.sv:960`  
**Change:** `port_tran_so_dir = 1'b1;` → `port_tran_so_dir = sc_int_clock_out;`  
**Why top:** Fixes both the Power Antenna LED issue (#36) and the bus-conflict on the slave device in two-Pocket link (#84). One-line change. The pattern is already established by `port_tran_sck_dir = sc_int_clock_out` on the adjacent line. Requires recompile + hardware test with link cable to confirm #84 improvement. This is the highest-confidence hardware protocol correctness fix.

### Rank 3 — #55: Expose Wisdom Tree Mapper via Interact
**Files:** `src/core/core_top.sv:846`, `pkg/gb/Cores/budude2.GB/interact.json`  
**Change:** (a) Pass a boot_settings bit through `mapper_sel` to `cart_top`; (b) add a "Mapper Override" interact dropdown. The Wisdom Tree mapper is fully implemented in `misc.v`; only the wiring to the top level is missing.  
**Why top:** Enables an entire game (and other Wisdom Tree titles) that currently do not function. Self-contained change with clear verification: Game Boy Bible launches and shows content.

### Rank 4 — #63 + #88: SGB BIOS State After Sleep/Wake and Physical Cart
**Files:** `src/core/core_top.sv`, APF dataslot management  
**Investigation needed first:** Confirm whether APF automatically reloads all dataslots on wake. If not, the fix is to trigger a `target_dataslot_read` for the SGB BIOS slot in the post-reset sequence.  
**Why high:** SGB colorization is a frequently used feature and sleep/wake is a core Pocket UX feature. Affects #63, #88, and partially #86.

### Rank 5 — #11 / #21 / #75: Fix Screen Tearing on FF Exit
**File:** `src/gb/lcd.v`  
**Change:** In the `vbuffer_inptr` management block, add a reset to `0` on every rising edge of `lcd_vs` (not only on `lcd_off` transitions).  
**Why top-5:** Screen tearing is a visible quality regression that multiple users have reported independently. The fix hypothesis is low-risk (the write pointer should always start at 0 at frame start). Requires hardware test to confirm, but the change is localized and reversible.

---

*This document was generated from GitHub issue content and source code inspection. All file references are relative to the repository root.*
