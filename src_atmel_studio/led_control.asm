/*
 *   file: led_control.asm
 *   Author: Bulenko Ivan
 */ 

; Connecting .inc defenition-files
.include "inc/regdefs.inc"
.include "inc/constants.inc"


led_control:
	
	; Context saving
    push temp
    push red_reg
    push green_reg
    push blue_reg
    push bit_counter
    
    ldi bit_counter, BIT_COUNT  
    

led_bit_loop:
   
    ldi temp, (0 << PB0)
    out PORTB, temp
    
    ; Preparing the next bit - shifting the desired bit
    lsl blue_reg          
    rol red_reg           
    rol green_reg         
    
	; Bit validation
    brcc send_zero        
    
	; Sending a positive logical signal
    ldi temp, (1 << PB0)
    out PORTB, temp       
    nop                   
    nop
    nop
    rjmp bit_done
    

send_zero:
	
	; Sending a negative logical signal
    ldi temp, (1 << PB0)
    out PORTB, temp       
    nop                   
    ldi temp, (0 << PB0)
    out PORTB, temp       
    

bit_done:

    dec bit_counter
    brne led_bit_loop
    
    ldi temp, (0 << PB0)
    out PORTB, temp
    
	; Context restoration
    pop bit_counter
    pop blue_reg
    pop green_reg
    pop red_reg
    pop temp
    ret


reset_led:
	
	; LED reset
    push temp
    ldi temp, RESET_DELAY
    

reset_delay_loop:
	
	; LED strip reset control
    dec temp
    brne reset_delay_loop
    
    pop temp
    ret