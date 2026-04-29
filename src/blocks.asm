macro handle_stale_brick
	locate_brick_pos_in_hl
	ld a, h
	ld [BrickStaleAddr], a
	ld a, l
	ld [BrickStaleAddr+1], a
endm

macro move_block_right_single_step

	ld hl, Brick.x
	inc [hl]

endm

macro move_block_left_single_step

	ld hl, Brick.x
	dec [hl]

endm

macro move_block_down_single_step

	ld hl, Brick.y
	inc [hl]

endm

;macro check_block_done
;	
;	live_block_in_hl
;	locate_block_pos_in_hl
;	ld d, 0
;	ld e, $20
;	add hl, de
;	ld a, 1
;	ld [rVBK], a
;	ld a, [hl]
;	ld b, a
;	ld a, 0
;	ld [rVBK], a
;	ld a, b
;	and 7
;
;endm
