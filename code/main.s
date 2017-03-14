.include "constants.s"

################################################################################
# DATA
################################################################################
.section .data

####################
# SOUNDS
oneUp:
	.incbin		"W:/project/sounds/oneUp.wav"
oneUpEND:
boop:
	.incbin		"W:/project/sounds/boop.wav"
boopEND:
error:
	.incbin		"W:/project/sounds/error.wav"
errorEND:
goSND:
	.incbin		"W:/project/sounds/goSND.wav"
goSNDEND:

####################
# IMAGES
	.align		1
background:
	.hword		320
	.hword		240
	.incbin		"W:/project/images/Background.bin"
goIMG:
	.hword		212
	.hword		212
	.incbin		"W:/project/images/goIMG.bin"
pikachu:
	.hword		64
	.hword		64
	.incbin		"W:/project/images/pikachu.bin"
bulbasaur:
	.hword		64
	.hword		64
	.incbin		"W:/project/images/bulbasaur.bin"
charmander:
	.hword		64
	.hword		64
	.incbin		"W:/project/images/charmander.bin"
squirtle:
	.hword		64
	.hword		64
	.incbin		"W:/project/images/squirtle.bin"

.global gb0
gb0:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/0.bin"
.global gb1
gb1:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/1.bin"
.global gb2
gb2:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/2.bin"
.global gb3
gb3:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/3.bin"
.global gb6
gb6:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/6.bin"
.global gb12
gb12:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/12.bin"
.global gb24
gb24:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/24.bin"
.global gb48
gb48:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/48.bin"
.global gb96
gb96:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/96.bin"
.global gb192
gb192:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/192.bin"
.global gb384
gb384:
	.hword		50
	.hword		50
	.incbin		"W:/project/images/384.bin"

####################
# GRID

	.align		2
	.word		0xF0F0F0F0
.global BOARD
BOARD:
	
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	
.global BOARD2
BOARD2:
	
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	.word		0
	
	.word		0xF0F0F0F0
	
.global BOARDNUMBER
BOARDNUMBER:
	.word		1

################################################################################
# MAIN
################################################################################
.section .text

.global main
main:

	# initialize the stack
	movia	sp, STACK_BASE
	
reset:
	#Initialize the board
	movia	r4, BOARD
	movi	r5, 1
	call    spawnNumber
	movia	r4, BOARD
	movi	r5, 1
	call    spawnNumber
	
loop:
	
	############################################################################
	# GAME LOGIC

	#Let player move until board is full
	gameLoop:
		call	PRINTSCREEN
	
		#Make the "phantom" board to check
		call    SETBOARDSEQUAL

		#Wait for the player to make a move
		movi	r2, 1
		movia	r3, BOARDNUMBER
		stwio	r2, 0(r3)
		call    PLAYERMOVE
		mov		r18, r2

		#Check if the move was valid
		call    BOARDSEQUAL
		bne    	r2,r0, errorBoop
		br		boardMove
		
		errorBoop:
			movia	r4, error
			movia	r5, errorEND
			call	playSound
			br		gameLoop2


	#Move was valid, move the board
	boardMove:
		movia	r4, boop
		movia	r5, boopEND
		call	playSound
		movia	r4, BOARD
		mov		r5, r18
		call    spawnNumber
		br    	gameLoop2


	#Continue the game loop
	gameLoop2:

		#Check if the game is over
		call    GAMEOVERCHECK
		beq    	r2,r0,loop
		call	PRINTSCREEN

	gameOver:
	
		# DISPLAY GAME OVER STUFF
		movia	r4, goIMG
		movui	r5, 15
		movui	r6, 14
		call	drawImage
		
		movia	r4, goSND
		movia	r5, goSNDEND
		call	playSound
		
		call	getInput
		call	CLEARBOARDS
		br		reset
		
