----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.06.2019 17:42:28
-- Design Name: 
-- Module Name: lfsr - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lfsr is
    Port ( clk : in STD_LOGIC;
           roll : in STD_LOGIC;
           reset : in STD_LOGIC;
           output : out UNSIGNED (5 downto 0));
end lfsr;

architecture Behavioral of lfsr is
  signal count           :UNSIGNED (15 downto 0);
    signal linear_feedback :std_logic;
    
signal clk_div : STD_LOGIC;

signal out1, out2, out3, out4, out5, out6 : STD_LOGIC;

begin

freq_div_unit: 
	entity work.freq_div(Behavioral) 
	generic map(CLK_INPUT  => 125000000,		--Clock input frequency:  125MHz
					CLK_OUTPUT => 2)				--Clock output frequency: 2Hz
	port map(clk_in  => clk,
				clk_out => clk_div);
  
  
      process (clk) begin
          if ( count ="1111111111111111" ) then
              count <= (others=>'0');
          elsif (rising_edge(clk)) then
              count <= count + 1;
          end if;
      end process;
     process (clk_div) begin
      if (rising_edge(clk_div)) then
        if(roll='1') then
             out1 <= count(0) xor count(9)xor count(2);
              out2 <= count(6) xor count (10) xor count (5);
               out3 <= count(14) xor count (7) xor count (1);
               out4 <= count(5) xor count(13)xor count(3);
              out5 <= count(8) xor count (12) xor count (0);
               out6 <= count(15) xor count (1) xor count (9);
        end if;
      end if;
     end process;
output <= out6 & out5 & out4 & out3 & out2 & out1;
     


end Behavioral;
