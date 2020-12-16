;TITLE TICTACTOE Final Project Fall 2020
;AUTHOR: Edward Charles Baldwin IV
;DATE: December 8th, 2020
;Description: 3 person tic-tac-toe on a 6x6 matrix, PvPvP or CvCvC Modes available
;	   Rules: Player with the most 3-in-a-rows on the board wins
;			  If a player gets the center 4 tiles of the 6x6 game board, that player automatically wins
;******************************************************************************************************************************************************

INCLUDE Irvine32.inc

;*****************************************************[MACROS]*****************************************************************************************
move TEXTEQU <mov>
clearEAX EQU <move EAX, 0>
clearEBX EQU <move EBX, 0>
clearECX EQU <move ECX, 0>
clearEDX EQU <move EDX, 0>
clearESI EQU <move ESI, 0>
clearEDI EQU <move ESI, 0>
newline TEXTEQU <0Ah, 0Dh>

;*****************************************************[PROTOS]*****************************************************************************************
printTopOfBoard  PROTO, numCols:BYTE
printRowsOfBoard PROTO, boardOffset : DWORD, rowNum : BYTE, rowSize : BYTE
printCurrentRow  PROTO, boardOffset : DWORD, rowNum : BYTE, rowLength : BYTE
printSpacerRow   PROTO, numCols:BYTE
printBottomOfBoard PROTO, numCols:BYTE
ClearRegisters   PROTO
DisplayMainMenu  PROTO
OptionsDirection PROTO
getGameBoard     PROTO 
endGame          PROTO
DisplayPVPRules  PROTO
StartPVPGame	 PROTO namePlayerOne:PTR BYTE, namePlayerTwo:PTR BYTE, namePlayerThree:PTR BYTE
displayEndScore  PROTO x_scoreCount: PTR DWORD, y_scoreCount: PTR DWORD, z_scoreCount: PTR DWORD
DisplayCVCRules  PROTO
StartCVCGame     PROTO compPlayerOne:PTR BYTE, compPlayerTwo:PTR BYTE, compPlayerThree:PTR BYTE
CVCGAME          PROTO CVCGAME_ARRAY: PTR BYTE
createRandomArray PROTO CRA_COUNTER: PTR DWORD, CRAX_count: PTR DWORD, CRAY_count: PTR DWORD, CRAZ_count: PTR DWORD
getGameBoard_computer PROTO
input        PROTO, boardOffset : DWORD
changeValue  PROTO boardOffset : DWORD, Userinput1:dword, currentPlayer1: byte
switchPlayer PROTO currentplayerOffset: dword
scoreCounter PROTO
;*****************************************************[END PROTOS/MACROS]*****************************************************************************************

;*****************************************************[THE GAME BOARD AND LITERALS]*******************************************************************************
.data
Board BYTE   030h, 031h, 032h, 033h, 034h, 035h          ;//Characters that are initially on the board for logical entry
             Rowsize = ($-Board)
             BYTE 036h, 037h, 038h, 039h, 03Ah, 03Bh
             BYTE 03Ch, 03Dh, 03Eh, 03Fh, 040h, 05Bh
             BYTE 05Ch, 05Dh, 05Eh, 05Fh, 057h, 07Bh
             BYTE 07Dh, 07Eh, 061h, 062h, 063h, 064h
             BYTE 065h, 066h, 067h, 068h, 069h, 06Ah,0h

counter BYTE 0
toNextRow = 1
rowCounter BYTE 1
colCounter BYTE 0

.code
main PROC
	INVOKE DisplayMainMenu
	
	EXIT
main ENDP       ;//end of main procedure
;*****************************************************[PROCEDURES]*************************************************************************************
;========================================================================================================================
DisplayMainMenu PROC
;Description: It's the main menu! Voila! 
;Receives: Nothing
;Returns: Nothing, but main menu is displayed
;========================================================================================================================
.data
	mainMenuPrompt BYTE "MAIN MENU", 0Ah, 0Dh,
						"===============================================", 0Ah, 0Dh, 
						"1. Let's Play 3 Player Tic-Tac-Toe (PvPvP game)", 0Ah, 0Dh,
						"2. Let's Play 3 Player Tic-Tac-Toe (CvCvC game)", 0Ah, 0Dh,
						"3. Exit Tic-Tac-Toe",0Ah, 0Dh,
						" Select An Option From the Menu Above (1-3) -- : ", 0
.code
	MOV EDX, OFFSET mainMenuPrompt			
	Call WriteString
	Call ReadInt							
	INVOKE optionsDirection					;//sends user to appropriate procedure

RET
DisplayMainMenu ENDP
;========================================================================================================================
;========================================================================================================================
optionsDirection PROC
;//Description: Submenu - directs user input traffic to appropriate procedures
;//Receives: Nothing 
;//Returns: Nothing
;========================================================================================================================
.code
	opt1:
		CMP EAX, 1				;//if users input = 1, start the PvPvP game
		JNE opt2				;//if not =, go to opt2
		Call Clrscr				;//clear the screen
		INVOKE DisplayPVPRules  ;//start this route of program

	opt2:
		CMP EAX, 2				;//if users input = 2, start the CvCvC game
		JNE opt3				;//if not =, go to opt3
		Call Clrscr				;//clear the screen
		INVOKE DisplayCVCRules  ;//start this route of program
	opt3:						;//if users input = 3, exits the program
		CMP EAX, 3	
		EXIT					;//EXIT THE PROGRAM
	RET
