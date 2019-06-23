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
           output, output2 : out UNSIGNED (5 downto 0);
           win : out STD_LOGIC;
           lose : out STD_LOGIC);
end dicegametop;

architecture Behavioral of dicegametop is

signal clk_div : STD_LOGIC;

type state_type is (phase1,rolling1,stoprolling1,result1, phase2,win1,lose1, rolling2, stoprolling2,result2, save, phase3,win2,lose2);
signal current_state : state_type;
signal next_state : state_type;

signal savedNum, counter, diceSum :UNSIGNED (5 downto 0):="000000";
signal counter_roll, counter_result  : UNSIGNED (3 downto 0) := "1000";
signal enable_counter_roll, enable_counter_result, save_it : STD_LOGIC;
signal dice1, dice2 : UNSIGNED (5 downto 0); --eixame thema me thn prosthesi(3bits + 3 bits = 3 bits => output(6bits)ERROR)
signal dice1tmp, dice2tmp : UNSIGNED (2 downto 0);
begin

freq_div_unit: 
	entity work.freq_div(Behavioral) 
	generic map(CLK_INPUT  => 125000000,		--Clock input frequency:  125MHz
					CLK_OUTPUT => 2)		    --Clock output frequency: 2Hz
	port map(clk_in  => clk,
				clk_out => clk_div);
lfsr_unit: 
	entity work.lfsr(Behavioral)
	port map( clk => clk,
	          dice1 => dice1tmp, 
	          dice2 =>dice2tmp);
				
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
    save_it <= '0';
    if roll = '1' then
        next_state <= rolling1;
    end if;

when rolling1 => -- Oso patame to koympi roll
    save_it <= '0';
    if roll = '0' then
        next_state <= stoprolling1; 
    elsif newgame ='1' then 
        next_state <= phase1;  
    end if;

when stoprolling1 =>
   enable_counter_roll <='1'; -- Counter gia antistrofi mestrisi
   enable_counter_result <='0'; 
   if counter_roll <= 0 then
         enable_counter_roll <='0';
         next_state <= result1;
   elsif newgame ='1' then 
        next_state <= phase1;  
   end if;

when result1 =>
   enable_counter_result <='1'; -- Counter gia to poi wra fainontai ta apotelesmata
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
      if newgame ='1' then
            next_state <= phase1;
      elsif diceSum = 7 or diceSum = 11 then 
            next_state <= win1;
      elsif diceSum = 2 or diceSum = 3 or diceSum = 12 then 
            next_state <= lose1;
      else
        save_it <= '1';
        if roll='1' then
            next_state <=save;
        end if;
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

when save =>
    save_it <= '1';
    next_state<=rolling2;
   
when rolling2 => -- Oso patame to koympi roll gia tin 2i fasi
    save_it <= '0';
    if roll = '0' then
        next_state <= stoprolling2; 
    elsif newgame ='1' then 
        next_state <= phase1;  
    end if;     

when stoprolling2 =>
   enable_counter_roll <='1'; -- Counter gia antistrofi mestrisi
   enable_counter_result <='0'; 
   if counter_roll <= 0 then
         enable_counter_roll <='0';
         next_state <= result2;
   elsif newgame ='1' then 
        next_state <= phase1;  
   end if;        
  
when result2 =>
   enable_counter_result <='1'; -- Counter gia to poi wra fainontai ta apotelesmata
   enable_counter_roll <='0';
   if counter_result <= 0 then
        enable_counter_result <='0'; 
        next_state <= phase3;
   elsif newgame ='1' then 
        next_state <= phase1;  
    end if;     


    
when phase3 =>
      enable_counter_result <= '0';
      enable_counter_roll <= '0';
      save_it <= '0';
      if newgame ='1' then
            next_state <= phase1;
      elsif diceSum = 7 or diceSum= 11 then 
            next_state <= lose2;
      elsif diceSum = 12 or diceSum = savedNum then 
            next_state <= win2;
      else
        if roll='1' then
            next_state <=save;
        end if;
        
      end if; 

when win2 =>
      enable_counter_result <= '0';
      enable_counter_roll <= '0';
        if newgame ='1' then 
            next_state <= phase1;
        end if;
when lose2 =>
      enable_counter_result <= '0';
      enable_counter_roll <= '0';
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
     output <= dice1tmp&dice2tmp;
     output2 <= savedNum;
when stoprolling1 =>
    lose <='0';
    win <='0'; 
    output <= dice1tmp&dice2tmp;
    output2 <= savedNum;
when result1 =>
    lose <='0';
    win <='0'; 
    output <= dice1(2 downto 0)&dice2(2 downto 0);
    output2 <= savedNum;
when phase2 =>
    win<= '0';
    lose <= '0';
    output <= diceSum;--dice1+dice2;
    output2 <= savedNum;
    
when win1 =>
    win<='1';
    lose <= '0';
    output <= diceSum; --dice1+dice2;
    output2 <= savedNum;
when lose1 => 
    lose<='1';
    win <= '0';
    output <=  diceSum;--dice1+dice2;
    output2 <= savedNum;
when rolling2 =>
     lose <='0';
     win <='0';
     output <= dice1tmp&dice2tmp;
     output2 <= savedNum;
when stoprolling2 =>
    lose <='0';
    win <='0'; 
    output <= dice1tmp&dice2tmp;
    output2 <= savedNum;
when result2 =>
    lose <='0';
    win <='0'; 
    output <= dice1(2 downto 0)&dice2(2 downto 0);
    output2 <= savedNum;
when save =>
    lose <='0';
    win <='0'; 
    output <= dice1(2 downto 0)&dice2(2 downto 0);
    output2 <= savedNum;
when phase3 =>
    win<= '0';
    lose <= '0';
    output <= diceSum;--dice1+dice2;
    output2 <= savedNum;
when win2 =>
    win<='1';
    lose <= '0';
    output <=  diceSum;--dice1+dice2;
    output2 <= savedNum;
when lose2 => 
    lose<='1';
    win <= '0';
    output <=  diceSum;--dice1+dice2;
    output2 <= savedNum;
end case;
end process;

lock_dices:process (enable_counter_roll) -- Otan feugei apo to state stop rolling allazoume times gia 4 sec kai meta kleidwnoume
begin
    if enable_counter_roll = '1' then
        dice1 <= "000"&dice1tmp;
        dice2 <= "000"&dice2tmp;
        diceSum <= dice1 + dice2;
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


save_proc:process (save_it)
begin
if (save_it = '1') then 
    savedNum <= diceSum;
else
    savedNum <= savedNum;
end if;
end process save_proc;

end Behavioral;
