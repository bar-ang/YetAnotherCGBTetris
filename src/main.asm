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

	ld hl, Brick
	xor a
	REPT BRICK_SIZE
		ld [hl+], a
	ENDR

	call NewRandomBrick

	call InitClock
	call InitKeys

process:
	;check_block_done
	;jp z, .continue
	;	new_block $9, $77, 5, 5, -1
	;.continue:

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

	call UpdateKeys


	;call MarkRowsToClear
	call RenderBoard
	jp process


onClock:
	move_block_down_single_step
	ret

RenderBoard:
	call WaitVBlank
	handle_stale_brick
	construct_brick b
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

NewRandomBrick: ; TODO: not really random for now :)

	handle_stale_brick

	ld a, $9
	ld [Brick.shape], a
	ld a, $77
	ld [Brick.shape+1], a
	ld a, $5
	ld [Brick.palette], a
	ld a, $5
	ld [Brick.x], a
	ld a, $4
	ld [Brick.y], a

	ret