optionsDirection ENDP
;========================================================================================================================
;========================================================================================================================
DisplayPVPRules PROC
;//Description: Displays the rules for the PvPvP game-mode to the user/s
;//Recieves: Nothing
;//Returns: Nothing
;========================================================================================================================
.data
	pvpInstructions BYTE "You Are Playing (Player vs. Player vs. Player Mode)", 0Ah, 0Dh, 
						 "The player with the most tics or tacs or toes in a row of 4 win the game.", 0Ah, 0Dh,
						 "The player who successfully captures the center 4 squares instantly wins the game", 0Ah, 0Dh,0 

	enterPlayerOne	 BYTE "Enter Your Name Player 1: ", 0
	enterPlayerTwo	 BYTE "Enter Your Name Player 2: ", 0
	enterPlayerThree BYTE "Enter Your Name Player 3: ", 0

	nameStringOne	 BYTE 50 DUP(0)			;Hopefully we don't get any players with 51 character names
	nameOneSize		 BYTE ?
	nameStringTwo	 BYTE 50 DUP(0)
	nameTwoSize		 BYTE ?
	nameStringThree  BYTE 50 DUP(0)
	nameThreeSize	 BYTE ?

.code
	
	PUSH EBP								
	MOV EBP, ESP
	Call Clrscr                             
	
	MOV EDX, OFFSET pvpInstructions			;print the pvp instructions
	Call WriteString
	Call waitmsg							;waits for user so they have chance to read rules
	Call Clrscr								;clears the screen
											
	
	MOV EDX, OFFSET enterPlayerOne			;prompts player 1 for name, accepts name, saves name
	Call WriteString
	MOV EDX, OFFSET nameStringOne			
	MOV ECX, SIZEOF nameStringOne
	Call ReadString							
	MOV nameOneSize, AL

	MOV EDX, OFFSET enterPlayerTwo			;prompts player 2 for name, accepts name, saves name
	Call WriteString
	MOV EDX, OFFSET nameStringTwo			
	MOV ECX, SIZEOF nameStringTwo
	Call ReadString							
	MOV nameTwoSize, AL

	MOV EDX, OFFSET enterPlayerThree		;prompts player 3 for name, accepts name, saves name
	Call WriteString
	MOV EDX, OFFSET nameStringThree			
	MOV ECX, SIZEOF nameStringThree
	Call ReadString							
	MOV nameThreeSize, AL
	Call clrscr								

	INVOKE StartPVPGame, ADDR nameStringOne, ADDR nameStringTwo, ADDR nameStringThree ;Begin PvPvP mode 

	LEAVE
	RET
DisplayPVPRules ENDP
;========================================================================================================================
;========================================================================================================================
StartPVPGame PROC namePlayerOne:PTR BYTE, namePlayerTwo:PTR BYTE, namePlayerThree:PTR BYTE
;//Description: Plays the (PvPvP game mode)
;//Receives: namePlayerOne:PTR BYTE, namePlayerTwo:PTR BYTE, namePlayerThree:PTR BYTE
;//Returns: N/A
;========================================================================================================================
.data
	
	pvpTitle		BYTE " VS. ", 0		    ;Displays entered usernames
	movNumberPVP    BYTE 0					;will hold the number of the player that gets to go first
	selectionOne	DWORD 0					;player one's choice
	seletionTwo		DWORD 0					;player two's choice
	selectionThree	DWORD 0					;player three's choice
	playerOne EQU [namePlayerOne + 4]		;improves readability of the players
	playerTwo EQU [namePlayerTwo + 4]
	playerThree EQU [namePlayerThree + 4]
	nameOffset1		DWORD ?					;to store player 1 once moved
	nameOffset2		DWORD ?					;to store player 2 once moved
	nameOffset3		DWORD ?					;to store player 3 once moved
	firstGo			BYTE ?					;use as a parameter to remember which player goes first
	playerUserType2 BYTE ?					
	playerUserType3 BYTE ?					
	compUserType2	BYTE ?					
	runOnce			BYTE ?					

.code
	
	PUSH EBP				
	MOV EBP, ESP

	MOV EBX, playerOne		
	MOV nameOffset1, EBX					;store p1 

	MOV EBX, playerTwo
	MOV nameOffset2, EBX					;store p2

	MOV EBX, playerThree
	MOV nameOffset3, EBX					;store p3
	
	positionDecider:
		MOV firstGo, 1						;load a turn
		MOV EAX, 0							;clear the EAX register
		MOV AL, 3							;3 = max turn placements
		Call RandomRange					;randomly chooses integer between 1-3
		MOV firstGo, AL						;move what was randomized in the AL register to the original firstGo variable
											;position decided randomly, firstGo = the player that gets to go first
	pvpGame:							
		MOV EDX, playerOne					;Prints "Player1 vs. Player2 vs. Player3"
		Call WriteString
		MOV EDX, OFFSET pvpTitle			
		Call WriteString
		MOV EDX, playerTwo					
		Call WriteString
		MOV EDX, OFFSET pvpTitle			
		Call WriteString
		MOV EDX, playerThree				
		Call WriteString
		Call crlf
		Call crlf
		INVOKE getGameBoard

		LEAVE
		RET
StartPVPGame ENDP
;========================================================================================================================
;========================================================================================================================
printTopOfBoard PROC, numCols:BYTE
;description: prints top of the game board to the console
;receives: numCols:BYTE
;returns: the top of the board is printed to the console
;========================================================================================================================
.data
    leftCornerT BYTE     0C9h
    rightCornerT BYTE    0BBh
    topBar BYTE          0CDh
    colSeparaterT BYTE   0D1h
    barCounterT BYTE 0
