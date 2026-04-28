SECTION "Variables", WRAM0
DEF QUEUE_SIZE EQU 2


Blocks:
	; 0 1 2 4
	; E 3 7 5
	; D F B 6
	; C A 9 8
	.shape: dw
	.palette: db
	.x: db
	.y: db
	.queue: ds (@ - Blocks) * (QUEUE_SIZE-1)

BlockAlive: db

DEF BLOCK EQU (Blocks.queue - Blocks)

MACRO INIT_GBC_PALETTE
  ;NOTE Screen Must be off!
	ld a, $80
	ld [rBCPS], a
  
	RGB_Set 0, 0, 0
  RGB_Set 3, 3, 3
  RGB_Set 7, 7, 7
  RGB_Set 15, 15, 15

  RGB_Set 3, 0, 0
  RGB_Set 7, 0, 0
  RGB_Set 15, 0, 0
  RGB_Set 31, 0, 0

  RGB_Set 0, 3, 0
  RGB_Set 0, 7, 0
  RGB_Set 0, 15, 0
  RGB_Set 0, 31, 0
  
  RGB_Set 0, 0, 3
  RGB_Set 0, 0, 7
  RGB_Set 0, 0, 15
	RGB_Set 0, 0, 31
  
	RGB_Set 24, 5, 27
	RGB_Set 12, 3, 13
	RGB_Set 6, 1, 6
	RGB_Set 3, 0, 3
	
	RGB_Set 24, 24, 0
	RGB_Set 10, 10, 4
	RGB_Set 8, 8, 1
	RGB_Set 3, 3, 0

ENDM

MACRO PAINT_TILE_IN_HL
		ld a, 1
		ld [rVBK], a
		ld a, [hl]
		and $F8
		or \1
		ld [hl], a
		xor a
		ld [rVBK], a
ENDM

macro live_block_in_hl
	ld a, [BlockAlive]

	xor 1
	dec a
	and BLOCK
	ld e, a
	ld d, 0
	ld hl, Blocks
	add hl, de

endm

macro dead_block_in_hl
	ld a, [BlockAlive]
	dec a
	and BLOCK
	ld e, a
	ld d, 0
	ld hl, Blocks
	add hl, de

endm

macro locate_block_pos_in_hl
	; assume block in hl
	inc hl
	inc hl
	ld e, BOARD_POS
	ld d, 0
	ld a, [hli]
	add a, e
	ld e, a
	ld a, [hli]
	ld c, a
	mul32
	ld h, b
	ld l, c
	add hl, de
	ld a, h
	add a, $98
	ld h, a
endm

macro construct_block_in_hl
	
	push hl
	locate_block_pos_in_hl
	pop de

	ld b, d
	ld c, e
	inc bc
	inc bc
	ld a, [bc]
	ld c, a

	DEF i = 0
	REPT 2
		ld a, [de]
		push de

		REPT 8
			IF i == 0
				DEF pos = $00
			ELIF i == 1
				DEF pos = $01
			ELIF i == 2
				DEF pos = $02
			ELIF i == 3
				DEF pos = $21
			ELIF i == 4
				DEF pos = $03
			ELIF i == 5
				DEF pos = $23
			ELIF i == 6
				DEF pos = $43
			ELIF i == 7
				DEF pos = $22
			ELIF i == 8
				DEF pos = $63
			ELIF i == 9
				DEF pos = $62
			ELIF i == $A
				DEF pos = $61
			ELIF i == $B
				DEF pos = $42
			ELIF i == $C
				DEF pos = $60
			ELIF i == $D
				DEF pos = $40
			ELIF i == $E
				DEF pos = $20
			ELIF i == $F
				DEF pos = $41
			ENDC


			ld b, a
			and 1
			xor 1
			dec a
			push hl
			ld de, pos
			add hl, de
			and a, c
			ld d, a
			PAINT_TILE_IN_HL d
			pop hl
			ld a, b
			srl a

		DEF i+=1
		ENDR

		pop de
		inc de
	ENDR


endm
