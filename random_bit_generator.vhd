library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity random_bit_generator is
    Port ( clk : in STD_LOGIC;
           dice1 : out UNSIGNED (2 downto 0);
           dice2 : out UNSIGNED (2 downto 0));
end random_bit_generator;

architecture Behavioral of random_bit_generator is
  signal count           :UNSIGNED (15 downto 0);
  signal out1, out2, out3, out4, out5, out6 : STD_LOGIC;
  signal clk_div : STD_LOGIC;

begin
 
 freq_div_unit: 
	entity work.freq_div(Behavioral) 
	generic map(CLK_INPUT  => 125000000,		--Clock input frequency:  125MHz
					CLK_OUTPUT => 2)	
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
			out1 <= count(0) xor count(9)xor count(2);
			out2 <= count(6) xor count (10) xor count (5);
			out3 <= count(14) xor count (7) xor count (1);
			out4 <= count(5) xor count(13)xor count(3);
			out5 <= count(8) xor count (12) xor count (0);
			out6 <= count(15) xor count (1) xor count (9);
		end if;   
    end process;

dice1 <= "001" when  (out2= '0' and out5= '0' and out4 = '0') else
         "110" when  (out2= '1' and out5= '1' and out4 = '1') else
         out2 & out5 & out4;
         
dice2 <= "001" when  (out3= '0' and out6= '0' and out1 = '0') else
         "110" when  (out3= '1' and out6= '1' and out1 = '1') else
         out3 & out6 & out1;

end Behavioral;
