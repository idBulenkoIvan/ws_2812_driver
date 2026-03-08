/*
 *   file: main.asm
 *   Author: Bulenko Ivan
 */ 

; Connecting .inc defenition-files
.include "inc/regdefs.inc"
.include "inc/constants.inc"

; RAM initialization
.dseg
	.org 0x0060                 
	red:    .byte LED_COUNT     
	green:  .byte LED_COUNT     
	blue:   .byte LED_COUNT     

; ROM initialization
.cseg
	
	; Reset vector
	.org 0x0000
		rjmp reset 
	
	; Timer interrupt-vector
	.org 0x0006                 
		rjmp timer_interrupt

	; ADC interrupt-vector
	.org 0x000E                 
		rjmp adc_interrupt


reset:
	
	; Initialization of the least significant bit of the stack pointer
    ldi temp, low(RAMEND)
    out SPL, temp

	; Initialization of the high bit of the stack pointer
    ldi temp, high(RAMEND)
    out SPH, temp

	; Port configuration 
    ldi temp, 0b11111111    
    out DDRB, temp
    ldi temp, 0x00          
    out PORTB, temp

	; ADC configuration
    ldi temp, (1 << ADEN) | (1 << ADPS0) | (1 << ADPS1) | (1 << ADIE) | (1 << ADFR)
    out ADCSRA, temp         
    
    ldi temp, (1 << REFS0)   
    out ADMUX, temp

	; Timer configuration
    ldi temp, (1 << WGM12) | (1 << CS12) | (1 << CS10)  
    out TCCR1B, temp
    
    ldi temp, (1 << OCIE1A)  
    out TIMSK, temp
    
	; Setting initial values for comparison
    ldi temp, 0x00
    out OCR1AH, temp
    ldi temp, 0x0F
    out OCR1AL, temp

    ldi mode_reg, MODE_CYAN  

    ; Global interrupt enable
	sei        
	            
	; ADC conversion start  
    sbi ADCSRA, ADSC


main:
	
	; Arrays pointers initialization
    ldi XL, low(red)
    ldi XH, high(red)
    ldi YL, low(green)
    ldi YH, high(green)
    ldi ZL, low(blue)
    ldi ZH, high(blue)
    
    ldi led_counter, LED_COUNT


main_cycle:
	
	; Disabling global interrupts to safely update the LED strip state
    cli

	; LED strip reset
    rcall reset_led
    
	; Resetting pointers to the beginning of the arrays
    ldi XL, low(red)
    ldi XH, high(red)
    ldi YL, low(green)
    ldi YH, high(green)
    ldi ZL, low(blue)
    ldi ZH, high(blue)
    
    ldi led_counter, LED_COUNT


led_output_loop:
	
	; Color loading for the current LED
    ld red_reg, X+
    ld green_reg, Y+
    ld blue_reg, Z+
    
	; Data sending to the LED strip
    rcall led_control
    
    dec led_counter
    brne led_output_loop
    
	; Global interrupt enable
    sei
    
    rjmp main_cycle


timer_interrupt:

	; Context saving
    push temp
    in temp, SREG
    push temp

    ; Initialization of pointers to the beginnig of the arrays
    ldi XL, low(red)
    ldi XH, high(red)
    ldi YL, low(green)
    ldi YH, high(green)
    ldi ZL, low(blue)
    ldi ZH, high(blue)
    
    ; Installation of LED counters
    ldi temp, LED_COUNT
    push temp                

    ; Mode setting
    cpi mode_reg, MODE_CYAN
    brne check_red_mode
    
    ldi red_reg, COLOR_CYAN_R
    ldi green_reg, COLOR_CYAN_G
    ldi blue_reg, COLOR_CYAN_B
    ldi mode_reg, MODE_RED   
    rcall fill_all_leds
    rjmp timer_exit


check_red_mode:

    cpi mode_reg, MODE_RED
    brne green_mode
    
    ldi red_reg, COLOR_RED_R
    ldi green_reg, COLOR_RED_G
    ldi blue_reg, COLOR_RED_B
    ldi mode_reg, MODE_GREEN 
    rcall fill_all_leds
    rjmp timer_exit


green_mode:

    ldi red_reg, COLOR_GREEN_R
    ldi green_reg, COLOR_GREEN_G
    ldi blue_reg, COLOR_GREEN_B
    ldi mode_reg, MODE_CYAN   
    rcall fill_all_leds


timer_exit:

    pop temp                
    pop temp
    out SREG, temp
    pop temp
    reti


fill_all_leds:

    pop temp                 
    

fill_loop:
    st X+, red_reg
    st Y+, green_reg
    st Z+, blue_reg
    dec temp
    brne fill_loop
    ret


adc_interrupt:

    ; ADC registers reading
    in adcl_val, ADCL
    in adch_val, ADCH
    
	; Checking for the edge-value
    cpi adch_val, 0x00
    breq adc_min_value
    
    out OCR1AH, adch_val
    out OCR1AL, adcl_val
    reti


adc_min_value:

    ; Protection against too fast interrputs
    ldi adcl_val, ADC_MIN_VAL
    out OCR1AH, adch_val     
    out OCR1AL, adcl_val
    reti


.include "led_control.asm"