.code
    push EAX
    push ECX
    mov barCounterT, 0           ; // reset barCounter to 0 to use this proc multiple times
    movzx EAX, leftCornerT
    call writeChar
    movzx ECX, numCols
    printRowLoopT:
        ; // need to do top bar 3 times, then do colSeparater
        printTopBar:
            cmp barCounterT, 3
            je separateT
            movzx EAX, topBar
            call writeChar
            inc barCounterT
            jmp printTopBar
        separateT:
            cmp ECX, 1                      ; // check if we're printing our last column
            je  endRowT                     ; // if we are, skip printing colSeparater         
            movzx EAX, colSeparaterT
            call writeChar
            mov barCounterT, 0
    loop printRowLoopT
    endRowT:
        movzx EAX, rightCornerT
        call writeChar
    pop ECX
    pop EAX
    ret
printTopOfBoard ENDP
;========================================================================================================================
;========================================================================================================================
printRowsOfBoard PROC, boardOffset : DWORD, rowNum : BYTE, rowLength : BYTE
;description: prints rows of the game board to the console
;receives: boardOffset : DWORD, rowNum : BYTE, rowLength : BYTE
;returns: the rows of the board are printed to the console
;========================================================================================================================
.data
    counterPrint BYTE 0
.code
     push EAX
     push ECX
     mov ESI, boardOffset
     mov EBX, 0
     movzx EDX, rowLength
     movzx ECX, rowLength  
     print:
              
	     INVOKE printCurrentRow, ESI, BL, rowLength
         push EBX
	     call crlf
	     mov counterPrint, 0
	     mov ESI, boardOffset
         inc EBX	
	     ;[go to next row]
	     push ECX
	     movzx ECX, rowNum
	     moveToNextRow:
			add ESI, EDX
	        loop moveToNextRow		
	        pop ECX
	        inc rowNum
            cmp ECX, 1
            je done
		    ;[print spacer row]
		    INVOKE printSpacerRow, rowLength
		    call crlf
          done:
          pop EBX
    loop print
    pop ECX
    pop EAX
    ret
printRowsOfBoard ENDP
;========================================================================================================================
;========================================================================================================================
printCurrentRow PROC, boardOffset : DWORD, rowNum : BYTE, rowLength : BYTE
;description: Works in conjunction with board printing procedures to finish each character to screen in order
;receives: boardOffset : DWORD, rowNum : BYTE, rowLength : BYTE
;returns: the current row of the board is printed to the console
;========================================================================================================================
.data
    endBar BYTE 0BAh
    colSeparater BYTE 0B3h
    spacer BYTE 20h
.code
    push EAX
    push ECX
    push EBX
    ; // this prints one row (first)
        movzx EAX, endBar
        call writeChar
        movzx ECX, rowLength
        mov ESI, boardOffset
	   movzx EBX, rowNum
        clearEAX
        printRow:
            movzx EAX, spacer
            call writeChar
            mov EAX, [ESI + EBX]
            call writeChar
            inc EBX
            movzx EAX, spacer
            call writeChar
            cmp ECX, 1
            je doneThisRow
            movzx EAX, colSeparater
            call writeChar
        loop printRow
        doneThisRow:
        movzx EAX, endBar
        call writeChar
    pop EBX
    pop ECX
    pop EAX
    ret
printCurrentRow ENDP
;========================================================================================================================
;========================================================================================================================
printSpacerRow PROC, numCols:BYTE
;description: Works in conjunction with board printing procedures to finish each character to screen in order
;receives: numCols:BYTE to determine how many columns are in a row
;returns: prints spacer row to console
;========================================================================================================================
.data
    leftSide BYTE       0C7h
    rightSide BYTE      0B6h
    spacerBar BYTE      0C4h
    colSeparaterSR BYTE 0C5h
    barCounterSR BYTE 0
.code
    push EAX
    push ECX    
    mov barCounterSR, 0           						;for continued use
    movzx EAX, leftSide
    call writeChar
    movzx ECX, numCols
    printRowLoopSR:
        printSeparaterBar:
            cmp barCounterSR, 3
            je separateColSR
            movzx EAX, spacerBar
            call writeChar
            inc barCounterSR
            jmp printSeparaterBar
        separateColSR:
            cmp ECX, 1                      			;last column?
            je  endRowSR                    			;if we are, skip printing        
            movzx EAX, colSeparaterSR
            call writeChar
            mov barCounterSR, 0
    loop printRowLoopSR
    endRowSR:
        movzx EAX, rightSide
        call writeChar
    pop ECX
    pop EAX
    ret
printSpacerRow ENDP
;========================================================================================================================
;========================================================================================================================
printBottomOfBoard PROC, numCols:BYTE
;description: Works in conjunction with board printing procedures to finish each character to screen in order
;receives: numCols:BYTE to determine number of rows
;returns: prints bottom of the board to the console
;========================================================================================================================
.data
    leftCornerB BYTE     0C8h
    rightCornerB BYTE    0BCh
    bottomBar BYTE       0CDh
    colSeparaterB BYTE   0CFh
    barCounterB BYTE 0
.code
    push EAX
    push ECX
    mov barCounterB, 0           ; // reset barCounter to 0 to use this proc multiple times
    movzx EAX, leftCornerB
    call writeChar
    movzx ECX, numCols
    printRowLoopB:
        ; // need to do top bar 3 times, then do colSeparater
        printBottomBar:
            cmp barCounterB, 3
            je separateB
            movzx EAX, bottomBar
            call writeChar
            inc barCounterB
            jmp printBottomBar
        separateB:
            cmp ECX, 1                      ; // check if we're printing our last column
            je  endRowB                     ; // if we are, skip printing colSeparater            
            movzx EAX, colSeparaterB
            call writeChar
            mov barCounterB, 0
    loop printRowLoopB
    endRowB:
        movzx EAX, rightCornerB
        call writeChar
    pop ECX
    pop EAX
    ret
