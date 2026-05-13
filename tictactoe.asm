;*****************************************************************************
; Author: Adia Hite
; Date: 05/08/2026
; Revision: 1.0
;
; Description:  An ASCII game of tic-tac-toe
; Notes:        
;
;
; Register Usage:
;   R0 
;   R1 holds starting address of BOARD
;   R2 holds player number, int
;   R3 holds player number, ASCII
;   R4 iterator
;   R5 
;   R6 
;   R7 
;*****************************************************************************
.ORIG x3000
    
    JSR printRules
    JSR printBoard
    JSR pressEnter

GAMELOOP
    ; player 1 turn
    P1TURN
        AND R1, R1, #0
        ADD R1, R1, #1
        JSR playerTurn
        JSR printBoard
        
        JSR checkWin
        ADD R6, R6, #0
        BRp WINNER
        
        JSR boardFull  ; Check for tie
        ADD R6, R6, #0
        BRp FINISH
        BR P2TURN
        
        
    
    P2TURN 
    ; player 2 turn
        ADD R1, R1, #1
        JSR playerTurn
        JSR printBoard
        
        JSR checkWin
        ADD R6, R6, #0
        BRp WINNER
        
        JSR boardFull  ; Check for tie
        ADD R6, R6, #0
        BRp FINISH
        BR P1TURN
        
WINNER
    ADD R1, R1, #0
    LD R3, C48
    ADD R3, R1, R3
    LEA R0, WINMSG
    PUTS
    ADD R0, R3, #0
    OUT
    LD R0, EXCMNPT
    OUT
    LD R0, NEWL
    OUT
    
    
FINISH 
    HALT

; the board is initially filled ASCII values 1-9
; when p1 marks a space, that space (1-9) is replaced with "X"
; when p2 marks a space, that space (1-9) is replaced with "O"
BOARD   .FILL x31
        .FILL x32
        .FILL x33
        .FILL x34
        .FILL x35
        .FILL x36
        .FILL x37
        .FILL x38
        .FILL x39
NEWL    .FILL x0A
C48     .FILL #48
WINMSG  .STRINGZ "You're a winner, player "
EXCMNPT .FILL x21

;*****************************************************************************  
;                               printBoard
; Description:  print the board
; Notes:        use starting address of board members, printed in the 
;               proper cell within the board.
;
;
; Register Usage:
;   R0 used for TRAP instructions
;   R1 holds starting address of board members
;   R2 used as iterator
;   R3 row number
;   R4 
;   R5 
;   R6 
;   R7 
;*****************************************************************************
printBoard:
; save registers
ST R0, SVR0PB
ST R1, SVR1PB
ST R2, SVR2PB
ST R7, SVR7PB
    
    ;initialize iterator
    AND R2, R2, #0
    ADD R2, R2, #3
    
    LEA R1, BOARD   ; starting address of BOARD in R1
    
    LD R0, NEWLPB
    OUT
    
    LEA R0, HLINE   ; print horizontal line
    PUTS
    LD R0, NEWLPB
    OUT
    
LOOP   
    LEA R0, VLINE
    PUTS   
    LDR R0, R1, #0  ; first element in board row
    OUT
    ADD R1, R1, #1  ; move to next element in board
    LEA R0, VLINE
    PUTS            ; print vertical line
    LDR R0, R1, #0  ; second element
    OUT             
    ADD R1, R1, #1  ; move to next element
    LEA R0, VLINE    
    PUTS
    LDR R0, R1, #0  ; third element
    OUT             
    ADD R1, R1, #1  ; move to next element
    LEA R0, VLINE    
    PUTS
    LD R0, NEWLPB
    OUT
    LEA R0, HLINE
    PUTS
    LD R0, NEWLPB
    OUT
    ADD, R2, R2, #-1 ; DECREMENT
    
    BRz DONE
    BR LOOP
    
    
DONE
; restore registers
LD R0, SVR0PB
LD R1, SVR1PB
LD R2, SVR2PB
LD R7, SVR7PB

RET

SVR7PB  .BLKW #1
SVR1PB  .BLKW #1
SVR2PB  .BLKW #1
SVR0PB  .BLKW #1
VLINE   .STRINGZ " | "
HLINE   .STRINGZ "---------------"
NEWLPB  .FILL x0A

