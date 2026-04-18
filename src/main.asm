INCLUDE "src/hardware.inc"
INCLUDE "src/macros.asm"
INCLUDE "src/blocks.asm"
INCLUDE "src/common.asm"
INCLUDE "src/initiator.asm"
INCLUDE "src/clock.asm"
INCLUDE "src/tiles.asm"
INCLUDE "src/io.asm"


SECTION "Variables", WRAM0
DEF QUEUE_SIZE = 2

Blocks:
	; Block shape: described by one byte, each square is
	; represented by one bit.
	; lower nibble describes the bottom row of the block
	; higher nibble describes the upper row of the block
	;
	; i.e.
	; 7 6 5 4
	; 3 2 1 0
	.shape: db
	.palette: db
	.x: db
	.y: db
	.queue: ds (@ - Blocks) * (QUEUE_SIZE-1)

BlockAlive: db

DEF BLOCK EQU (Blocks.queue - Blocks)

SECTION "Entry", ROM0[$100]
	nop
	jp main
	ds $143 - @, 0
	db $C0 ; Turn on CGB-or-DMG Flag


SECTION "Main", ROM0[$150]

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

main:
	call RestartScreenAndInitAll

	xor a
	ld [BlockAlive], a
	ld [Blocks.shape], a
	ld [Blocks.palette], a
	ld [Blocks.x], a
	ld [Blocks.y], a

	new_block $E7, 5, 5, -1
	
	call InitClock
	call InitKeys


process:
	halt
	check_block_done
	jp z, .continue
		new_block $E7, 5, 5, -1
	.continue:
	blockcpy

	ld a, [wCurKeys]
	and a, PAD_LEFT
	jp z, .no_left
	move_block_left_single_step
	.no_left:

	ld a, [wCurKeys]
	and a, PAD_RIGHT
	jp z, .no_right
	move_block_right_single_step
	.no_right:

	outofclock .nodown
	move_block_down_single_step

	.nodown:
	call UpdateKeys


	call MarkRowsToClear
	call RenderBoard
	jp process


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
			inc hl
			srl c
		ENDR
		push de
		ld e, $1C
		ld d, 0
		add hl, de
		pop de
	ENDR


endm

RenderBoard:
	call WaitVBlank
	dead_block_in_hl

	construct_block_in_hl 0

	live_block_in_hl

	construct_block_in_hl b


	ret


MarkRowsToClear:

	ld l, BOARD_POS
	ld h, $98

	ld a, 1
	ld [rVBK], a


.next_row:

	push hl

	ld c, BOARD_WIDTH
	.loop:
		ld a, [hli]
		and 7
		jp z, .dont_mark_delete

		dec c
		ld a, c
		and a
		jp nz, .loop

	ld c, BOARD_WIDTH
	dec hl
	.mark_delete:
		ld a, 1 ; TODO: we need a special palette!
		ld [hl-], a
		
		dec c
		ld a, c
		and a
		jp nz, .mark_delete


	.dont_mark_delete:	

	pop hl
	ld e, $20
	ld d, 0
	add hl, de
	ld a, h
	cp a, $9c
	jp nz, .next_row

	xor a
	ld [rVBK], a

	ret
