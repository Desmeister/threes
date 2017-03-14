.include "constants.s"
.section .text

################################################################################
# drawPixel
################################################################################
# r4		x
# r5		y
# r6		colour

.global drawPixel
drawPixel:

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

	# convert x and y to offset
	slli	r5, r5, 10
	slli	r4, r4, 1
	add		r2, r4, r5
	
	# add offset to base
	movia	r3, PIXEL_BUFFER
	add		r3, r3, r2
	
	# draw pixel
	sth		r6, (r3)
	
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
# drawChar
################################################################################
# r4		x
# r5		y
# r6		char

.global drawChar
drawChar:

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

	# convert x and y to offset
	slli	r5, r5, 7
	add		r2, r4, r5
	
	# add offset to base
	movia	r3, CHARACTER_BUFFER
	add		r3, r3, r2
	
	# draw character
	stb		r6, (r3)
	
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
# drawBox
################################################################################
# r16		x1
# r17		y1
# r18		x2
# r19		y2
# r20		colour
# r21		row
# r22		col

.global drawBox
drawBox:
	
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
	
	# store
	mov		r16, r4
	mov		r17, r5
	mov		r18, r6
	mov		r19, r7
	ldw		r20, 0(fp)
	
	# nested for loop to draw rectangle
	# for loop (row)
	mov		r21, r17 # row = y1
	for_rows:
		bgt		r21, r19, done_rows # loop while(row <= y2)
	
		# for loop (col)
		mov		r22, r16 # col = x1
		for_cols:
			bgt		r22, r18, done_cols # loop while(col <= x2)
		
			# draw pixel
			mov		r4, r22
			mov		r5, r21
			mov		r6, r20
			call	drawPixel
			
			addi	r22, r22, 1 # col++
			br		for_cols

		done_cols:
		addi	r21, r21, 1 # row++
		br		for_rows
	done_rows:
	
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
# drawImage
################################################################################
# note: image is stored backwards (last row, 2nd last row, etc)
# rows themselves are not flipped, only the order of the columns
#
# r4		fileLabel
# r5		xOffset (arg)
# r6		yOffset (arg)
# r16		width
# r17		height
# r18		imagePtr
# r19		done
# r20		x
# r21		y
# r22		xOffset (saved)
# r23		yOffset (saved)

.global drawImage
drawImage:

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

	# get image variables
	ldh		r16, 0(r4)		# get width
	ldh		r17, 2(r4)		# get height
	addi	r18, r4, 0x58	# skip over header
	mov		r22, r5			# save xOffset
	mov		r23, r6			# save yOffset
	
	# initialize drawing variables
	mov		r19, zero		# done = false
	add		r20, r22, zero	# x = xOffset + 0
	add		r21, r23, r17	# y = yOffset + height
	subi	r21, r21, 1		# y = y - 1
	
	# while loop
	drawImage_while:
		movi	r2, 1
		beq		r19, r2, drawImage_doneWhile # while (!done)
	
		mov		r4, r20
		mov		r5, r21
		ldh		r6, (r18)
		call	drawPixel		# draw current pixel
		
		addi	r20, r20, 1 	# x++
		addi	r18, r18, 2		# go to next 2 bytes (16 bit RGB)
		
		drawImage_if1:
		add		r2, r22, r16
		blt		r20, r2, drawImage_if2 # if (x >= xOffset + width)
			
			mov		r20, r22		# x = xOffset
			subi	r21, r21, 1		# y = y - 1
			
		drawImage_if2:
		bge		r21, r23, drawImage_while # if (y < yOffset)
		
			movi	r19, 1			# done = true
			
		br		drawImage_while
	
	
	drawImage_doneWhile:
	
	
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
# drawGridBox
################################################################################
# r4		gridBoxIdx

