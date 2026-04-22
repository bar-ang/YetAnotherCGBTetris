INCLUDE "src/modules.asm"

SECTION "entry", ROM0[$100]
	nop
	jp main


SECTION "main", ROM0[$200]

main:
	live_block_in_hl
	ld a, $ee
	call test+0
	ld [$CABA], a
	call test+1
	ld b, a
	inc b
	call test+5

	call done






SECTION "hooks", ROM0[$3FF0]

test:
	REPT 7
	ret
	ENDR
done:
	ret