################################################################################
# FUNCIONS
################################################################################
#-------------------------------------------------------------------------------
#BOARDFULL (Checks whether the board is full, returns a bool)
#
# r4	1 or 2 (BOARD OR BOARD2)
.global PRINTSCREEN
PRINTSCREEN:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

	call	SETBOARDSEQUAL
	############################################################################
	# REDRAW BACKGROUND
	movia	r4, background
	movui	r5, 0
	movui	r6, 0
	call	drawImage
	
	############################################################################
	# REDRAW THE BOARD
	mov		r16, zero
	whileDraw:
		movi	r2, 16
		bge 	r16, r2, doneWhileDraw
		
		mov		r4, r16
		call	drawGridBox
		
		addi	r16, r16, 1
		br		whileDraw
	doneWhileDraw:
	
	############################################################################
	# REDRAW THE SCORE
	mov		r16, zero
	mov		r17, zero
	whileGetScore:
		movi	r2, 16
		bge 	r16, r2, doneWhileGetScore
		
		muli	r3, r16, 4
		movia	r2, BOARD
		add		r3, r3, r2		# get grid+offset in words
		ldw		r2, (r3)
		
		add		r17, r17, r2
		
		addi	r16, r16, 1
		br		whileGetScore
	doneWhileGetScore:
		mov		r4, r17
		call	drawScore
	
PRINTSCREEN_DONE:
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	
	ret


#-------------------------------------------------------------------------------
#BOARDFULL (Checks whether the board is full, returns a bool)
#
# r4	1 or 2 (BOARD OR BOARD2)
.global BOARDFULL
BOARDFULL:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

	#r16 is a pointer to the board
	movi	r2, 1
	beq		r4, r2, BOARDFULL_set1
    br		BOARDFULL_set2
	
	BOARDFULL_set1:
		movia	r16, BOARD
		br		BOARDFULL_doneSet
	BOARDFULL_set2:
		movia	r16, BOARD2
		br		BOARDFULL_doneSet
	BOARDFULL_doneSet:
	

    #r20 is a counter for the loop
    movi    r20, 1

	#Iterate through the boards
	boardsEqualLoop:

		#r18 will store the value
		ldwio   r18, 0(r16)
		beq    	r18, r0, BOARDFULL_notFull
		addi    r16, r16, 4
		addi    r20, r20, 1
		movia	r3, 16
		bgt    	r20, r3, BOARDFULL_full   
		
		br		boardsEqualLoop

	BOARDFULL_full:
		movi	r2, 1
		br		BOARDFULL_DONE

	BOARDFULL_notFull:
		movi	r2, 0
		br		BOARDFULL_DONE

	BOARDFULL_DONE:
	
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	
	ret

#-------------------------------------------------------------------------------
#MOVEHELPER (Moves space b to space a, if possible)

MOVEHELPER:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

	movia	r2, BOARDNUMBER
	ldw		r3,	0(r2)
	movi	r2, 1
	beq		r3, r2, MOVEHELPER_SET1
	br		MOVEHELPER_SET2
	
MOVEHELPER_SET1:
	movia   r16, BOARD
	br		MOVEHELPER_DONESET
		
MOVEHELPER_SET2:
	movia	r16, BOARD2
	br		MOVEHELPER_DONESET

MOVEHELPER_DONESET:
	#Store a in r17
	muli	r4, r4, 4
	add    	r2, r16, r4
	ldw		r17, 0(r2)
	
	#Store b in r18
	muli	r5, r5, 4
	add		r3, r16, r5
	ldw		r18, 0(r3)

#Compare the numbers to determine what should happen
MOVEHELPER_CHECKEMPTY:
	beq		r17, r0, numCanMove
MOVEHELPER_CHECKSAME:
	beq		r17, r18, MOVEHELPER_CHECKLARGE
	br		MOVEHELPER_CHECKSUM
MOVEHELPER_CHECKLARGE:
	add		r19, r17, r18
	movi	r20, 4
	bgt		r19, r20, numCombine
	br		MOVEHELPER_DONE
MOVEHELPER_CHECKSUM:
	add		r19, r17, r18
	movi 	r20, 3
	beq		r19, r20, numCombine
	br		MOVEHELPER_DONE

#There is an empty space we can move to
numCanMove:
	stw		r18, 0(r2)
	stw		r0, 0(r3)
	br		MOVEHELPER_DONE

