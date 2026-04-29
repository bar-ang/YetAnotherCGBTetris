SECTION "Variables", WRAM0
DEF QUEUE_SIZE EQU 2


Brick:
	; 0 1 2 4
	; E 3 7 5
	; D F B 6
	; C A 9 8
	.shape: dw
	.palette: db
	.x: db
	.y: db
	.end:

BrickStaleAddr: dw

DEF BRICK_SIZE EQU (Brick.end - Brick)

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

macro clear_stale_brick
	ld a, 1
	ld [rVBK], a

	REPT 4

		REPT 4

			ld a, [hl]
			and a, $F7
			ld [hl+], a

		ENDR

		ld de, $1C
		add hl, de
	ENDR

	ld a, 0
	ld [rVBK], a

endm

macro locate_brick_pos_in_hl
	ld hl, Brick
	ld a, BOARD_POS
	add a, [hl]
	inc hl
	ld c, [hl]
	mul32
	ld h, 0
	ld l, a
	add hl, bc
endm

macro construct_brick
	
	locate_brick_pos_in_hl

	ld a, [Brick.palette]
	ld c, a

	DEF i = 0
	REPT 2
		ld a, [Brick + i / 8]

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
