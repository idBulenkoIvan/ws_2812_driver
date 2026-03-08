/*  
 *   file: regdefs.inc
 *	 Author: Bulenko Ivan
 */ 

.def temp        = r16		; Temporary register
.def bit_counter = r17      ; Bit counter
.def led_counter = r18      ; LEDs counter

.def red_reg     = r19      ; The current value of the red component of the color in RGB format
.def green_reg   = r20		; The current value of the green component of the color in RGB format
.def blue_reg    = r21      ; The current value of the blue component of the color in RGB format

.def mode_reg    = r22      ; Current mode
.def adcl_val    = r23      ; ADC low byte
.def adch_val    = r24      ; ADC high byte

.def save_sreg   = r25      ; To save SREG in interrupts