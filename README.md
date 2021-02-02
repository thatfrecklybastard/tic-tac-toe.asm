# tic-tac-toe.asm
A 6x6, 3 player tic tac toe game written x86 Assembly (MASM32)

## Rules  
Choose to have 3 players or watch the computer play against itself. On load, when the board is displayed, entering one of the shown ASCII outputs will place your game marker. At the end of the game, scores are tallied by rows of three. For instance, a 4-in-a-row will be displayed as 2 points because it is technically to 3-in-a-rows. 

## How it works  
If you take note of the bottom 1000 lines, you will see something like "//---stripping row x". The code is breaking down all possible permutations of verticals, horizontals, and diagonals into their own arrays. After each permutation is placed in its own array, the algorithm then iterates over each array, copying the player's marker into a "score tracking" array if that marker is shown to be a 3-in-a-row. After this score tracking array is complete, the code then iterates over this array, adding up the occurence of each marker within, thereby providing a score. Enjoy!
