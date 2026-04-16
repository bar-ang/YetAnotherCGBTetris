macro new_block
	ld a, [BlockAlive]
	xor 1
	ld [BlockAlive], a

	xor 1
	dec a
	and BLOCK
	ld e, a
	ld d, 0
	ld hl, Blocks
	add hl, de
	
	ld a, \1
	ld [hli], a
	ld a, \2
	ld [hli], a
	ld a, \3
	ld [hli], a
	ld a, \4
	ld [hli], a

endm

macro move_block_down_single_step
	
	live_block_in_hl	
	push hl
	ld a, [BlockAlive]
	xor 1
	ld [BlockAlive], a
	live_block_in_hl	
	pop de

	ld c, BLOCK
	ld b, 0
	push hl
	call Memcpy
	pop hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	inc a
	ld [hl], a

endm

macro check_block_done
	
	live_block_in_hl
	locate_block_pos_in_hl
	ld d, 0
	ld e, $20
	add hl, de
	ld a, 1
	ld [rVBK], a
	ld a, [hl]
	ld b, a
	ld a, 0
	ld [rVBK], a
	ld a, b
	and 7

endm
