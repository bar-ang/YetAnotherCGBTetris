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

OnClock:
	xor a
	ld [rIF], a

	halt

	ld a, [Tick]
	dec a
	ld [Tick], a

	and a
	ret nz

	ld a, CLOCK_LENGTH
	ld [Tick], a

	ret

SECTION "VBlank Int Vector", ROM0[$0040]
	reti
