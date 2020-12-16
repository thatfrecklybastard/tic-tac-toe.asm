# tic-tac-toe.asm
A 6x6, 3 player tic tac toe game. 

While the code is nothing special, the algorithm for stripping the 6x6 matrix into linear arrays for score counting is one of the cooler ideas I have had during my academic career. 

1. Strips rows, columns, and diagonals into linear arrays.
2. Iterates over linear arrays. 
3. If 3 in a row match, the matching element is copied to equivArray.
4. Every instance of a character in equivArray is representative of a 3 in a row. 
5. Iterate over equivArray and count 1 for every occurence of a player's hit marker. 
6. Display scores

#Please do not copy this code. I have already used it in an assignment. However, feel free to use ideas or similar algorithms in your own code.#####################