;*****************************************************************************  
;                               printRules
; Description:  print the rules of the game
; Notes:        
;
;
; Register Usage:
;   R0 used for TRAP instructions
;   R1 
;   R2 
;   R3 
;   R4 
;   R5 
;   R6 
;   R7 
;*****************************************************************************
printRules:

; save registers
ST R0, SVR0PR
ST R7, SVR7PR

    LEA R0, TITLE
    PUTS
    LD R0, NEWLPR
    OUT
    LEA R0, HLINE2
    PUTS
    LD R0, NEWLPR
    OUT
    LEA R0, RULE1
    PUTS
    LD R0, NEWLPR
    OUT
    LEA R0, RULE2
    PUTS
    LD R0, NEWLPR
    OUT
    LEA R0, RULE3
    PUTS
    LD R0, NEWLPR
    OUT
    LEA R0, HLINE2
    PUTS
    

; restore registers
LD R0, SVR0PR
LD R7, SVR7PR

RET
    
SVR0PR  .BLKW #1
SVR7PR  .BLKW #1
NEWLPR  .FILL x0A
TITLE   .STRINGZ "            Tic-Tac-Toe            "
HLINE2  .STRINGZ "==================================="
RULE1   .STRINGZ "1. player1 is 'X', player2 is 'O'"
RULE2   .STRINGZ "2. players will take turns, \n   with the goal of marking 3 in a \n   row (horizontal, vertical, \n   or diagonal)."
RULE3   .STRINGZ "3. during each player's turn, they \n   will choose a position for their \n   token, 1-9 "


;*****************************************************************************  
;                               playerTurn
; Description: prompt player for input (1-9), check space is empty, 
; Notes:        
;
;
; Register Usage:
;   R0 for trap instructions
;   R1 holds player number (int passed R1 from main)
;   R2 holds player number ASCII
;   R3 used for calculations / comparisons
;   R4 holds board address location at which changes are made
;   R5 holds player char (X or O)
;   R6 BOOL value, 0 if move invalid, 1 if valid
;   R7 
;*****************************************************************************
playerTurn:

ST R0, SVR0PT
ST R1, SVR1PT
ST R2, SVR2PT
ST R3, SVR3PT
ST R4, SVR4PT
ST R5, SVR5PT
ST R6, SVR6PT
ST R7, SVR7PT

    LD R2, CONST48
    ADD R2, R1, R2  ; convert int in R1 to ascii, store in R2

GETMOVE
    ; print "    Player #     "
    LEA R0, USER
    PUTS            
    ADD R0, R2, #0
    OUT
    LEA R0, SPACES
    PUTS
    LD R0, NEWLPT
    OUT
    
    ; print prompt
    LEA R0, PROMPT
    PUTS
    
    GETC
    JSR checkValid ; returns valid (1) / invalid (0) in R6
    ADD R6, R6, #0
    BRz GETMOVE
   

VALIDMOVE
    ADD R0, R0, #0
    OUT
    ; convert to integer
    LD R3, NEG48
    ADD R0, R0, R3
    
    ; if R1 == 1 : BOARD + R1 - 1 = "X" (x58)
    ; if R1 == 2 : BOARD + R1 - 1 = "O" (x4F)
    ; check user
    ADD R3, R1, #-1
    BRz PLAYER1 ; R1 - 1 = 0
    BRp PLAYER2 ; R1 - 1 = 1
    
PLAYER1
    ; BOARD + R0 - 1 = "X" (x58)
    LD R4, BOARDPT      ; R4 = BOARD
    ADD R4, R4, R0      ; R4 = R0 + BOARD
    ADD R4, R4, #-1      ; R4 = -1 + R0 + BOARD
    LD R5, ASCIIX
    STR R5, R4, #0
    BR DONEPT
    
PLAYER2
    ; BOARD + R0 - 1 = "O"
    LD R4, BOARDPT      ; R4 = BOARD
    ADD R4, R4, R0      ; R4 = R0 + BOARD
    ADD R4, R4, #-1      ; R4 = -1 + R0 + BOARD
    LD R5, ASCIIO
    STR R5, R4, #0
    BR DONEPT
    
    