.global drawGridBox
drawGridBox:

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

	
	
	# set x and y
	setXY:
		mov		r2, r4
	
		movi	r3, 0
		beq		r3, r2, s0
		movi	r3, 1
		beq		r3, r2, s1
		movi	r3, 2
		beq		r3, r2, s2
		movi	r3, 3
		beq		r3, r2, s3
		movi	r3, 4
		beq		r3, r2, s4
		movi	r3, 5
		beq		r3, r2, s5
		movi	r3, 6
		beq		r3, r2, s6
		movi	r3, 7
		beq		r3, r2, s7
		movi	r3, 8
		beq		r3, r2, s8
		movi	r3, 9
		beq		r3, r2, s9
		movi	r3, 10
		beq		r3, r2, s10
		movi	r3, 11
		beq		r3, r2, s11
		movi	r3, 12
		beq		r3, r2, s12
		movi	r3, 13
		beq		r3, r2, s13
		movi	r3, 14
		beq		r3, r2, s14
		movi	r3, 15
		beq		r3, r2, s15
	
		s0:
			movi	r5, col1x
			movi	r6, row1y
			br		setBlock
		s1:
			movi	r5, col2x
			movi	r6, row1y
			br		setBlock
		s2:
			movi	r5, col3x
			movi	r6, row1y
			br		setBlock
		s3:
			movi	r5, col4x
			movi	r6, row1y
			br		setBlock
		s4:
			movi	r5, col1x
			movi	r6, row2y
			br		setBlock
		s5:
			movi	r5, col2x
			movi	r6, row2y
			br		setBlock
		s6:
			movi	r5, col3x
			movi	r6, row2y
			br		setBlock
		s7:
			movi	r5, col4x
			movi	r6, row2y
			br		setBlock
		s8:
			movi	r5, col1x
			movi	r6, row3y
			br		setBlock
		s9:
			movi	r5, col2x
			movi	r6, row3y
			br		setBlock
		s10:
			movi	r5, col3x
			movi	r6, row3y
			br		setBlock
		s11:
			movi	r5, col4x
			movi	r6, row3y
			br		setBlock
		s12:
			movi	r5, col1x
			movi	r6, row4y
			br		setBlock
		s13:
			movi	r5, col2x
			movi	r6, row4y
			br		setBlock
		s14:
			movi	r5, col3x
			movi	r6, row4y
			br		setBlock
		s15:
			movi	r5, col4x
			movi	r6, row4y
			br		setBlock
	
	setBlock:
	
		muli	r4, r4, 4
		movia	r2, BOARD
		add		r4, r4, r2		# get grid+offset in words
		ldw		r2, (r4)
	
		movi	r3, 0
		beq		r3, r2, b0
		movi	r3, 1
		beq		r3, r2, b1
		movi	r3, 2
		beq		r3, r2, b2
		movi	r3, 3
		beq		r3, r2, b3
		movi	r3, 6
		beq		r3, r2, b6
		movi	r3, 12
		beq		r3, r2, b12
		movi	r3, 24
		beq		r3, r2, b24
		movi	r3, 48
		beq		r3, r2, b48
		movi	r3, 96
		beq		r3, r2, b96
		movi	r3, 192
		beq		r3, r2, b192
		movi	r3, 384
		beq		r3, r2, b384
		br		b0
	
		b0:
			movia	r4, gb0
			br 		fill
		b1:
			movia	r4, gb1
			br 		fill
		b2:
			movia	r4, gb2
			br 		fill
		b3:
			movia	r4, gb3
			br 		fill
		b6:
			movia	r4, gb6
			br 		fill
		b12:
			movia	r4, gb12
			br 		fill
		b24:
			movia	r4, gb24
			br 		fill
		b48:
			movia	r4, gb48
			br 		fill
		b96:
			movia	r4, gb96
			br 		fill
		b192:
			movia	r4, gb192
			br 		fill
		b384:
			movia	r4, gb384
			br 		fill
		
	fill:
		call	drawImage
	
	
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
# drawScore
################################################################################
# r4		score
# r16		thousands
# r17		hundreds
# r18		tens
# r19		ones

.global drawScore
drawScore:

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

	mov		r16, zero
	whileTH:
		addi	r4, r4, -1000
		blt		r4, zero, doneTH
		addi	r16, r16, 1
		br		whileTH
	doneTH:
		addi	r4, r4, 1000

	movi	r2, 10 
	ble		r16, r2, continue
	movi	r16, 0
	
	continue:
	mov		r17, zero
	whileHU:
		addi	r4, r4, -100
		blt		r4, zero, doneHU
		addi	r17, r17, 1
		br		whileHU
	doneHU:
		addi	r4, r4, 100
		
	mov		r18, zero
	whileTE:
		addi	r4, r4, -10
		blt		r4, zero, doneTE
		addi	r18, r18, 1
		br		whileTE
	doneTE:
		addi	r4, r4, 10
	
	mov		r19, zero
	whileON:
		addi	r4, r4, -1
		blt		r4, zero, doneON
		addi	r19, r19, 1
		br		whileON
	doneON:
		addi	r4, r4, 1

	# convert to ASCII
	addi	r16, r16, 48
	addi	r17, r17, 48
	addi	r18, r18, 48
	addi	r19, r19, 48
	
	movia	r4, 67
	movia	r5, 30
	mov		r6, r16
	call	drawChar
	movia	r4, 68
	movia	r5, 30
	mov		r6, r17
	call	drawChar
	movia	r4, 69
	movia	r5, 30
	mov		r6, r18
	call	drawChar
	movia	r4, 70
	movia	r5, 30
	mov		r6, r19
	call	drawChar
	
	
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
