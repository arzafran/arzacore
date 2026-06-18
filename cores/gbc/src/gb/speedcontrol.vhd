library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity speedcontrol is
   port
   (
      clk_sys     : in     std_logic;
      pause       : in     std_logic;
      speedup     : in     std_logic;
      cart_act    : in     std_logic;
      DMA_on      : in     std_logic;
      -- #2: ff_speed selects fast-forward rate
      --     "00" = 2x  (ce every 4 clocks)
      --     "01" = 4x  (ce every 2 clocks, legacy default)
      --     "1x" = Max (ce every clock)
      ff_speed    : in     std_logic_vector(1 downto 0) := "01";
      ce          : out    std_logic := '0';
      ce_2x       : buffer std_logic := '0';
      refresh     : out    std_logic := '0';
      ff_on       : out    std_logic := '0'
   );
end entity;

architecture arch of speedcontrol is

   signal clkdiv           : unsigned(2 downto 0) := (others => '0');

   signal cart_act_1       : std_logic := '0';

   signal unpause_cnt      : integer range 0 to 15 := 0;
   signal fastforward_cnt  : integer range 0 to 15 := 0;

   signal refreshcnt       : integer range 0 to 127 := 0;
   signal sdram_busy       : integer range 0 to 1 := 0;

   type tstate is
   (
      NORMAL,
      PAUSED,
      FASTFORWARDSTART,
      FASTFORWARD,
      FASTFORWARDEND,
      RAMACCESS
   );
   signal state : tstate := NORMAL;

begin

   process(clk_sys)
   begin
      if falling_edge(clk_sys) then

         ce          <= '0';
         ce_2x       <= '0';
         refresh     <= '0';

         cart_act_1  <= cart_act;

         if (refreshcnt > 0) then
            refreshcnt <= refreshcnt - 1;
         end if;

         case (state) is

            when NORMAL =>
               if (pause = '1' and clkdiv = "111" and cart_act = '0') then
                  state       <= PAUSED;
                  unpause_cnt <= 0;
               elsif (speedup = '1' and pause = '0' and DMA_on = '0' and clkdiv = "000") then
                  state           <= FASTFORWARDSTART;
                  fastforward_cnt <= 0;
               else
                  clkdiv <= clkdiv + 1;
                  if (clkdiv = "000") then
                     ce <= '1';
                  end if;
                  if (clkdiv(1 downto 0) = "00") then
                     ce_2x    <= '1';
                  end if;
               end if;

            when PAUSED =>
               if (unpause_cnt = 0) then
                  refresh <= '1';
               end if;

               if (pause = '0') then
                  if (unpause_cnt = 15) then
                     state <= NORMAL;
                  else
                     unpause_cnt <= unpause_cnt + 1;
                  end if;
               end if;

            when FASTFORWARDSTART =>
               if (fastforward_cnt = 15) then
                  state <= FASTFORWARD;
                  ff_on <= '1';
               else
                  fastforward_cnt <= fastforward_cnt + 1;
               end if;

            -- #2: FASTFORWARD speed is parameterized by ff_speed
            when FASTFORWARD =>
               if (pause = '1' or speedup = '0' or DMA_on = '1') then
                  state           <= FASTFORWARDEND;
                  fastforward_cnt <= 0;
                  -- Re-align clkdiv so NORMAL mode resumes cleanly
                  -- For all FF speeds: if bit 0 is odd, nudge to "100"
                  if (clkdiv(0) = '1') then
                     clkdiv <= "100";
                  end if;
               elsif (cart_act = '1' and cart_act_1 = '0') then
                  state      <= RAMACCESS;
                  sdram_busy <= 1;
               elsif (cart_act = '0' and refreshcnt = 0) then
                  refreshcnt <= 127;
                  refresh    <= '1';
                  state      <= RAMACCESS;
                  sdram_busy <= 1;
               else
                  -- Speed selection: 2x counts clkdiv[1:0] mod 4 (ce every 4 clocks),
                  -- 4x toggles clkdiv[0] (ce every 2 clocks), max fires ce every clock
                  if (ff_speed = "00") then
                     -- 2x: ce every 4 sys-clocks via 2-bit counter on clkdiv[1:0]
                     clkdiv(1 downto 0) <= clkdiv(1 downto 0) + 1;
                     if (clkdiv(1 downto 0) = "11") then
                        ce    <= '1';
                     end if;
                     ce_2x <= '1';
                  elsif (ff_speed(1) = '1') then
                     -- Max: ce every sys-clock (limited only by SDRAM arbitration)
                     ce    <= '1';
                     ce_2x <= '1';
                  else
                     -- 4x (default, ff_speed="01"): original behaviour
                     clkdiv(0) <= not clkdiv(0);
                     if (clkdiv(0) = '0') then
                        ce    <= '1';
                     end if;
                     ce_2x <= '1';
                  end if;
               end if;

            when FASTFORWARDEND =>
               if (fastforward_cnt = 15) then
                  state <= NORMAL;
                  ff_on <= '0';
               else
                  fastforward_cnt <= fastforward_cnt + 1;
               end if;

            when RAMACCESS =>
               if (sdram_busy > 0) then
                  sdram_busy <= sdram_busy - 1;
               else
                  state <= FASTFORWARD;
               end if;

         end case;

      end if;
   end process;



end architecture;