DONEPT
LD R0, SVR0PT
LD R1, SVR1PT
LD R2, SVR2PT
LD R3, SVR3PT
LD R4, SVR4PT
LD R5, SVR5PT
LD R6, SVR6PT
LD R7, SVR7PT
RET

USER    .STRINGZ "     Player "
SPACES  .STRINGZ "   "
PROMPT  .STRINGZ "Enter space (0-9): "

SVR0PT  .BLKW #1
SVR1PT  .BLKW #1
SVR2PT  .BLKW #1
SVR3PT  .BLKW #1
SVR4PT  .BLKW #1
SVR5PT  .BLKW #1
SVR6PT  .BLKW #1
SVR7PT  .BLKW #1

NEWLPT  .FILL x0A
CONST48 .FILL #48
NEG48   .FILL #-48
ASCIIX  .FILL x58
ASCIIO  .FILL x4F

BOARDPT .FILL BOARD

;*****************************************************************************  
;                               checkValid
; Description: checks if player move is valid
; Notes:    user-entered val should be 1-9
;           space cannot be taken
;
;
; Register Usage:
;   R0 holds user entered value from playerTurn()
;   R1 used for calculations
;   R2 holds board-location address according to user-entered value
;   R3 holds contents @ board-location address in R2
;   R4 
;   R5 
;   R6 RETURN - 0 if invalid, 1 if valid
;   R7 
;*****************************************************************************
checkValid:

ST R0, SVR0CV
ST R1, SVR1CV
ST R2, SVR2CV
ST R3, SVR3CV
ST R7, SVR7CV

; convert R0, user-entered value, atoi
    LD R1, NEG48CV
    ADD R0, R0, R1

    AND R6, R6, #0  ; initialize R6 to 0 (false)

; check value is 1-9
    ADD R1, R0, #-9 ; if R1 > 0, then R0 > 9
    BRp INVALIDCV
    ADD R1, R0, #-1 ; if R1 < 0, then R0 < 1
    BRn INVALIDCV
; If NO BRANCH to INVALID, value is between 1-9
; Ensure location on board (BOARD + (RO -1)) does NOT contain X or O

; load board location (BOARD + R0 - 1) into R2
    LD R2, BOARDCV
    ADD R2, R2, R0
    ADD R2, R2, #-1
    LDR R3, R2, #0  ; cell contents of address
; check cell for x
    LD R1, CHARXCV
    NOT R1, R1
    ADD R1, R1, #1   ; R1 = -'X'
    ADD R1, R3, R1
    BRz INVALIDCV      ; cell contains X
; check cell for O
    LD R1, CHAROCV
    NOT R1, R1
    ADD R1, R1, #1   ; R1 = -'O'
    ADD R1, R3, R1
    BRz INVALIDCV    ; cell contains O


; if NO BRANCH to INVALID, move is VALID
VALIDCV
    ADD R6, R6, #1
    BR DONECV
    
INVALIDCV
    LEA R0, INVALID
    PUTS
    LD R0, NEWLCV
    OUT
    ADD R6, R6, #0
    BR DONECV

DONECV
; RESTORE registers
    LD R0, SVR0CV
    LD R1, SVR1CV
    LD R2, SVR2CV
    LD R3, SVR3CV
    LD R7, SVR7CV
RET


SVR0CV  .BLKW #1
SVR1CV  .BLKW #1
SVR2CV  .BLKW #1
SVR3CV  .BLKW #1
SVR7CV  .BLKW #1
NEG48CV .FILL #-48
BOARDCV .FILL BOARD
CHARXCV .FILL x58
CHAROCV .FILL x4F
INVALID .STRINGZ "Invalid move. Try Again."
NEWLCV  .FILL x0A

;*****************************************************************************  
;                               checkWin
; Description:  check for win for designated player
; Notes:        check horizontal, vertical, diagonal
;
;
; Register Usage:
;   R0 used for calculations + TRAP
;   R1 player num, passed from main
;   R2 value to check for
;   R3 starting address of board loc being checked
;   R4 holds value held at board address
;   R5 
;   R6 return val - ret 1 if win, 0 if no win
;   R7 
;*****************************************************************************
checkWin:

