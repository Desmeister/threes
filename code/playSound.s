.include "constants.s"
.section .text

################################################################################
# playSound
################################################################################
# r4		startPtr
# r5		endPtr

.global playSound
playSound:

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

	/*
	movi	r18, 48
	movia	r16, 0xFF203040
	movia	r17, 0x01000000
	mov		r20, r18
	
	wait:
		ldwio	r2, 4(r16)
		andhi	r3, r2,0xFF00
		beq		r3, zero, wait
		andhi	r3, r2,0x00FF
		beq		r3, zero, wait
	write:
		stwio	r17, 8(r16)
		stwio	r17, 12(r16)
		addi	r20, r20, -1
		bne		r20, zero, wait
	half:
		mov		r20, r18
		sub		r17, zero, r17
		br		wait
	*/
	
	addi	r4, r4, 0 # skip header
	waitForWriteSpace:
		# read FIFO space
		movia	r3, AUDIO_FIFOSPACE
		ldwio	r2, (r3)

		# look at write space in left channel
		andhi	r3, r2, 0xFF00
		beq		r3, zero, waitForWriteSpace
		
		# look at write space in right channel
		andhi	r3, r2, 0x00FF
		beq		r3, zero, waitForWriteSpace
		
		# write current sample
		ldhio	r6, (r4)
		slli	r6, r6, 16
		movia	r3, AUDIO_LEFTDATA
		stwio	r6, (r3)
		movia	r3, AUDIO_RIGHTDATA
		stwio	r6, (r3)
		
		# get next sample
		bge		r4, r5, playSound_done
		addi	r4, r4, 2
		br		waitForWriteSpace
		
		
	playSound_done:
	
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
