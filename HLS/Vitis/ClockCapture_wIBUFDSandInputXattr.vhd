-- PL_SYSREF_Capture: PL SYSREF capture circuit where the RF-ADC and RF-DAC are 
-- operating at the same AXI4-Stream clock frequency (based on the example circuit 
-- on page 196 of pg269 (the RF Data Converter LogiCORE IP Product Guide))

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_capture is 
  Port (
    pl_sysref_p : in STD_LOGIC;
    pl_sysref_n : in STD_LOGIC;
    pl_clk_p : in STD_LOGIC;
    pl_clk_n : in STD_LOGIC;
    sysref_adc : out STD_LOGIC);
end clock_capture;



architecture Behavioral of clock_capture is
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO of pl_sysref_p: SIGNAL is "xilinx.com:signal:clock:1.0 pl_sysref pl_sysref_p";
  ATTRIBUTE X_INTERFACE_INFO of pl_sysref_n: SIGNAL is "xilinx.com:signal:clock:1.0 pl_sysref pl_sysref_n";
  ATTRIBUTE X_INTERFACE_INFO of pl_clk_p: SIGNAL is "xilinx.com:signal:clock:1.0 pl_clk pl_clk_p";
  ATTRIBUTE X_INTERFACE_INFO of pl_clk_n: SIGNAL is "xilinx.com:signal:clock:1.0 pl_clk pl_clk_n";

begin

  end