printBottomOfBoard ENDP
;========================================================================================================================
;========================================================================================================================
input PROC boardOffset : DWORD 
;Description: this is the bulk of the PvPvP game
; 				Continually prompts the player in a randomly selected order to enter their game board choice
;Recieves: boardOffset : DWORD 
;Returns: N/A
;========================================================================================================================
.data
prompter1 BYTE "Please enter the character where you wish to play (Player 1 - Recall an X will appear in your selection): ", 0h
prompter2 BYTE "Please enter the character where you wish to play (Player 2 - Recall a Y will appear in your selection): ", 0h
prompter3 BYTE "Please enter the character where you wish to play (Player 3 - Recall a Z will appear in your selection): ", 0h
inputErrorprompt BYTE newline, "Cannot Overwrite.  Please Try Again!", 0h
userinput byte ?
checkTorF byte ?
currentPlayer byte ?
firsttime byte 0
.code
     pushad 
     cmp firsttime, 0
     je randomassign
     jmp switchp
     randomassign:
          call Randomize
          mov al, 3
          call RandomRange
          cmp al, 0
          je X
          cmp al, 1
          je Y
          cmp al, 2
          je Z
     X:
          mov currentPlayer, 'X'
          inc firsttime
          jmp inputUser
     Y:
          mov currentPlayer, 'Y'
          inc firsttime
          jmp inputUser 
     Z:
          mov currentPlayer, 'Z'
          inc firsttime
          jmp inputUser 
     switchp:
          invoke switchPlayer, offset currentPlayer

     inputUser:
          .IF(currentPlayer == 'X')             			;if the current player is X, let them know
            MOV EDX, OFFSET prompter1
            Call WriteString
            Call ReadChar
                .IF(AL == 'X')                  			;if they try to write an existing X, prompt an error, and retry
                 MOV EDX, OFFSET inputErrorprompt
                 Call WriteString
                 Call crlf
                 JMP inputUser
                .ENDIF
                .IF(AL == 'Y')                  			;if they try to write an existing Y, prompt an error, and retry
                 MOV EDX, OFFSET inputErrorprompt
                 Call WriteString
                 Call crlf
                 JMP inputUser
                .ENDIF
                .IF(AL == 'Z')                  			;if they try to write an existing Z, prompt an error, and retry
                 MOV EDX, OFFSET inputErrorprompt
                 Call WriteString
                 Call crlf
                 JMP inputUser
                .ENDIF
            MOV userinput, AL
            Call WriteChar
          .ENDIF
          .IF(currentPlayer == 'Y')
            MOV EDX, OFFSET prompter2
            Call WriteString
            Call ReadChar
                .IF(AL == 'X')
                    MOV EDX, OFFSET inputErrorprompt
                    Call WriteString
                    JMP inputUser
                .ENDIF
                .IF(AL == 'Y')
                    MOV EDX, OFFSET inputErrorprompt
                    Call WriteString
                    JMP inputUser
                .ENDIF
                .IF(AL == 'Z')
                    MOV EDX, OFFSET inputErrorprompt
                    Call WriteString
                    JMP inputUser
                .ENDIF
            MOV userinput, AL
            Call WriteChar
            ;///inc endCounter
          .ENDIF
          .IF(currentPlayer == 'Z')
            MOV EDX, OFFSET prompter3
            Call WriteString
            Call ReadChar
                .IF(AL == 'X')
                    MOV EDX, OFFSET inputErrorprompt
                    Call WriteString
                    JMP inputUser
                .ENDIF
                .IF(AL == 'Y')
                    MOV EDX, OFFSET inputErrorprompt
                    Call WriteString
                    Call crlf
                    JMP inputUser
                .ENDIF
                .IF(AL == 'Z')
                    MOV EDX, OFFSET inputErrorprompt
                    Call WriteString
                    Call crlf
                    JMP inputUser
                .ENDIF
            MOV userinput, AL
            Call WriteChar
          .ENDIF
         INVOKE changeValue, boardOffset, userinput, currentPlayer
         RET
input ENDP
;========================================================================================================================
;========================================================================================================================
changeValue PROC boardOffset : DWORD, Userinput1:dword, currentPlayer1: byte 
;Description: After user input, this procedure changes the respective value on the gameboard
;Recieves: boardOffset : DWORD, Userinput1:dword, currentPlayer1: byte 
;Return: N/A
;========================================================================================================================
.data
     endCounter BYTE 0       		;to keep track of the end of the game, when hits 36, end the game
.code 
     pushad
     mov esi, boardOffset
     mov ebx, 0
     start:
          mov eax, 0h
          cmp [esi], eax
          je done
          mov eax, Userinput1
          cmp [esi], AL
          je switch 
          inc esi
          jmp start
     switch:
          INC endCounter            ;place here, because a switch was successful
          mov al, currentPlayer1
          mov [esi], al
          .IF(endCounter == 37)
              INVOKE endGame        ;go to end game, for now we just have a prompt in endGame
          .ENDIF
     done:
     popad
     call crlf
     ret
changeValue ENDP
;========================================================================================================================

;========================================================================================================================
getGameBoard PROC
;Description: Uses the appropriate procedures from above to print the gameboard to the screen with the board array within
;Recieves: N/A
;Returns: N/A
;========================================================================================================================
display:
        call crlf
    INVOKE printTopOfBoard, 6
        call crlf

        INVOKE printRowsOfBoard, offset Board, 1, 6

    INVOKE printBottomOfBoard, 6
    call crlf
    
    INVOKE input, offset Board                                      ;----------[PvP or CvC decided here]---------------------
    jmp display
    
