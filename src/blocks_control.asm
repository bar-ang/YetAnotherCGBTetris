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

