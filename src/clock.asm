SECTION "Clock Data", WRAM0

; Measure in vbalnks.
; the number of clocks cycles per second is approx:
;        59.7
;    -----------
;    ClockLength
ClockLength: db


SECTION "Clock Work", ROM0

InitClock:
	di
	ld a, CLOCK_LENGTH
	ld [ClockLength], a

	ld a, 1
	ld [rIE], a
	ei

	ret

SECTION "VBlank Int Vector", ROM0[$0040]
	reti
