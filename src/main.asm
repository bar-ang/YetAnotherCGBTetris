INCLUDE "src/hardware.inc"
INCLUDE "src/macros.asm"
INCLUDE "src/blocks_control.asm"
INCLUDE "src/common.asm"
INCLUDE "src/initiator.asm"
INCLUDE "src/clock.asm"
INCLUDE "src/tiles.asm"


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

	new_block $E7, 2, 5, 9
	
	call InitClock


process:
	halt
	call RenderBoard
	jp process


RenderBoard:
	live_block_in_hl

	push hl
	locate_block_pos_in_hl
	pop de
	inc de
	inc de

	ld a, [de]
	ld b, a

	call WaitVBlank
	PAINT_TILE_IN_HL b
	
	ret
