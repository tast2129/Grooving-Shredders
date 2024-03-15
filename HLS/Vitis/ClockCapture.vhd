-- PL_SYSREF_Capture: PL SYSREF capture circuit where the RF-ADC and RF-DAC are 
-- operating at the same AXI4-Stream clock frequency (based on the example circuit 
-- on page 196 of pg269 (the RF Data Converter LogiCORE IP Product Guide))

-- generic lib probably?
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- for IBUFDS and BUFGCE
Library UNISIM;
use UNISIM.vcomponents.all;

entity clock_capture is 
  Port (
    pl_sysref_p : in STD_LOGIC;
    pl_sysref_n : in STD_LOGIC;
    pl_clk_p : in STD_LOGIC;
    pl_clk_n : in STD_LOGIC;
    sysref_adc : out STD_LOGIC);
end clock_capture;

  
architecture Behavioral of clock_capture is
  -- BEGIN declarative Architecture body ->
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO of pl_sysref_p: SIGNAL is "xilinx.com:interface:diff_clock:1.0 pl_sysref CLK_P";
  ATTRIBUTE X_INTERFACE_INFO of pl_sysref_n: SIGNAL is "xilinx.com:interface:diff_clock:1.0 pl_sysref CLK_N";
  ATTRIBUTE X_INTERFACE_INFO of pl_clk_p: SIGNAL is "xilinx.com:interface:diff_clock:1.0 pl_clk CLK_P";
  ATTRIBUTE X_INTERFACE_INFO of pl_clk_n: SIGNAL is "xilinx.com:interface:diff_clock:1.0 pl_clk CLK_N";

 signal pl_sysref, pl_clk_in, pl_clk: STD_LOGIC;

  -- IBUFDS: Differential Input Buffer
  --         Virtex UltraScale
  -- Xilinx HDL Language Template, version 2022.1

  BUFDS_sysref : IBUFDS
  port map (
    O => pl_sysref,     -- 1-bit output: Buffer output
    I => pl_sysref_p,   -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
    IB => pl_sysref_n   -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
  );

  BUFDS_clk : IBUFDS
  port map (
    O => pl_clk_in,     -- 1-bit output: Buffer output
    I => pl_clk_p,   -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
    IB => pl_clk_n   -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
  );

  -- End of IBUFDS_sysref and IBUFDS_clk instantiation

  -- BUFGCE: General Clock Buffer with Clock Enable
  --         Virtex UltraScale+
  -- Xilinx HDL Language Template, version 2022.1

  BUFGCE_clk : BUFGCE
  generic map (
    CE_TYPE => "SYNC",               -- ASYNC, HARDSYNC, SYNC
    IS_CE_INVERTED => '0',           -- Programmable inversion on CE
    IS_I_INVERTED => '0',            -- Programmable inversion on I
    SIM_DEVICE => "ULTRASCALE_PLUS"  -- ULTRASCALE, ULTRASCALE_PLUS
  )
  port map (
    O => pl_clk,     -- 1-bit output: Buffer
    CE => 1,         -- 1-bit input: Buffer enable
    I => pl_clk_in   -- 1-bit input: Buffer
  );

  -- End of BUFGCE_clk instantiation
  -- END declarative Architecture body

  -- BEGIN statement Architecture body ->
  -- differential flip-flop logic
  process (signal)
    if rising_edge(signal) then  -- Older VHDL if (signal'event and signal = '1')
      sysref_adc <= pl_sysref;
    end if;
  end process;
  -- END statement Architecture body
    
end Behavioral;