#The two numbers are the same and can combine
numCombine:
	add		r17, r17, r18
	stw		r17, 0(r2)
	stw		r0, 0(r3)
	br     	MOVEHELPER_DONE
	
MOVEHELPER_DONE:
	
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	
	ret
	
#-------------------------------------------------------------------------------

#MOVE (performs one row of moves on a,b,c,d)
MOVE:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

	
	mov		r16, r4
	mov		r17, r5
	mov		r18, r6
	mov		r19, r7
    #Call movehelper on a&b then b&c then c&d
	
	mov		r4, r16
	mov		r5, r17
    call    MOVEHELPER
    mov		r4, r17
	mov		r5, r18
    call    MOVEHELPER
    mov		r4, r18
	mov		r5, r19
    call    MOVEHELPER
	
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40

    ret

#-------------------------------------------------------------------------------
#PLAYERMOVE (gets input and returns 1(w), 2(a), 3(s), 4(d))
PLAYERMOVE:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40
	
	call	getInput
	mov		r23, r2

    #Determine which direction the move is in
    movi   r16, 1
    beq    r2, r16, playerMoveUp
    movi   r16, 2
    beq    r2, r16, playerMoveLeft
    movi   r16, 3
    beq    r2, r16, playerMoveDown
    movi   r16, 4
    beq    r2, r16, playerMoveRight


#Performs a "Up" move
playerMoveUp:
    movi    r4, 0
    movi    r5, 4
    movi    r6, 8
    movi    r7, 12
    call    MOVE
    movi    r4, 1
    movi    r5, 5
    movi    r6, 9
    movi    r7, 13
    call    MOVE
    movi    r4, 2
    movi    r5, 6
    movi    r6, 10
    movi    r7, 14
    call    MOVE
    movi    r4, 3
    movi    r5, 7
    movi    r6, 11
    movi    r7, 15
    call    MOVE
    br		PLAYERMOVE_DONE


#Performs a "Left" move
playerMoveLeft:
    movi    r4, 0
    movi    r5, 1
    movi    r6, 2
    movi    r7, 3
    call    MOVE
    movi    r4, 4
    movi    r5, 5
    movi    r6, 6
    movi    r7, 7
    call    MOVE
    movi    r4, 8
    movi    r5, 9
    movi    r6, 10
    movi    r7, 11
    call    MOVE
    movi    r4, 12
    movi    r5, 13
    movi    r6, 14
    movi    r7, 15
    call    MOVE
    br		PLAYERMOVE_DONE

#Performs a "Down" move
playerMoveDown:
    movi    r4, 12
    movi    r5, 8
    movi    r6, 4
    movi    r7, 0
    call    MOVE
    movi    r4, 13
    movi    r5, 9
    movi    r6, 5
    movi    r7, 1
    call    MOVE
    movi    r4, 14
    movi    r5, 10
    movi    r6, 6
    movi    r7, 2
    call    MOVE
    movi    r4, 15
    movi    r5, 11
    movi    r6, 7
    movi    r7, 3
    call    MOVE
    br		PLAYERMOVE_DONE
	
#Performs a "Right" move
playerMoveRight:
    movi    r4, 3
    movi    r5, 2
    movi    r6, 1
    movi    r7, 0
    call    MOVE
    movi    r4, 7
    movi    r5, 6
    movi    r6, 5
    movi    r7, 4
    call    MOVE
    movi    r4, 11
    movi    r5, 10
    movi    r6, 9
    movi    r7, 8
    call    MOVE
    movi    r4, 15
    movi    r5, 14
    movi    r6, 13
    movi    r7, 12
    call    MOVE
    br		PLAYERMOVE_DONE
	

PLAYERMOVE_DONE:

	mov		r2, r23

	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	
    ret
#-------------------------------------------------------------------------------

#COMPUTERMOVE (simulates a move to check if game is over)

COMPUTERMOVE:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

    #Determine which direction the move is in
    movi   r16, 1
    beq    r4, r16, computerMoveUp
    movi   r16, 2
    beq    r4, r16, computerMoveLeft
    movi   r16, 3
    beq    r4, r16, computerMoveDown
    movi   r16, 4
    beq    r4, r16, computerMoveRight


