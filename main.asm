; Target: ATTiny2313a
; 
; # Intro
; Peripheral: eight 7 Segment Displays (kcsc02-105) 
; KCSC02-105 Are ultra-red 7 segment displays with common cathode (1.9V required with 30ma forward current)
; With a 5V supply we use ~200/300 ohm resistors in series which each segment
; 
; # Driving multiple 7 segment displays
; Normally you'd have a shift register that is being fed data serially to output it in parallel for 7 segment displays to collect. Then we can pick which
; 7sd should accept data by pulling its common cathode low, while keeping other common cathodes high (it's probably not the best way to do it but hey, what
; do i know :3c)
;
; # Explanation on how we drive multiple 7sd using one chip without a SR
; Halfway through development it turned out that USI (universal serial interface) of ATtiny2313 is just too slow to work with a shift-register to
; drive multiple 7 segment displays.
;
; Luckily, it turned out that ATTiny2313 has enough pins to both send the data to our seven segment displays and to pick which 7sd should collect said data.
; For picking a 7sd we use PORTB, (PB7-PB0) where logical ONE for a given bit means that the display associated with that pin is OFF, while logical ZERO
; means that a given display is ON and accepting data (look at disp_0 - disp_1)
;
; For data we use PORTD (PD0-PD6 (we only need 7 bits)) where we simply output data in parallel. 
;

.include "tn2313def.inc"

.def 	char_reg	= r16
.def	disp_reg	= r17
.def	word_idx	= r18
.equ 	tim1_reset_value	= 230
.equ	disp_0			= 0b01111111
.equ 	disp_1  		= 0b10111111
.equ 	disp_2  		= 0b11011111
.equ	disp_3			= 0b11101111
.equ	disp_4			= 0b11110111
.equ	disp_5			= 0b11111011
.equ	disp_6			= 0b11111101
.equ	disp_7			= 0b11111110
.equ	a			= 0b11011111
.equ	b			= 0b11111100
.equ	c			= 0b11100110
.equ	d			= 0b11111001
.equ	e			= 0b11101110
.equ	f			= 0b01001110
.equ 	h			= 0b11011101
.equ	i			= 0b00010001
.equ 	j			= 0b00110001
.equ	l			= 0b01100100
.equ	n			= 0b01011000
.equ 	o			= 0b01111000
.equ	u			= 0b01110000
.equ	v			= 0b01110000
.equ 	p			= 0b11001111
.equ	r 			= 0b11001000
.equ	s			= 0b10111110

.org 0x00  					; so yeah lets jump to main :3
	rjmp main

.org 0x0004  					; isr vector for compare match for 16 bit timer
	rjmp TIM1_COMPA_ISR 

TIM1_COMPA_ISR:  				; this ISR probably does way too much? but it should be okay for this purpose lmao
	ldi r20, 0b00000010
	in r19, PORTA
	eor r19, r20  				; blink the LED every time the ISR is called
	out PORTA, r19
	ldi r16, tim1_reset_value  		; value to reset the timer with, can be adjusted depending on the delay we want
	out TCNT1H, r16
	out TCNT1L, r16
	inc word_idx  				; we shall USE that value to pick which words we display on 7 segment displays :3c
	reti

main:  ;; configure pins and such (all outputs, aside from XTAL pins)
	ldi r16, 0b11111111
	out DDRD, r16  				; set all to output
	out DDRB, r16  				; set all to output
	out DDRA, r16  				; for testing
	ldi r16, (1 << CS12) | (1 << CS10)  	; enable prescaler (/1024) 
	out TCCR1B, r16
	ldi r16, (1 << OCIE1A)  		; enable interrupts for the compare match
	out TIMSK, r16
	sei  					; enable interrupts
	ldi r16, 255  
	out OCR1AL, r16		  		; low byte of the 16 bit timer
	out OCR1AH, r16  			; high byte of the 16 bit timer
	rjmp loop

clear_displays:  ; clears all displays by setting all pins high (they are 'active low')
	ldi r16, 0b11111111
	out PORTB, r16
	ret

; uses r16 to hold the character (PORTD) to send, and r17 to hold the displays (PORTB) state
send_character:
	out PORTD, char_reg
	out PORTB, disp_reg
	rcall clear_displays
	ret

send_a:
	ldi char_reg, a
	rcall send_character
	ret

send_b:
	ldi char_reg, b
	rcall send_character
	ret

send_c:
	ldi char_reg, c
	rcall send_character
	ret

send_d:
	ldi char_reg, d
	rcall send_character
	ret

send_e:
	ldi char_reg, e
	rcall send_character
	ret

send_f:
	ldi char_reg, f
	rcall send_character
	ret

send_h:
	ldi char_reg, h
	rcall send_character
	ret

send_i:
	ldi char_reg, i
	rcall send_character
	ret

send_j:
	ldi char_reg, j
	rcall send_character
	ret

send_l:
	ldi char_reg, l
	rcall send_character
	ret

send_n:
	ldi char_reg, n
	rcall send_character
	ret

send_o:
	ldi char_reg, o
	rcall send_character
	ret

send_u:
	ldi char_reg, u
	rcall send_character
	ret

send_v:
	rcall send_u
	ret

send_p:
	ldi char_reg, p
	rcall send_character
	ret

send_r:
	ldi char_reg, r
	rcall send_character
	ret

send_space:
	ldi char_reg, 0b00000000
	rcall send_character
	ret

send_s:
	ldi char_reg, s
	rcall send_character
	ret

send_lol:
	ldi disp_reg, disp_0
	rcall send_l
	ldi disp_reg, disp_1
	rcall send_o
	ldi disp_reg, disp_2
	rcall send_l
	ret

send_hi_love:
	ldi disp_reg, disp_0
	rcall send_h
	ldi disp_reg, disp_1
	rcall send_i
	ldi disp_reg, disp_2
	rcall send_space
	ldi disp_reg, disp_3
	rcall send_l
	ldi disp_reg, disp_4
	rcall send_o
	ldi disp_reg, disp_5
	rcall send_v
	ldi disp_reg, disp_6
	rcall send_e
	ret

loop:
	cpi word_idx, 1
	breq send_lol_br
	cpi word_idx, 2
	breq send_hi_br
	cpi word_idx, 3
	breq reset
send_lol_br:
	rcall send_lol
	rjmp end
send_hi_br:
	rcall send_hi_love
	rjmp end
reset:
	ldi word_idx, 0
end:
	rjmp loop
