INCLUDE "src/hardware.inc"

DEF CLOCK_LENGTH EQU 10

SECTION "Clock Data", WRAM0

; Measure in vbalnks.
; the number of clocks cycles per second is approx:
;        59.7
;    -----------
;    ClockLength
ClockLength: db
Tick: db


SECTION "Clock Work", ROM0

InitClock:
	di
	ld a, CLOCK_LENGTH
	ld [ClockLength], a
	xor a
	ld [Tick], a

	ld a, 1
	ld [rIE], a
	ei

	ret

WaitForClock:
	xor a
	ld [rIF], a

	ld a, [ClockLength]
	.loop:
		halt
		dec a
		ret z
		jr .loop

VBlankIntHandler:
	ld a, [Tick]
	inc a
	ld [Tick], a

	cp a, CLOCK_LENGTH
	ret nz

	xor a
	ld [Tick], a

	ret

SECTION "VBlank Int Vector", ROM0[$0040]
	call VBlankIntHandler
	reti

macro outofclock
	ld a, [Tick]
	and a
	jp nz, \1

endm
