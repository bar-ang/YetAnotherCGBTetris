INCLUDE "src/hardware.inc"
INCLUDE "src/macros.asm"
INCLUDE "src/common.asm"
INCLUDE "src/initiator.asm"
INCLUDE "src/tiles.asm"

SECTION "Entry", ROM0[$100]
	nop
	jp main
	ds $143 - @, 0
	db $C0 ; Turn on CGB-or-DMG Flag


SECTION "Main", ROM0[$150]

main:
	call RestartScreenAndInitAll

process:
	jp process



