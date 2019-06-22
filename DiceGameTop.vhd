----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.06.2019 00:36:43
-- Design Name: 
-- Module Name: dicegametop - Behavioral
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

entity dicegametop is
Port ( clk : in STD_LOGIC;
           newgame : in STD_LOGIC;
           roll : in STD_LOGIC;
           output : out UNSIGNED (5 downto 0);
           win : out STD_LOGIC;
           lose : out STD_LOGIC);
end dicegametop;

architecture Behavioral of dicegametop is

signal clk_div : STD_LOGIC;


type state_type is (phase1,rolling1,stoprolling1,result1, phase2,win1,lose1, rolling2);
signal current_state : state_type;
signal next_state : state_type;

signal savedNum, counter :UNSIGNED (5 downto 0):="000000";
signal counter_roll, counter_result  : UNSIGNED (3 downto 0) := "1000";
signal enable_counter_roll, enable_counter_result : STD_LOGIC;



begin

freq_div_unit: 
	entity work.freq_div(Behavioral) 
	generic map(CLK_INPUT  => 125000000,		--Clock input frequency:  125MHz
					CLK_OUTPUT => 2)		    --Clock output frequency: 2Hz
	port map(clk_in  => clk,
				clk_out => clk_div);
				
p1: process (newgame,clk_div)
begin
    if (newgame = '1') then
         current_state <= phase1;
    elsif clk_div'event and clk_div = '1' then
         current_state <= next_state;
    end if;
end process;

p2: process (current_state,roll, counter_roll, counter_result )
begin
next_state <= current_state;
case current_state is

when phase1 =>
    enable_counter_roll <='0';
    enable_counter_result <='0';
    if roll = '1' then
        next_state <= rolling1;
    end if;

when rolling1 =>  
    if roll = '0' then
        next_state <= stoprolling1;
    elsif newgame ='1' then 
        next_state <= phase1;  
    end if;

when stoprolling1 =>
   enable_counter_roll <='1';
   enable_counter_result <='0';
   if counter_roll <= 0 then
         enable_counter_roll <='0';
         next_state <= result1;
   elsif newgame ='1' then 
        next_state <= phase1;  
   end if;

when result1 =>
   enable_counter_result <='1';
   enable_counter_roll <='0';
   if counter_result <= 0 then
        enable_counter_result <='0'; 
        next_state <= phase2;
   elsif newgame ='1' then 
        next_state <= phase1;  
    end if;
    
when phase2 =>
      enable_counter_result <= '0';
      enable_counter_roll <= '0';
      if counter >=0 and counter <20 then 
            next_state <= win1;
      elsif counter>= 20 and counter < 30 then 
            next_state <= lose1;   
      elsif counter >=30 and counter <= 40 then
            next_state <= rolling2;
      elsif newgame ='1' then
            next_state <= phase1;
      end if;
 
 when win1 =>
      enable_counter_result <= '0';
      enable_counter_roll <= '0';
        if newgame ='1' then 
            next_state <= phase1;
        end if;
when lose1 =>
      enable_counter_result <= '0';
      enable_counter_roll <= '0';
        if newgame ='1' then 
            next_state <= phase1;
        end if;
        
when rolling2 =>
    if newgame ='1' then 
            next_state <= phase1;
    end if;

end case;
end process;

p3: process (current_state)
begin
case current_state is
when phase1 =>
   output <= "000000"; 
   lose <='0';
   win <='0';
   
when rolling1 =>
     lose <='0';
     win <='0';
     output <= counter;
when stoprolling1 =>
    lose <='0';
    win <='0'; 
    output <= counter;
    
when result1 =>
    lose <='0';
    win <='0'; 
    output <= counter;
    
when phase2 =>
    win<= '0';
    lose <= '0';
    output <= counter;
    
when win1 =>
    win<='1';
    lose <= '0';
    output <= counter;
    
when lose1 => 
    lose<='1';
    win <= '0';
    output <= counter;
    
when rolling2 =>
    win <='0';
    lose <= '0';
    output <= counter;
    
end case;
end process;


process (clk_div, roll, newgame)
begin
      if (newgame = '1') then 
        counter <= "000000";
      elsif clk_div'event and clk_div ='1' then
        
         if(roll ='1')then 
            if (counter = 63) then
                counter <= (others => '0');
            else 
                counter <= counter +1;
            end if; 
        elsif (enable_counter_roll ='1')  then
           if (counter = 63) then
                counter <= (others => '0');
            else 
                counter <= counter +1;
            end if; 
         elsif (enable_counter_result ='1')then            
               counter <= counter;
         else 
            counter <= counter;
         end if;
      end if;
               
end process;

process (clk_div, newgame, enable_counter_roll)
begin
      if (newgame = '1') then 
         counter_roll <= "1000";
      elsif clk_div'event and clk_div ='1' then
        if(enable_counter_roll = '1') then  
            if (counter_roll <= 0) then
                counter_roll <= "1000";
                              
            else 
            
                counter_roll <= counter_roll - 1;
            end if;        
         else
            counter_roll <= "1000";       
        end if ; 
    end if;     
   
end process;


process (clk_div, newgame, enable_counter_result)
begin
      if newgame ='1' then
            counter_result <= "1000";           
      elsif clk_div'event and clk_div ='1' then
        if(enable_counter_result = '1') then  
            if (counter_result <= 0) then
                counter_result <="1000";             
            else
                counter_result <= counter_result - 1;
            end if;
          else
            counter_result <= "1000";            
        end if ;
         
    end if;     
   
end process;

end Behavioral;