ret
getGameBoard ENDP
;========================================================================================================================
;========================================================================================================================
switchPlayer PROC currentplayerOffset: dword
;Description: After player input, this procedure changes input to next player, creating player turns
;Recieves: currentplayerOffset: dword
;Returns: Next Player
;========================================================================================================================
.data
.code
     pushad 
     mov ebx, [currentplayerOffset]
     mov ecx, 'X'
     mov edx, 'Y'
     mov eax, 'Z'
     cmp [ebx], cl
     je XtoY
     cmp [ebx], dl
     je YtoZ
     cmp [ebx], al
     je ZtoX
     
     XtoY:
          mov [ebx], dl
          jmp done
     YtoZ:
          mov [ebx], al
          jmp done
     ZtoX:
          mov [ebx], cl
          jmp done
     done:
     popad
     ret
switchPlayer ENDP
;========================================================================================================================
;========================================================================================================================
endGame PROC
;//Description: Displays if the game has ended
;//Receives: N/A
;//Returns: N/A
;========================================================================================================================
.data
    theEndPrompt BYTE "The Game Has Ended.", newline, 0h
.code
    
    Call crlf
    Call crlf
    MOV EDX, OFFSET theEndPrompt
    Call WriteString
    Invoke scoreCounter                                                                   ;----------------------------
    Call waitmsg
    RET
endGame ENDP
;========================================================================================================================
;========================================================================================================================
DisplayCVCRules PROC
;//Description: Displays the rules for the CvCvC game-mode to console
;//Recieves: N/A
;//Returns: N/A
;========================================================================================================================
.data
	cvcInstructions BYTE "You Are Playing (Computer vs. Computer vs. Computer Mode)", 0Ah, 0Dh, 
						 "The player with the most tics or tacs or toes in a row of 4 win the game.", 0Ah, 0Dh,
						 "The player who successfully captures the center 4 squares instantly wins the game", 0Ah, 0Dh,0	

	computerNameStringOne	 BYTE 'Computer 1',0		;predetermined names for the computer players
	computerNameOneSize		 BYTE ?
	computerNameStringTwo	 BYTE 'Computer 2',0
	computerNameTwoSize		 BYTE ?
	computerNameStringThree  BYTE 'Computer 3', 0
	computerNameThreeSize	 BYTE ?

.code

    PUSH EBP								
	MOV EBP, ESP
	Call Clrscr                             
	
	MOV EDX, OFFSET cvcInstructions			;print the cvc instructions
	Call WriteString
	Call waitmsg							;waits for user so they have chance to read rules
	Call Clrscr								
											

	INVOKE StartCVCGame, ADDR computerNameStringOne, ADDR computerNameStringTwo, ADDR computerNameStringThree ;Starting CVC mode

	LEAVE
	RET
DisplayCVCRules ENDP
;========================================================================================================================
;========================================================================================================================
StartCVCGame PROC compPlayerOne:PTR BYTE, compPlayerTwo:PTR BYTE, compPlayerThree:PTR BYTE
;Description: This is pretty much just a copy of the PvPvP mode instructions with relevant factors changed for CvCvC
;				Most of it is not used for anything, but I am afraid to touch it, as it is working and isn't causing
;				too much of an issue. 
;Recieves: compPlayerOne:PTR BYTE, compPlayerTwo:PTR BYTE, compPlayerThree:PTR BYTE
;Returns: N/A
;========================================================================================================================
.data
	
	cvcTitle		BYTE " VS. ", 0				
	movNumberCVC    BYTE 0						
	compSelectionOne	DWORD 0					
	compSelectionTwo	DWORD 0					
	compSelectionThree	DWORD 0					
	compOne EQU [compPlayerOne + 4]				
	compTwo EQU [compPlayerTwo + 4]
	compThree EQU [compPlayerThree + 4]
	compNameOffset1		DWORD ?					;to store computer 1 once moved
	compNameOffset2		DWORD ?					;to store computer 2 once moved
	compNameOffset3		DWORD ?					;to store computer 3 once moved
	compFirstGo			BYTE ?					;use as a parameter to remember which player goes first


.code
	
	PUSH EBP				
	MOV EBP, ESP

	MOV EBX, compOne		
	MOV compNameOffset1, EBX					;store comp p1 

	MOV EBX, compTwo
	MOV compNameOffset2, EBX					;store comp p2

	MOV EBX, compThree
	MOV compNameOffset3, EBX					;store comp p3
	
					
												
	pvpGame:									;Prints "Computer1 vs. Computer2 vs. Computer3"
		MOV EDX, compOne						
		Call WriteString
		MOV EDX, OFFSET cvcTitle				
		Call WriteString
		MOV EDX, compTwo						
		Call WriteString
		MOV EDX, OFFSET cvcTitle				
		Call WriteString
		MOV EDX, compThree						
		Call WriteString
		Call crlf
		Call crlf
		INVOKE createRandomArray,0,0,0,0		;Creates a randomArray_computer which will be the collection of moves used for CvCvC

		LEAVE
		RET