; save registers
    ST R0, CW_R0
    ST R1, CW_R1
    ST R2, CW_R2
    ST R3, CW_R3
    ST R4, CW_R4
    ST R7, CW_R7

; initialize R3 with board address
    LD R3, BOARDCW
; initialize R6 with 0
    AND R6, R6, #0

; determine if player 1 or 2
    ADD R0, R1, #-1
    BRz P1CHECK
    BRp P2CHECK
P1CHECK     ; set value to check for to 'X'    
    LD R2, CHARXCW
    NOT R2, R2
    ADD R2, R2, #1 ; R2 = -'X' 
    BR CWSTART
P2CHECK     ; set value to check for to 'O'
    LD R2, CHAROCW
    NOT R2, R2
    ADD R2, R2, #1 ; R2 = -'O'
    BR CWSTART
CWSTART
    
HORIZONTAL_CW
    
    ROW0 ; 0,1,2
        LDR R4, R3, #0
        ADD R0, R4, R2
        BRnp ROW1
        LDR R4, R3, #1
        ADD R0, R4, R2
        BRnp ROW1
        LDR R4, R3, #2
        ADD R0, R4, R2
        BRnp ROW1
        BR WIN_CW
    ROW1 ;3,4,5
        LDR R4, R3, #3
        ADD R0, R4, R2
        BRnp ROW2
        LDR R4, R3, #4
        ADD R0, R4, R2
        BRnp ROW2
        LDR R4, R3, #5
        ADD R0, R4, R2
        BRnp ROW2
        BR WIN_CW
    ROW2 ; 6,7,8
        LDR R4, R3, #6
        ADD R0, R4, R2
        BRnp VERTICAL_CW
        LDR R4, R3, #7
        ADD R0, R4, R2
        BRnp VERTICAL_CW
        LDR R4, R3, #8
        ADD R0, R4, R2
        BRnp VERTICAL_CW
        BR WIN_CW
    

VERTICAL_CW
    COL0 ; 0 3 6
        LDR R4, R3, #0
        ADD R0, R4, R2
        BRnp COL1
        LDR R4, R3, #3
        ADD R0, R4, R2
        BRnp COL1
        LDR R4, R3, #6
        ADD R0, R4, R2
        BRnp COL1
        BR WIN_CW
    COL1 ; 1 4 7
        LDR R4, R3, #1
        ADD R0, R4, R2
        BRnp COL2
        LDR R4, R3, #4
        ADD R0, R4, R2
        BRnp COl2
        LDR R4, R3, #7
        ADD R0, R4, R2
        BRnp COL2
        BR WIN_CW
    COL2 ; 2 5 8
        LDR R4, R3, #2
        ADD R0, R4, R2
        BRnp DIAGONAL_CW
        LDR R4, R3, #5
        ADD R0, R4, R2
        BRnp DIAGONAL_CW
        LDR R4, R3, #8
        ADD R0, R4, R2
        BRnp COL2
        BR WIN_CW
        
DIAGONAL_CW
    DGN0 ; 0 4 8
        LDR R4, R3, #0
        ADD R0, R4, R2
        BRnp DGN1
        LDR R4, R3, #4
        ADD R0, R4, R2
        BRnp DGN1
        LDR R4, R3, #8
        ADD R0, R4, R2
        BRnp DGN1
        BR WIN_CW
    DGN1 ; 2 4 6
        LDR R4, R3, #2
        ADD R0, R4, R2
        BRnp NOWIN_CW
        LDR R4, R3, #4
        ADD R0, R4, R2
        BRnp NOWIN_CW
        LDR R4, R3, #6
        ADD R0, R4, R2
        BRnp NOWIN_CW
        BR WIN_CW

WIN_CW
    ADD R6, R6, #1

NOWIN_CW
    ADD R6, R6, #0
; restore registers
LD R0, CW_R0
LD R1, CW_R1
LD R2, CW_R2
LD R3, CW_R3
LD R4, CW_R4
LD R7, CW_R7

RET
BOARDCW .FILL BOARD
CHARXCW .FILL x58
CHAROCW .FILL x4F

