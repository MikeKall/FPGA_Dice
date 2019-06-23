----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.06.2019 01:15:36
-- Design Name: 
-- Module Name: dicegame_tbench - Behavioral
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

entity dicegame_tbench is
--  Port ( );
end dicegame_tbench;

architecture Behavioral of dicegame_tbench is

COMPONENT omadikibackup
    PORT(
          clk : in STD_LOGIC;
           newgame : in STD_LOGIC;
           roll : in STD_LOGIC;
           output, output2 : out UNSIGNED (5 downto 0);
           win : out STD_LOGIC;
           lose : out STD_LOGIC);
    END COMPONENT;

 signal clk : std_logic:= '0'; 
  signal newgame : std_logic; 
   signal output : UNSIGNED (5 downto 0);
   signal output2 : UNSIGNED (5 downto 0);
   signal win : std_logic;
   signal lose : std_logic ;
    signal roll : std_logic ;

begin
uut: omadikibackup PORT MAP (
         clk => clk,
          newgame => newgame,
          roll => roll,
          output => output,
          output2 => output2,
          win => win,
          lose =>lose
        );
        
  process1 : process

begin 
    clk <= '0'; wait for 500 ms;
    clk <= '1'; wait for 500 ms;
end process;

process2 : process 

begin 
    newgame <= '1'; 
    wait for 1000 ms;
    newgame <='0';
    wait for 999999999 ms;
    
    roll <= '1'; wait for 6000 ms;
    roll <= '0'; wait for 9999999 ms;
    
    
   
   
   
end process;

end Behavioral;