StartCVCGame ENDP
;========================================================================================================================
;========================================================================================================================
scoreCounter PROC 
;Description: This is a long procedure, but it is essentially a single algorithm 
; Step0: Checks to see if 4 center squares are filled. If so, the winner is announced
; Step1: The procedure strips the gameboard of every row, column, and diagonal, and places these into separate arrays
; Step2: The procedure then iterate over every row, column, and diagonal as a linear array
; Step3: Every time 3-in-a-row is encountered, the ascii character that has been matched, is moved to an array
; Step4: The procedure then counts the occurence of each letter in the final "3 in a row" array, as every occurence
; 			of a letter within the array is an occurence of a 3-in-a-row
; Step5: The counts for each letter is passed into a display procedure
; Recieves: N/A
; Returns: x_count, y_count, z_count (the number of times each one has a 3 in a row win)
;
;========================================================================================================================
.data
test1 BYTE 'They are the same',0
row1 BYTE 6 DUP(?),0 ;contains positions: 1-6
row2 BYTE 6 DUP(?),0 ;contains positions: 7-12
row3 BYTE 6 DUP(?),0 ;contains positions: 13-18
row4 BYTE 6 DUP(?),0 ;contains positions: 19-24
row5 BYTE 6 DUP(?),0 ;contains positions: 25-30
row6 BYTE 6 DUP(?),0 ;contains positions: 31-36
col1 BYTE 6 DUP(?),0 ;contains positions: 1,7,13,19,25,31
col2 BYTE 6 DUP(?),0 ;contains positions: 2,8,14,20,26,32
col3 BYTE 6 DUP(?),0 ;contains positions: 3,9,15,21,27,33
col4 BYTE 6 DUP(?),0 ;contains positions: 4,10,16,22,28,34
col5 BYTE 6 DUP(?),0 ;contains positions: 5,11,17,23,29,35
col6 BYTE 6 DUP(?),0 ;contains positions: 6,12,18,24,30,36
leftdown1 BYTE 6 DUP(?),0 ;contains positions: 1,8,15,22,29,36
leftdown2 BYTE 6 DUP(?),0 ;contains positions: 2,9,16,23,30
leftdown3 BYTE 6 DUP(?),0 ;contains positions: 3,10,17,24
leftdown4 BYTE 6 DUP(?),0 ;contains positions: 4,11,18
leftdown5 BYTE 6 DUP(?),0 ;contains positions: 7,14,21,28,35
leftdown6 BYTE 6 DUP(?),0 ;contains positions: 13,20,27,34
leftdown7 BYTE 6 DUP(?),0 ;contains positions: 19,26,33
leftup1 BYTE 6 DUP(?),0 ;contains positions: 13,8,3
leftup2 BYTE 6 DUP(?),0 ;contains positions: 19,14,9,4
leftup3 BYTE 6 DUP(?),0 ;contains positions: 25,20,15,10,5
leftup4 BYTE 6 DUP(?),0 ;contains positions: 31,26,21,16,11,6
leftup5 BYTE 6 DUP(?),0 ;contains positions: 32,27,22,17,12
leftup6 BYTE 6 DUP(?),0 ;contains positions: 33,28,23,18
leftup7 BYTE 6 DUP(?),0 ;contains positions: 34,29,24
equivArray BYTE 244 DUP(?), 0
equivCtr BYTE 0
x_count DWORD 0
y_count DWORD 0
z_count DWORD 0
position15 BYTE ?       ;// to store values and check if same
position16 BYTE ?
position21 BYTE ?
position22 BYTE ?
instantWinPrompt BYTE "This player has captured the Middle Squares!, This player INSTANTLY WINS!!!!: ", 0h

.code
    
    clearEAX
    clearEBX
    clearEDX
    clearEDI
    clearESI

    ;----[ROWS STRIPPED HERE]----------------------------------------------------------

    MOV ESI, offset board
    MOV EBX, offset row1            ;----------STRIP ROW 1

    
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    
    mov ebx, offset row2                    ;----------STRIP ROW 2

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx

    mov ebx, offset row3                        ;----------STRIP ROW 3

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx

    mov ebx, offset row4                ;----------STRIP ROW 4

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx

    mov ebx, offset row5                        ;----------STRIP ROW 5

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx

    mov ebx, offset row6                            ;----------STRIP ROW 6

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    inc esi
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al

    ;----[COLUMNS STRIPPED HERE]----------------------------------------------------------

    clearESI
    clearEBX
    mov esi, offset board
    mov ebx, offset col1                            ;---STRIP COLUMN 1

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx

    mov esi, offset board
    mov ebx, offset col2                            ;---STRIP COLUMN 2

    add esi, 1

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx

    mov esi, offset board
    mov ebx, offset col3                            ;---STRIP COLUMN 3

    add esi, 2

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx

    mov esi, offset board
    mov ebx, offset col4                            ;---STRIP COLUMN 4

    add esi, 3

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx

    mov esi, offset board
    mov ebx, offset col5                            ;---STRIP COLUMN 5

    add esi, 4

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx

    mov esi, offset board
    mov ebx, offset col6                            ;---STRIP COLUMN 6

    add esi, 5

    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 6
    inc ebx

    ;-----[Leftdown diagonal stripping]-----------------------------------------------------------------

    clearESI
    clearEBX

    mov ESI, offset board
    mov EBX, offset leftdown1

    mov al, byte ptr[esi]                       ;-----------stripping leftdown diagonal 1
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftdown2

    add esi,1

    mov al, byte ptr[esi]                       ;-----------stripping leftdown diagonal 2
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftdown3

    add esi,2

    mov al, byte ptr[esi]                       ;-----------stripping leftdown diagonal 3
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftdown4

    add esi,3

    mov al, byte ptr[esi]                       ;-----------stripping leftdown diagonal 4
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftdown5

    add ESI, 6

    mov al, byte ptr[esi]                       ;-----------stripping leftdown diagonal 5
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftdown6

    add ESI, 12

    mov al, byte ptr[esi]                       ;-----------stripping leftdown diagonal 6
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftdown7

    add ESI, 18

    mov al, byte ptr[esi]                       ;-----------stripping leftdown diagonal 7
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al
    add esi, 7
    inc ebx
    mov al, byte ptr[esi]
    mov byte ptr[ebx], al



    ;-----[Leftup diagonal stripping]-----------------------------------------------------------------

    clearESI
    clearEBX

    mov ESI, offset board
    mov EBX, offset leftup1                              ;-----------stripping leftup diagonal 1
   
    add ESI, 12

    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al


    mov ESI, offset board
    mov EBX, offset leftup2                              ;-----------stripping leftup diagonal 2
   
    add ESI, 18

    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftup3                              ;-----------stripping leftup diagonal 3
   
    add ESI, 24

    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
     sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftup4                              ;-----------stripping leftup diagonal 4
   
    add ESI, 30

    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftup5                              ;-----------stripping leftup diagonal 5
   
    add ESI, 31

    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al

    mov ESI, offset board
    mov EBX, offset leftup6                              ;-----------stripping leftup diagonal 6
   
    add ESI, 32

    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al


    mov ESI, offset board
    mov EBX, offset leftup7                              ;-----------stripping leftup diagonal 7
   
    add ESI, 33

    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    sub esi, 5
    inc ebx
    mov al, byte ptr[esi]                       
    mov byte ptr[ebx], al
    
    
