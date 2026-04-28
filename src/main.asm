INCLUDE "src/hardware.inc"
INCLUDE "src/blocks.asm"
INCLUDE "src/clock.asm"
INCLUDE "src/initiator.asm"
INCLUDE "src/io.asm"


SECTION "Entry", ROM0[$100]
	nop
	jp main
	ds $143 - @, 0
	db $C0 ; Turn on CGB-or-DMG Flag


SECTION "Main", ROM0[$150]

main:
	call RestartScreenAndInitAll

	xor a
	ld [BlockAlive], a
	ld [Blocks.shape], a
	ld [Blocks.shape+1], a
	ld [Blocks.palette], a
	ld [Blocks.x], a
	ld [Blocks.y], a

	new_block $77, $9, 5, 5, -1
	
	call InitClock
	call InitKeys


process:
	halt
	check_block_done
	jp z, .continue
		new_block $77, $9, 5, 5, -1
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


RenderBoard:
	call WaitVBlank
	dead_block_in_hl
	locate_block_pos_in_hl
	clear_block_from_screen
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
