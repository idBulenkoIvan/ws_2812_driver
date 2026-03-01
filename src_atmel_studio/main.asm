/*
 *   file: main.asm
 *   Author: Bulenko Ivan
 */ 

; Подключение def-файлов
.include "inc/regdefs.inc"
.include "inc/constants.inc"

; Инициализация ОЗУ
.dseg
	.org 0x0060                 
	red:    .byte LED_COUNT     
	green:  .byte LED_COUNT     
	blue:   .byte LED_COUNT     

; Инициализация ПЗУ
.cseg
	
	; Вектор сброса
	.org 0x0000
		rjmp reset 
	
	; Вектор прерывания таймера по сравнению             
	.org 0x0006                 
		rjmp timer_interrupt

	; Вектор прерывания АЦП
	.org 0x000E                 
		rjmp adc_interrupt


reset:
	
	; Инициализация младшего бита указателя стека
    ldi temp, low(RAMEND)
    out SPL, temp

	; Инициализация старшего бита указателя стека
    ldi temp, high(RAMEND)
    out SPH, temp

	; Настройка портов 
    ldi temp, 0b11111111    
    out DDRB, temp
    ldi temp, 0x00          
    out PORTB, temp

	; Настройка АЦП
    ldi temp, (1 << ADEN) | (1 << ADPS0) | (1 << ADPS1) | (1 << ADIE) | (1 << ADFR)
    out ADCSRA, temp         
    
    ldi temp, (1 << REFS0)   
    out ADMUX, temp

	; Настройка таймера по сравнению
    ldi temp, (1 << WGM12) | (1 << CS12) | (1 << CS10)  
    out TCCR1B, temp
    
    ldi temp, (1 << OCIE1A)  
    out TIMSK, temp
    
	; Установка начальных значений для сравнения
    ldi temp, 0x00
    out OCR1AH, temp
    ldi temp, 0x0F
    out OCR1AL, temp

    ldi mode_reg, MODE_CYAN  

    ; Глобальное разрешение прерываний
	sei        
	            
	; Запуск преобразования АЦП   
    sbi ADCSRA, ADSC


main:
	
	; Инициализация указателей на массивы
    ldi XL, low(red)
    ldi XH, high(red)
    ldi YL, low(green)
    ldi YH, high(green)
    ldi ZL, low(blue)
    ldi ZH, high(blue)
    
    ldi led_counter, LED_COUNT


main_cycle:
	
	; Отключение глобальных прерываний для безопасного обновления состояния ленты
    cli

	; Сброс состояния ленты
    rcall reset_led
    
	; Сброс указателей на начало массивов
    ldi XL, low(red)
    ldi XH, high(red)
    ldi YL, low(green)
    ldi YH, high(green)
    ldi ZL, low(blue)
    ldi ZH, high(blue)
    
    ldi led_counter, LED_COUNT


led_output_loop:
	
	; Загрузка цвета для текущего светодиода
    ld red_reg, X+
    ld green_reg, Y+
    ld blue_reg, Z+
    
	; Отправка данных на ленту
    rcall led_control
    
    dec led_counter
    brne led_output_loop
    
	; Глобальное разрешение прерываний
    sei
    
    rjmp main_cycle


timer_interrupt:

	; Сохранение контекста
    push temp
    in temp, SREG
    push temp

    ; Инициализация указателей на начало массивов
    ldi XL, low(red)
    ldi XH, high(red)
    ldi YL, low(green)
    ldi YH, high(green)
    ldi ZL, low(blue)
    ldi ZH, high(blue)
    
    ; Установка счетчика светодиодов
    ldi temp, LED_COUNT
    push temp                

    ; Выбор режима
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

    ; Чтение регистров АЦП
    in adcl_val, ADCL
    in adch_val, ADCH
    
	; Проверка на граничное значение 
    cpi adch_val, 0x00
    breq adc_min_value
    
    out OCR1AH, adch_val
    out OCR1AL, adcl_val
    reti


adc_min_value:

    ; Защита от слишком быстрых прерываний
    ldi adcl_val, ADC_MIN_VAL
    out OCR1AH, adch_val     
    out OCR1AL, adcl_val
    reti


.include "led_control.asm"