;----[END STRIPPING]--------------------------------------------------------------------------------------
    MOV ESI, OFFSET row3
    MOV AL, BYTE PTR[ESI + 2]
    MOV position15, AL          ;//has 15th square char
    MOV AL, [ESI + 3]
    MOV position16, AL          ;//AL = 16th square char
        .IF(position15 == AL)
        MOV ESI, OFFSET row4
        MOV AL, BYTE PTR[ESI + 2]
        MOV position21, AL
        MOV AL, BYTE PTR[ESI + 3]
        MOV position22, AL      ;//dont need but getting a copy just incase
            .IF(position21 == AL)
                MOV EDX, OFFSET instantWinPrompt
                Call WriteString
                MOV EDX, OFFSET position15
                Call WriteChar
                Call crlf
                call waitmsg
                EXIT
            .ENDIF
        .ENDIF
;----[Begin ROW, COL, DIAG Analysis]--------------------------------------------------------------------------------
    mov edi, offset equivarray
;----[row scores]------------------------------------------------------------------------------------------
    mov esi, offset row1                            ;-----row1 check

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset row2                            ;-----row2 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

   mov esi, offset row3                            ;-----row3 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset row4                            ;-----row4 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset row5                            ;-----row5 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi
   
    mov esi, offset row6                            ;-----row6 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

;----[column scores]------------------------------------------------------------------------------------------
    mov esi, offset col1                            ;-----col1 check

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset col2                            ;-----col2 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

   mov esi, offset col3                            ;-----col3 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset col4                            ;-----col4 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset col5                            ;-----col5 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi
   
    mov esi, offset col6                            ;-----col6 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

;----[leftdown diagonal scores]------------------------------------------------------------------------------------------
    mov esi, offset leftdown1                       ;-----leftdown1 check

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftdown2                       ;-----leftdown2 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

   mov esi, offset leftdown3                        ;-----leftdown3 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftdown4                       ;-----leftdown4 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftdown5                       ;-----leftdown5 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftdown6                       ;-----leftdown6 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftdown7                       ;-----leftdown7 check

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

;----[leftup diagonal scores]------------------------------------------------------------------------------------------
    mov esi, offset leftup1                       ;-----leftup1 check

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftup2                       ;-----leftup2 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

   mov esi, offset leftup3                        ;-----leftup3 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftup4                         ;-----leftup4 check
    
    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----456
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftup5                         ;-----leftup5 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----345
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftup6                         ;-----leftup6 check
    

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov bl, byte ptr[esi]                           ;----234
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi

    mov esi, offset leftup7                         ;-----leftup7 check

    mov bl, byte ptr[esi]                           ;-----123
    mov bh, byte ptr[esi + 1]
    mov al, byte ptr[esi + 2]
    .IF (BL == BH && BH == AL)
    mov byte ptr[edi], bl
    inc edi
    .ENDIF
    inc esi
;----[END ROW, COL, DIAG Analysis]--------------------------------------------------------------------------------
;---[AFTER ROW/COL/DIAG STRIP AND ROW/COL/DIAG ANALYSIS---> SCORE COUNT]-----------------------------------------------------------
; 
;Welcome to the bottom of this procedure, I know it took awhile to get here. If you are tired, feel free to take a water break.
;

mov esi, offset equivarray			;the following 3 "moves" count the occurence of each 3 in a row win within equivArray
mov ecx, 244
x_count_loop:
    MOV AL, BYTE PTR[ESI]
    .IF (AL == 'X')
    add x_count, 1
    .ENDIF
    inc esi
loop x_count_loop

mov esi, offset equivarray
mov ecx, 244
y_count_loop:
    MOV AL, BYTE PTR[ESI]
    .IF (AL == 'Y')
    add y_count, 1
    .ENDIF
    inc esi
loop y_count_loop

mov esi, offset equivarray
mov ecx, 244
z_count_loop:
    MOV AL, BYTE PTR[ESI]
    .IF (AL == 'Z')
    add z_count, 1
    .ENDIF
    inc esi
loop z_count_loop
   
INVOKE displayEndScore, x_count, y_count, z_count ;Sends info to display scores
EXIT

ret
scoreCounter ENDP
;========================================================================================================================

;========================================================================================================================
displayEndScore  PROC, x_scoreCount: PTR DWORD, y_scoreCount: PTR DWORD, z_scoreCount: PTR DWORD
;Description: Takes in scores from the above procedure, and returns those scores to the console
;Recieves: x_scoreCount: PTR DWORD, y_scoreCount: PTR DWORD, z_scoreCount: PTR DWORD
;Returns: Ends the game
;========================================================================================================================
    .data
    displayEndScore_PromptX BYTE 'X had a score of: ',0
    displayEndScore_PromptY BYTE 'Y had a score of: ',0
    displayEndScore_PromptZ BYTE 'Z had a score of: ',0
    .code
    call crlf
    call crlf
    mov edx, offset displayEndScore_PromptX
    call writestring
    mov eax, x_scoreCount
    call writeint
    call crlf
    mov edx, offset displayEndScore_PromptY
    call writestring
    mov eax, y_scoreCount
    call writeint
    call crlf
    mov edx, offset displayEndScore_PromptZ
    call writestring
    mov eax, z_scoreCount
    call writeint
    call crlf
    call crlf

