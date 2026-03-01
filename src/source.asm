.DEVICE ATmega8
 
.def tmp = r16			
.def bit_cnt = r17		
.def led_cnt = r18		
.def r = r19			
.def g = r20			
.def b = r21			
.def mode = r22			
.def adcl_reg = r23		
.def adch_reg = r24		
 

.equ led_count = 0x08	
.equ bit_count = 0x18	
 

.dseg           
    red: .byte led_count	
    blue: .byte led_count	
    green: .byte led_count	
 

.cseg
    .org 0x000
        rjmp reset
					
    .org 0x006
        rjmp timer_interrupt
		 
    .org 0x00E
        rjmp adc_interrupt			
 

reset: 
							
    ldi tmp, low(RAMEND)	
    out SPL, tmp			
    ldi tmp, high(RAMEND)	
    out SPH, tmp			
    
    ldi tmp, 0b11111111     
    out DDRB, tmp			
 
    ldi tmp, (1 << ADEN) + (1 << ADPS0) + (1 << ADPS1) + (1 << ADIE) + (1 << ADFR)				 
    out ADCSRA, tmp																											; его режима работы
    ldi tmp, (1 << REFS0)																							; Установка опорного  
    out ADMUX, tmp																									;	напряжения АЦП 

    ldi tmp, (1 << WGM12) + (1 << CS12) + (1 << CS10)			
    out TCCR1B, tmp												
    
    ldi tmp, (1 << OCIE1A)							
    out TIMSK, tmp									
 
    ldi tmp, 0x00						
    out OCR1AH, tmp						
    ldi tmp, 0x0F						
    out OCR1AL, tmp						
 
    ldi mode, 0x01 
	
    sei				

    rjmp main			


fill_array: 
 
    st X+, r	
    st Y+, g	
    st Z+, b	
 
    dec tmp
 
ret
 

adc_interrupt:		
 
    in adcl_reg, ADCL		 
    in adch_reg, ADCH		 	
    
    cpi adch_reg, 0x00		 
    breq utter_case			

    out OCR1AH, adch_reg
    out OCR1AL, adcl_reg

reti


utter_case:			
	
    ldi adcl_reg, 0x5F
    out OCR1AH, adch_reg
    out OCR1AL, adcl_reg

reti
 

timer_interrupt:	
	
    push tmp

    ldi XL, low(red)
    ldi XH, high(red)
    ldi YL, low(green)
    ldi YH, high(green)
    ldi ZL, low(blue)
    ldi ZH, high(blue)
    
    ldi tmp, led_count  
 
        mode_1:		
 
            cpi mode, 0x01
            brne mode_2
 
            ldi r, 0x66				
            ldi g, 0x95			
            ldi b, 0xDC			
            ldi mode, 0x02

            rcall fill_array
                
            cpi tmp, 0x00  
            
	    brne PC + 3
	    pop tmp

        reti
 
        mode_2: 
 
            cpi mode, 0x02
            brne mode_3
 
            ldi r, 0xFC			
            ldi g, 0x66			
            ldi b, 0x66			
	    ldi mode, 0x03

            rcall fill_array 
                
            cpi tmp, 0x00
  
            brne PC + 3
	    pop tmp

        reti
                
	    mode_3: 
 
            ldi r, 0x66			
            ldi g, 0xEC			
            ldi b, 0x7D			
            ldi mode, 0x01

            rcall fill_array
                
            cpi tmp, 0x00  
            
   	    brne PC + 3
	    pop tmp

        reti
 
	cpi tmp, 0x00
	brne mode_1 
 

main:			

    sbi ADCSRA, ADSC		

    main_cycle:
		
	cli		
        rcall reset_led
 
        ldi XL, low(red)
        ldi XH, high(red)
        ldi YL, low(green)
        ldi YH, high(green)
        ldi ZL, low(blue)
        ldi ZH, high(blue)
 
        ldi tmp, led_count
 
        lent_cycle:		
 
            ld r, X+
            ld g, Y+
            ld b, Z+
 
            rcall led_control
            dec tmp
            brne lent_cycle
 
    sei		
    rjmp main_cycle
 

led_control:		
 
    push tmp		
    push r			
    push g			
    push b			

    ldi bit_cnt, bit_count 
 
    led_cycle:		
 
        ldi tmp, (0 << PB0)
        out PORTB, tmp
        
        lsl b		
        rol r	
        rol g		
 
        brcc set_0
 
        ldi tmp, (1 << PB0)
        out PORTB, tmp
        nop			
        nop			
        nop			
 
        rjmp end_check
 
    set_0: 
 
        ldi tmp, (1 << PB0)
        out PORTB, tmp
        nop			
 
        ldi tmp, (0 << PB0)
        out PORTB, tmp
 
    end_check:
 
        dec bit_cnt
        brne led_cycle
 
    ldi tmp, (0 << PB0)
    out PORTB, tmp
 
    pop b
    pop g
    pop r
    pop tmp
 
ret
 

reset_led:		
    
    ldi tmp, 0x20
    
    delay_cycle: 
    
        dec tmp
        brne delay_cycle
 
    ret
