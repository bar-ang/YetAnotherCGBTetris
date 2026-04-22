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

	ld a, [de]
	ld c, a ; c contains block's shape
	inc de

	ld a, [de]
	ld b, a ; b contains block's color

	; hl contains blocks position on board

	REPT 2
		REPT 4
			ld a, c
			and 1
			xor 1
			dec a
			and \1
			push bc
			ld b, a
			PAINT_TILE_IN_HL b
			pop bc
			dec hl
			srl c
		ENDR
		push de
		ld e, $e4
		ld d, $ff ; de = -$16 (two's comp of $16)
		add hl, de
		pop de
	ENDR


endm