ret
displayEndScore ENDP
;========================================================================================================================
;========================================================================================================================
createRandomArray PROC, CRA_COUNTER: PTR DWORD, CRAX_count: PTR DWORD, CRAY_count: PTR DWORD, CRAZ_count: PTR DWORD
;Description: Recursively creates a random array
;				Simulates the computer playing itself as CvCvC, each C gets 12 turns.
;Recieves: CRA_COUNTER: PTR DWORD, CRAX_count: PTR DWORD, CRAY_count: PTR DWORD, CRAZ_count: PTR DWORD
;Returns: A randomized array of game moves to be used for CvCvC
;========================================================================================================================
.data
randomArray_computer BYTE 36 DUP(?)

.code
.IF (CRA_COUNTER == 36)											;If 36 moves have been made, the game is over
INVOKE CVCGAME, offset randomArray_computer						;Calls the CVC game mode to display the game moves made
EXIT
.ENDIF
	
mov esi, offset randomArray_computer							
add esi, CRA_COUNTER

MOV EAX, 3
CALL RANDOMRANGE												;selects a pseudo-random number from 0-2

.IF (EAX == 0)													;If 0 = 'X', 1 = 'Y', 2 = 'Z'
    CMP CRAX_count, 12											;Ensures each player only gets 12 moves (no cheating)
    JE DONEX													;Tells procedure to recurse if player has met max moves
    MOV AL, 'X'													;Moving player move to randomArray_computer
    MOV byte ptr[esi], AL
    ADD CRA_COUNTER, 1											;Enforcing the base case
    ADD CRAX_count, 1											;Enforcing max player moves
    DONEX:
    INVOKE createRandomArray, CRA_COUNTER, CRAX_count, CRAY_count, CRAZ_count ;recursive step
.ENDIF
.IF (EAX == 1)
     CMP CRAY_count, 12
     JE DONEY
     MOV AL, 'Y'
     MOV byte ptr[esi], AL
     ADD CRA_COUNTER, 1
     ADD CRAY_count, 1
     DONEY:
     INVOKE createRandomArray, CRA_COUNTER, CRAX_count, CRAY_count, CRAZ_count
.ENDIF
.IF (EAX == 2)
     CMP CRAZ_count, 12
     JE DONEX
     MOV AL, 'Z'
     MOV byte ptr[esi], AL
     ADD CRA_COUNTER, 1
     ADD CRAZ_count, 1
     DONEZ:
     INVOKE createRandomArray, CRA_COUNTER, CRAX_count, CRAY_count, CRAZ_count
.ENDIF
ret
createRandomArray ENDP
;========================================================================================================================
;========================================================================================================================

CVCGAME PROC, CVCGAME_ARRAY: PTR BYTE
;Description: Prints each move to console with a delay so user can watch the game, then shows score
;Recieves: CVCGAME_ARRAY: PTR BYTE
;Returns: N/A
;========================================================================================================================
.data
CVCGAME_GAMEPLAY BYTE 'The players have finished their game. Here are the results', 0
.code

mov edx, offset CVCGAME_GAMEPLAY
call writestring
call crlf

INVOKE getGameBoard_computer			   ;Displays initial gameboard
MOV EAX, 1000							   ;Delays
CALL DELAY

MOV ESI, CVCGAME_ARRAY					   ;Moving randomArray_computer array into place
MOV EDI, offset Board					   ;Moving board characters into place

MOV BL, BYTE PTR[ESI]                      ;MOVE 1
MOV BYTE PTR[EDI], BL					   ;Exchanges first character of board array and randomArray_computer
INVOKE getGameBoard_computer    		   ;Displays to console
INC ESI                                    ;Iterates for further swaps
INC EDI
MOV EAX, 1000							   ;Delays 1 second for user to watch each move
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 2
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 3
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 4
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 5
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 6
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 7
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 8
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 9
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 10
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 11
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 12
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 13
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 14
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 15
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 16
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 17
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 18
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 19
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 20
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 21
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 22
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 23
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 24
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY


MOV BL, BYTE PTR[ESI]                      ;MOVE 25
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 26
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 27
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY


MOV BL, BYTE PTR[ESI]                      ;MOVE 28
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 29
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 30
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY


MOV BL, BYTE PTR[ESI]                      ;MOVE 31
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 32
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 33
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY


MOV BL, BYTE PTR[ESI]                      ;MOVE 34
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 35
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

MOV BL, BYTE PTR[ESI]                      ;MOVE 36
MOV BYTE PTR[EDI], BL
INVOKE getGameBoard_computer
INC ESI
INC EDI
MOV EAX, 1000
CALL DELAY

INVOKE scoreCounter

RET
CVCGAME ENDP
;========================================================================================================================
;========================================================================================================================

getGameBoard_computer PROC
;Description: Works with the CvCvC mode to bypass loop of PvPvP mode
;Recieves: N/A
;Returns: Prints updated CvCvC moves to console
;========================================================================================================================
    PUSH ESI
    PUSH EDI
    call crlf
    INVOKE printTopOfBoard, 6
    call crlf

    INVOKE printRowsOfBoard, offset Board, 1, 6

    INVOKE printBottomOfBoard, 6
    call crlf
    POP EDI
    POP ESI
ret
getGameBoard_computer ENDP
;========================================================================================================================
;========================================================================================================================
;========================================================================================================================
end main
