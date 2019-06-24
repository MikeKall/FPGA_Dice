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

-- --------> the word dice is a plural noun... Die is the singular form

architecture Behavioral of dicegametop is

signal clk_div : STD_LOGIC;

type state_type is (phase1,rolling1,stoprolling1,result1, phase2,win1,lose1, rolling2, stoprolling2,result2, save, phase3,win2,lose2);
signal current_state : state_type;
signal next_state : state_type;

signal savedNum, counter, diceSum :UNSIGNED (5 downto 0):="000000";
signal counter_roll, counter_result  : UNSIGNED (3 downto 0) := "1000";
signal enable_counter_roll, enable_counter_result, save_it : STD_LOGIC;
signal dice1, dice2 : UNSIGNED (5 downto 0); --thema me thn prosthesi(3bits + 3 bits = 3 bits => output(6bits)ERROR), gia auto ta zaria einai 6 bits(xreisimopoioume pali omws mono ta 3bits)
signal dice1tmp, dice2tmp : UNSIGNED (2 downto 0);
begin

freq_div_unit: 
	entity work.freq_div(Behavioral) 
	generic map(CLK_INPUT  => 125000000,		--Clock input frequency:  125MHz
					CLK_OUTPUT => 2)		    --Clock output frequency: 2Hz
	port map(clk_in  => clk,
				clk_out => clk_div);
random_bit_generator_unit:
	entity work.random_bit_generator(Behavioral)
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

when phase1 => --waiting for roll to be pressed
    enable_counter_roll <='0';
    enable_counter_result <='0';
    save_it <= '0';
    if roll = '1' then
        next_state <= rolling1;
    end if;

when rolling1 => -- Roll is pressed, dice are rolling
    save_it <= '0';
    if roll = '0' then -- If roll is released then go to next state
        next_state <= stoprolling1; 
    elsif newgame ='1' then -- If new game is pressed then go to phase1
        next_state <= phase1;  
    end if;

when stoprolling1 => --rolling is being stopped. The counter for the 4 seconds is being started.
   enable_counter_roll <='1'; -- Sends signal for the countdown counter to start.(Dices will roll for 4 more seconds)
   if counter_roll <= 0 then -- If the 4 seconds countdown has stopped then 
         enable_counter_roll <='0'; -- Disable the signal
         next_state <= result1; -- Go to next state
   elsif newgame ='1' then -- If new game is pressed then go to phase1
        next_state <= phase1;  
   end if;

when result1 =>
   enable_counter_result <='1'; -- Sends signal to enable 4 seconds countdown counter(Displays the results for 4 seconds)
   if counter_result <= 0 then -- If the 4 seconds countdown has stopped then 
        enable_counter_result <='0'; -- Disable the signal
        next_state <= phase2; -- Go to next state
   elsif newgame ='1' then -- If new game is pressed then go to phase1
        next_state <= phase1;  
    end if;
    
when phase2 => -- The results will be displayed in this state
      if newgame ='1' then -- If new game is pressed then go to phase1
            next_state <= phase1;
      elsif diceSum = 7 or diceSum = 11 then -- if the user wins
            next_state <= win1; -- Go to state win
      elsif diceSum = 2 or diceSum = 3 or diceSum = 12 then -- if the user loses
            next_state <= lose1; -- Go to state lose
      else -- if the user doesn't win or lose
        if roll='1' then -- Waiting for the user to continue
            next_state <=save; -- Go to state save
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
    save_it <= '1'; --Send a signal to save the results
    next_state<=rolling2; -- go to rolling2 state
   
when rolling2 => -- Rolling in phase 2
    save_it <= '0'; -- Disable the save signal
    if roll = '0' then -- If the user release the roll btn
        next_state <= stoprolling2; -- go to state stoprolling2
    elsif newgame ='1' then 
        next_state <= phase1;  
    end if;     

when stoprolling2 => --rolling is being stopped. The counter for the 4 seconds is being started.
   enable_counter_roll <='1'; -- Sends signal for the countdown counter to start.(Dices will roll for 4 more seconds)
   if counter_roll <= 0 then
         enable_counter_roll <='0'; -- disable the signal
         next_state <= result2; -- Go to state result2
   elsif newgame ='1' then 
        next_state <= phase1;  
   end if;        
  
when result2 =>
   enable_counter_result <='1'; -- Sends signal to enable 4 seconds countdown counter(Displays the results for 4 seconds)
   if counter_result <= 0 then -- If the 4 seconds countdown has stopped then 
        enable_counter_result <='0'; -- Disable the signal
        next_state <= phase3; --Go to phase3
   elsif newgame ='1' then 
        next_state <= phase1;  
    end if;     


    
when phase3 => -- The results will be displayed in this state
      if newgame ='1' then
            next_state <= phase1;
      elsif diceSum = 7 or diceSum= 11 then -- Checking if the user lost
            next_state <= lose2;
      elsif diceSum = 12 or diceSum = savedNum then -- Checking if the user won
            next_state <= win2;
      else
        if roll='1' then -- waiting for the user to continue
            next_state <=save; -- Go to state save
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
when phase1 => -- outputs are empty
   output <= "000000";
   lose <='0';
   win <='0';
   
when rolling1 => --Displays the changes of the values of the dice
     lose <='0';
     win <='0';
     output <= dice1tmp&dice2tmp;
     
when stoprolling1 => --Displays the changes of the values of the dice for 4 more seconds
    lose <='0';
    win <='0'; 
    output <= dice1tmp&dice2tmp;

when result1 => --Displays the results
    lose <='0';
    win <='0'; 
    output <= dice1(2 downto 0)&dice2(2 downto 0);

when phase2 => -- Displays the sum of the dice
    win<= '0';
    lose <= '0';
    output <= diceSum;
    
when win1 => -- Win led is on
    win<='1';
    lose <= '0';
    output <= diceSum;
when lose1 => -- Lose led is on
    lose<='1';
    win <= '0';
    output <=  diceSum;

when rolling2 =>
     lose <='0';
     win <='0';
     output <= dice1tmp&dice2tmp;

when stoprolling2 =>
    lose <='0';
    win <='0'; 
    output <= dice1tmp&dice2tmp;

when result2 =>
    lose <='0';
    win <='0'; 
    output <= dice1(2 downto 0)&dice2(2 downto 0);

when save =>
    lose <='0';
    win <='0'; 
    output <= dice1(2 downto 0)&dice2(2 downto 0);

when phase3 =>
    win<= '0';
    lose <= '0';
    output <= diceSum;

when win2 =>
    win<='1';
    lose <= '0';
    output <=  diceSum;

when lose2 => 
    lose<='1';
    win <= '0';
    output <=  diceSum;

end case;
end process;

lock_dice:process (enable_counter_roll) -- When on stoprolling state an enable signal is being sent here. When the this signal is disabled the dice lock their values and the Sum is calculated
begin
    if enable_counter_roll = '1' then
        dice1 <= "000"&dice1tmp;
        dice2 <= "000"&dice2tmp;
        diceSum <= dice1 + dice2;
     end if;
end process lock_dice;
    
process (clk_div, newgame, enable_counter_roll) -- When on stoprolling state an enable signal is being sent here, the 4 seconds rolling countdown starts.
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


process (clk_div, newgame, enable_counter_result) -- When on result an enable signal is being sent here and the 4 seconds countdown starts and the result are displayed for 4 seconds
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


save_proc:process (save_it) -- Saves the results
begin
if (save_it = '1') then 
    savedNum <= diceSum;
else
    savedNum <= savedNum;
end if;
end process save_proc;

end Behavioral;
