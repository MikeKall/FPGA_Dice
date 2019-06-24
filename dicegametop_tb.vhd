----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.06.2019 22:20:50
-- Design Name: 
-- Module Name: dicegametop_tb - Behavioral
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


use IEEE.NUMERIC_STD.ALL;


entity dicegametop_tb is
--  Port ( );
end dicegametop_tb;

architecture Behavioral of dicegametop_tb is


COMPONENT dicegametop
    PORT(
          clk : in STD_LOGIC;
           newgame : in STD_LOGIC;
           roll : in STD_LOGIC;
           output : out UNSIGNED (5 downto 0);
           win : out STD_LOGIC;
           lose : out STD_LOGIC);
    END COMPONENT;

 signal clk : std_logic := '0'; 
 signal newgame : std_logic := '0'; 
 signal output : UNSIGNED (5 downto 0) := "000000";
 signal win : std_logic := '0';
 signal lose : std_logic := '0';
 signal roll : std_logic := '0';

begin

uut: dicegametop PORT MAP (
         clk => clk,
          newgame => newgame,
          roll => roll,
          output => output,
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
    
    
     newgame <= '1'; wait for 1000ms;
   newgame <= '0';
   roll <= '1'; wait for 2000ms;  roll <= '0'; wait;
  
      
end process;



   

end Behavioral;