CW_R0 .BLKW #1
CW_R1 .BLKW #1
CW_R2 .BLKW #1
CW_R3 .BLKW #1
CW_R4 .BLKW #1
CW_R7 .BLKW #1


;*****************************************************************************  
;                               boardFull
; Description:  checks the board is full
; Notes:        return 1 if full, 0 if not
;
;
; Register Usage:
;   R0 
;   R1 board starting address
;   R2 tracks what's held @ address
;   R3 used for comparison / calculation
;   R4 counter
;   R5 address being checked
;   R6 return value - 0 for not full, 1 for full
;   R7 
;*****************************************************************************
boardFull:

; Save registers
ST R0, BF_R0
ST R1, BF_R1
ST R2, BF_R2
ST R3, BF_R3
ST R4, BF_R4
ST R5, BF_R5
ST R7, BF_R7

; initialize R6, R4, R1
    AND R6, R6, #0  ; R6 = 0
    AND R4, R4, #0
    LD R1, BRD_BF

LOOP_BF
        ADD R5, R1, R4
        LDR R2, R5, #0
    CHECK_X_BF
        LD R3, X_BF
        NOT R3, R3
        ADD R3, R3, #1 ; R3 = -'X'
        ADD R3, R2, R3
        BRz CHECK_COUNTER   ; IS 'X'
        BR CHECK_O_BF
    
    CHECK_O_BF
        LD R3, O_BF
        NOT R3, R3
        ADD R3, R3, #1 ; R3 = -'O'
        ADD R3, R2, R3
        BRz CHECK_COUNTER
        BR NOT_FULL
    
    CHECK_COUNTER
        LD R3, NEG8_BF
        ADD R3, R4, R3
        BRz BOARD_FULL
        ADD R4, R4, #1
        BR LOOP_BF
        

BOARD_FULL
    LEA R0,FULLSTR
    PUTS
    LD R0, NL_BF
    OUT
    ADD R6, R6, #1
    BR DONE_BF

NOT_FULL
    ADD R6, R6, #0
    BR DONE_BF
    
DONE_BF
    ; restore registers
LD R0, BF_R0
LD R1, BF_R1
LD R2, BF_R2
LD R3, BF_R3
LD R4, BF_R4
LD R5, BF_R5
LD R7, BF_R7
    RET
    

BRD_BF  .FILL BOARD
X_BF    .FILL x58
O_BF    .FILL x4F
NEG8_BF .FILL #-8
FULLSTR .STRINGZ "There's a tie! Board is full."
NL_BF   .FILL x0A

BF_R0   .BLKW #1
BF_R1   .BLKW #1
BF_R2   .BLKW #1
BF_R3   .BLKW #1
BF_R4   .BLKW #1
BF_R5   .BLKW #1
BF_R7   .BLKW #1

;*****************************************************************************  
;                               pressEnter
; Description:  prompts user to press enter, freezes until user does so
; Notes:        
;
;
; Register Usage:
;   R0 used for TRAP
;   R1 holds value for comparison (~'ENTER' + 1 == --'ENTER')
;   R2 used for calculation
;   R3 
;   R4 
;   R5 
;   R6 
;   R7 
;*****************************************************************************
pressEnter:
; SAVE registers
ST R0, PE_R0
ST R1, PE_R1
ST R2, PE_R2
ST R7, PE_R7

    LEA R0, PE_PROMPT
    PUTS

    ; initialize R1 with -'\n'
    LD R1, ENTER
    NOT R1, R1
    ADD R1, R1, #1 ; R1 = -'ENTER'
    
    
PE_LOOP
    GETC 
    ADD R2, R0, R1 ; R2 = user-value - 'ENTER'
    BRz PE_DONE
    BR PE_LOOP
PE_DONE
    OUT
; restore registers
LD R0, PE_R0
LD R1, PE_R1
LD R2, PE_R2
LD R7, PE_R7

RET
    
ENTER   .FILL x0A
PE_PROMPT   .STRINGZ "Press enter to continue..."
PE_R0   .BLKW #1
PE_R1   .BLKW #1
PE_R2   .BLKW #1
PE_R7   .BLKW #1

.END