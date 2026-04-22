INCLUDE "src/hardware.inc"
INCLUDE "src/macros.asm"
INCLUDE "src/common.asm"
INCLUDE "src/modules.asm"
INCLUDE "src/tiles.asm"

SECTION "Initiator", ROM0

RestartScreenAndInitAll:
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
	
	call GenerateTilemap

	; Turn the LCD on
	ld a, LCDC_ON | LCDC_BG_ON
	ld [rLCDC], a

  ret

GenerateTilemap:
	ld hl, $9800
	ld bc, $240+$20
	.loop:
		push hl

		ld a, h
		sub a, $98
		ld h, a
		REPT 3
		srl h
		rr  l
		ENDR
		srl l
		srl l
		ld a, l
		cp a, BOARD_HEIGHT
		jp z, .draw_bound

		pop hl
		push hl

		ld a, l
		and a, $1F

		cp a, BOARD_POS - MARGIN
		jr c, .draw_external
		
		cp a, BOARD_POS
		jr c, .draw_wall

		cp a, BOARD_POS + BOARD_WIDTH
		jr c, .draw_board
		
		cp a, BOARD_POS + BOARD_WIDTH + MARGIN
		jr c, .draw_wall

		;else
		jr .draw_external
		
		.draw_wall:
			PAINT_TILE_IN_HL 5
			ld a, 2
			jr .continue
		
		.draw_external:
			PAINT_TILE_IN_HL 4
			ld a, 1
			jr .continue

		.draw_board:
			PAINT_TILE_IN_HL 0
			ld a, 0
			jr .continue

		.draw_bound:
			pop hl
			push hl
			PAINT_TILE_IN_HL 3
			ld a, 0
			jr .continue

		.continue:

		pop hl

		ld [hli], a
		dec bc
		ld a, b
		or c
		jp nz, .loop

	ret
