/*
 *   file: led_control.asm
 *   Author: Bulenko Ivan
 */ 

; Подключение def-файлов
.include "inc/regdefs.inc"
.include "inc/constants.inc"


led_control:
	
	; Сохранение значения регистров в стек
    push temp
    push red_reg
    push green_reg
    push blue_reg
    push bit_counter
    
    ldi bit_counter, BIT_COUNT  
    

led_bit_loop:
   
    ldi temp, (0 << PB0)
    out PORTB, temp
    
    ; Подготовка следующего бита - сдвиг нужного бита
    lsl blue_reg          
    rol red_reg           
    rol green_reg         
    
	; Проверка бита
    brcc send_zero        
    
	; Отправка положительного логического сигнала
    ldi temp, (1 << PB0)
    out PORTB, temp       
    nop                   
    nop
    nop
    rjmp bit_done
    

send_zero:
	
	; Отправка отрицательного логического сигнала
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
    
	; Восстановление значений регистров из стека
    pop bit_counter
    pop blue_reg
    pop green_reg
    pop red_reg
    pop temp
    ret


reset_led:
	
	; Сброс состояния ленты
    push temp
    ldi temp, RESET_DELAY
    

reset_delay_loop:
	
	; Контроль сброса состояния ленты
    dec temp
    brne reset_delay_loop
    
    pop temp
    ret