#Performs a "Up" move
computerMoveUp:
    movi    r4, 0
    movi    r5, 4
    movi    r6, 8
    movi    r7, 12
    call    MOVE
    movi    r4, 1
    movi    r5, 5
    movi    r6, 9
    movi    r7, 13
    call    MOVE
    movi    r4, 2
    movi    r5, 6
    movi    r6, 10
    movi    r7, 14
    call    MOVE
    movi    r4, 3
    movi    r5, 7
    movi    r6, 11
    movi    r7, 15
    call    MOVE
    br		COMPUTERMOVE_DONE


#Performs a "Left" move
computerMoveLeft:
    movi    r4, 0
    movi    r5, 1
    movi    r6, 2
    movi    r7, 3
    call    MOVE
    movi    r4, 4
    movi    r5, 5
    movi    r6, 6
    movi    r7, 7
    call    MOVE
    movi    r4, 8
    movi    r5, 9
    movi    r6, 10
    movi    r7, 11
    call    MOVE
    movi    r4, 12
    movi    r5, 13
    movi    r6, 14
    movi    r7, 15
    call    MOVE
    br		COMPUTERMOVE_DONE

#Performs a "Down" move
computerMoveDown:
    movi    r4, 12
    movi    r5, 8
    movi    r6, 4
    movi    r7, 0
    call    MOVE
    movi    r4, 13
    movi    r5, 9
    movi    r6, 5
    movi    r7, 1
    call    MOVE
    movi    r4, 14
    movi    r5, 10
    movi    r6, 6
    movi    r7, 2
    call    MOVE
    movi    r4, 15
    movi    r5, 11
    movi    r6, 7
    movi    r7, 3
    call    MOVE
    br		COMPUTERMOVE_DONE
	
#Performs a "Right" move
computerMoveRight:
    movi    r4, 3
    movi    r5, 2
    movi    r6, 1
    movi    r7, 0
    call    MOVE
    movi    r4, 7
    movi    r5, 6
    movi    r6, 5
    movi    r7, 4
    call    MOVE
    movi    r4, 11
    movi    r5, 10
    movi    r6, 9
    movi    r7, 8
    call    MOVE
    movi    r4, 15
    movi    r5, 14
    movi    r6, 13
    movi    r7, 12
    call    MOVE
    br		COMPUTERMOVE_DONE

COMPUTERMOVE_DONE:
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	
    ret
#-------------------------------------------------------------------------------

#BOARDSEQUAL (checks if a move produces a change and is valid)
BOARDSEQUAL:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

    #r16 and r17 are pointers to the boards
    movia   r16, BOARD
    movia   r17, BOARD2
	
    #r2 is whether or not they are equal
    movi    r2, 1

    #r20 is a counter for the loop
    movi    r20, 1

#Iterate through the boards
BOARDSEQUAL_boardsEqualLoop:

    #r18 and r19 will store the values on each board
    ldwio   r18, 0(r16)
    ldwio   r19, 0(r17)
    bne 	r18, r19, boardsEqualNot
    addi    r16, r16, 4
    addi    r17, r17, 4
    addi    r20, r20, 1
	
	movi	r3, 16
    bgt    	r20, r3, boardsEqual2    
    br		BOARDSEQUAL_boardsEqualLoop

# Return
boardsEqual2:
    br		BOARDSEQUAL_DONE

#One of the squares was not equal, break
boardsEqualNot:
    movi    r2, 0
    br    boardsEqual2
	
BOARDSEQUAL_DONE:
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	ret

#-------------------------------------------------------------------------------

#SETBOARDSEQUAL (copies BOARD to BOARD2)
.global SETBOARDSEQUAL
SETBOARDSEQUAL:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

    #r16 and r17 are pointers to the boards
    movia   r16, BOARD
    movia   r17, BOARD2

    #r19 is a counter for the loop
    movi    r19, 1

