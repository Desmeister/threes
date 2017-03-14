.include "constants.s"
.section .text

################################################################################
# playerMove
################################################################################
# r16	keyPressed

.global getInput
getInput:

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

	getKey:
	# wait for first input
	movia	r3, PS2_DATA
	ldw		r2, (r3)
	andi	r4, r2, 0x8000
	beq		r4, zero, getKey
	andi	r4, r2, 0x00FF
	
	# check input
	movi	r2, PS2_MAKE_W
	beq		r4, r2, wKey		# pressed W
	movi	r2, PS2_MAKE_A
	beq		r4, r2, aKey		# pressed A
	movi	r2, PS2_MAKE_S
	beq		r4, r2, sKey		# pressed S
	movi	r2, PS2_MAKE_D
	beq		r4, r2, dKey		# pressed D
	br		getKey				# pressed something else, get new key
	
	# remember the first key
	wKey:
		movi	r16, PS2_MAKE_W 
		br		waitForRelease
	aKey:
		movi	r16, PS2_MAKE_A
		br		waitForRelease
	sKey:
		movi	r16, PS2_MAKE_S
		br		waitForRelease
	dKey:
		movi	r16, PS2_MAKE_D
		br		waitForRelease
	
	# wait until a key is released
	waitForRelease:
		movia	r3, PS2_DATA
		ldw		r2, (r3)
		andi	r4, r2, 0x8000
		beq		r4, zero, waitForRelease
		andi	r4, r2, 0x00FF
		
		movi	r2, PS2_BREAK
		beq		r4, r2, checkReleaseWasOriginalKey
		br		waitForRelease
		
	checkReleaseWasOriginalKey:
		movia	r3, PS2_DATA
		ldw		r2, (r3)
		andi	r4, r2, 0x8000
		beq		r4, zero, checkReleaseWasOriginalKey
		andi	r4, r2, 0x00FF
		
		beq		r4, r16, setRet # Original key was released
		br		waitForRelease # otherwise, keep checking
	
	setRet:
		
		movi	r3, PS2_MAKE_W
		beq		r3, r16, retW
		movi	r3, PS2_MAKE_A
		beq		r3, r16, retA
		movi	r3, PS2_MAKE_S
		beq		r3, r16, retS
		movi	r3, PS2_MAKE_D
		beq		r3, r16, retD
		
		# if no match, something wrong!
		movia	r2, 0xFFFFFFFF
		br		retDone
	
	
	retW:
		movi	r2, 1
		br		retDone
	retA:
		movi	r2, 2
		br		retDone
	retS:
		movi	r2, 3
		br		retDone
	retD:
		movi	r2, 4
		br		retDone
	
	retDone:
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
		
################################################################################
# empty line
################################################################################
