/*
 *   file: constants.inc
 *   Author: Bulenko Ivan
 */ 

; LED strip configuration
.equ LED_COUNT      = 0x08		; Number of LEDs in the strip
.equ BIT_COUNT      = 0x18      ; Number of bits per LED

; ADC zero-protection
.equ ADC_MIN_VAL    = 0x5F		; Minimum value for timer

; Mode
.equ MODE_CYAN      = 0x01 
.equ MODE_RED       = 0x02
.equ MODE_GREEN     = 0x03

; Mode colors in RGB format
.equ COLOR_CYAN_G   = 0x95     
.equ COLOR_CYAN_R   = 0x66     
.equ COLOR_CYAN_B   = 0xDC     

.equ COLOR_RED_G    = 0x66     
.equ COLOR_RED_R    = 0xFC     
.equ COLOR_RED_B    = 0x66     

.equ COLOR_GREEN_G  = 0xEC     
.equ COLOR_GREEN_R  = 0x66     
.equ COLOR_GREEN_B  = 0x7D     

; Time delay for LED strip reset
.equ RESET_DELAY    = 0x20