#Iterate through the boards
setBoardsEqualLoop:

    #r18 takes from BOARD and stores in BOARD2
    ldwio    r18, 0(r16)
    stwio    r18, 0(r17)

    #We increment by one position every loop
    addi   	r16, r16, 4
    addi    r17, r17, 4
    addi    r19, r19, 1
	
	movi	r3, 17
    blt    	r19, r3, setBoardsEqualLoop
	
SETBOARDSEQUAL_DONE:
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	ret
	
#-------------------------------------------------------------------------------
.global CLEARBOARDS
CLEARBOARDS:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

    #r16 and r17 are pointers to the boards
    movia   r16, BOARD
    movia   r17, BOARD2

    #r19 is a counter for the loop
    movi    r19, 1

#Iterate through the boards
clearBoardsLoop:

    #r18 takes from BOARD and stores in BOARD2
    stwio    r0, 0(r16)
    stwio    r0, 0(r17)

    #We increment by one position every loop
    addi   	r16, r16, 4
    addi    r17, r17, 4
    addi    r19, r19, 1
	
	movi	r3, 17
    blt    	r19, r3, clearBoardsLoop
	
CLEARBOARDS_DONE:
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	ret


#-------------------------------------------------------------------------------

#GAMEOVERCHECK (performs all 4 moves to see if the game is over)

GAMEOVERCHECK:

	# push regs on stack
	addi	sp, sp, -40
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	stw		r18, 8(sp)
	stw		r19, 12(sp)
	stw		r20, 16(sp)
	stw		r21, 20(sp)
	stw		r22, 24(sp)
	stw		r23, 28(sp)
	stw		ra, 32(sp)
	stw		fp, 36(sp)
	addi	fp, sp, 40

    #r16 and r17 are pointers to BOARD and BOARD2
    movia   r16, BOARD
    movia   r17, BOARD2

    #r18 is the boardsequal flag
    movi    r18, 0

    #Make move number 1
	call	SETBOARDSEQUAL
	movi	r2, 2
	movia	r3, BOARDNUMBER
	stwio	r2, 0(r3)
    movi    r4, 1
    call    COMPUTERMOVE
	call	BOARDSEQUAL
    beq		r2, r0, GAMEOVERCHECK_notGameOver

    #Make move number 2
	call	SETBOARDSEQUAL
	movi	r2, 2
	movia	r3, BOARDNUMBER
	stwio	r2, 0(r3)
    movi    r4, 2
    call    COMPUTERMOVE
	call	BOARDSEQUAL
    beq		r2, r0, GAMEOVERCHECK_notGameOver

    #Make move number 3
	call	SETBOARDSEQUAL
	movi	r2, 2
	movia	r3, BOARDNUMBER
	stwio	r2, 0(r3)
    movi    r4, 3
    call    COMPUTERMOVE
	call	BOARDSEQUAL
    beq		r2, r0, GAMEOVERCHECK_notGameOver

    #Make move number 4
	call	SETBOARDSEQUAL
	movi	r2, 2
	movia	r3, BOARDNUMBER
	stwio	r2, 0(r3)
    movi    r4, 4
    call    COMPUTERMOVE
	call	BOARDSEQUAL
    beq		r2, r0, GAMEOVERCHECK_notGameOver
	
    br    	GAMEOVERCHECK_gameOver

GAMEOVERCHECK_notGameOver:
    movi    r2, 0
    br		GAMEOVERCHECK_DONE

GAMEOVERCHECK_gameOver:   
    movi	r2, 1
	br		GAMEOVERCHECK_DONE
	
GAMEOVERCHECK_DONE:
	# pop regs off stack
	ldw		r16, 0(sp)
	ldw		r17, 4(sp)
	ldw		r18, 8(sp)
	ldw		r19, 12(sp)
	ldw		r20, 16(sp)
	ldw		r21, 20(sp)
	ldw		r22, 24(sp)
	ldw		r23, 28(sp)
	ldw		ra, 32(sp)
	ldw		fp, 36(sp)
	addi	sp, sp, 40
	ret

#-------------------------------------------------------------------------------



################################################################################
# empty line
################################################################################
