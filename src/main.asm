INCLUDE "src/hardware.inc"
INCLUDE "src/common.asm"
INCLUDE "src/tiles.asm"

SECTION "Entry", ROM0[$100]
	nop
	jp main
	ds $143 - @, 0
	db $C0 ; Turn on CGB-or-DMG Flag


MACRO INIT_GBC_PALETTE
  ;NOTE Screen Must be off!
	ld a, $80
	ld [rBCPS], a

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

ENDM


SECTION "Main", ROM0[$150]

main:
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
	call WaitVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	INIT_GBC_PALETTE

	ld de, Tiles
	ld hl, $9000
	ld bc, Tiles.end - Tiles
	call Memcpy

	; Turn the LCD on
	ld a, LCDC_ON | LCDC_BG_ON
	ld [rLCDC], a


process:
	jp process



