# VHDL_Dice
This project is a dice game for the Zybo-Z7 boards.

1) The user can "roll" the two dice by pressing a specific button on the board. While pressing the button the dice are rolling (LEDs on the board cycling through random binary numebers) and we can see the binary values changing every second.
2) When the user releases the button the dice stop "rolling" after 3 seconds.
3) If the sum of the two dice is 7 or 11 then the user wins, if it's 2 or 3 the the user loses else the game continues and the user rolls again.
4) This time the user can win if the sum of the results is 12 or if it's the same sum as the previous roll. The losing results now are 7 and 11. 
5) This pattern continues until the user wins or loses.
