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

.equ led_count = 0x08	                ; Определяем константу led_count = 8 - количество
                                        ; светодиодов в светодиодной ленте

.equ bit_count = 0x18	                ; Определяем константу bit_count = 24 - количество бит,
                                        ; необходимых для управления одним светодиодом

.dseg
red: .byte led_count	    ; Задаем массивы размером led_count
blue: .byte led_count	    ; байт на каждый цветовой канал
green: .byte led_count


.cseg
    .org 0x000
        rjmp reset		 	; Переход к метке reset при перезапуске МК

    .org 0x006
        rjmp timer_interrupt		; Переход к метке timer_interrupt по достижению
                                    	; таймером заданного значения
    .org 0x00E
        rjmp adc_interrupt		; Переход к метке adc_interrupt по завершении
                                    	; преобразования на АЦП


reset:

    ldi tmp, low(RAMEND)	; Установка младшего байта
    out SPL, tmp		; указателя стека

    ldi tmp, high(RAMEND)	; Установка старшего байта
    out SPH, tmp		; указателя стека

    ldi tmp, 0b11111111     	; Устанавливаем направление
    out DDRB, tmp	    	; передачи данных порта B

    ldi tmp, (1 << ADEN) + (1 << ADPS0) + (1 << ADPS1) + (1 << ADIE) + (1 << ADFR)		; Конфигурация АЦП и
    out ADCSRA, tmp										; его режима работы													; его режима работы

    ldi tmp, (1 << REFS0)																					; Установка опорного
    out ADMUX, tmp																							; напряжения АЦП

    ldi tmp, (1 << WGM12) + (1 << CS12) + (1 << CS10)						; Установка предделителя
    out TCCR1B, tmp										; тактовой частоты

    ldi tmp, (1 << OCIE1A)							; Устанавливаем генерацию прерывания
    out TIMSK, tmp								; по совпадению

	ldi tmp, 0x00						; Установка старшего байта
    out OCR1AH, tmp						; регистра сравнения

    ldi tmp, 0x0F						; Установка младшего байта
    out OCR1AL, tmp						; регистра сравнения

    ldi mode, 0x01

	sei				; Устанавливаем глобальный флаг прерываний

    rjmp main


fill_array:

    st X+, r	; Загружаем значения
    st Y+, g	; из регистров r, g, b
    st Z+, b	; в массивы

    dec tmp

ret


adc_interrupt:		; Функция:
                    	; - Cчитывает значения с АЦП и передает их в регистр сравнения таймера

    in adcl_reg, ADCL
    in adch_reg, ADCH
	cpi adch_reg, 0x00
	breq utter_case

    out OCR1AH, adch_reg
    out OCR1AL, adcl_reg

reti


utter_case:		; Функция;
                    	; - Обрабатывает крайний случай обработки данных с АЦП

	ldi adcl_reg, 0x5F
	out OCR1AH, adch_reg
	out OCR1AL, adcl_reg

reti


timer_interrupt:	; Функция:
                    	; - Обрабатывает прерывание по таймеру
                    	; - Генерирует следующее состояние светодиодной ленты

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

	sbi ADCSRA, ADSC		; Запускаем преобразование на АЦП

    main_cycle:

		cli	  	; Снимаем глобальный флаг прерываний, чтобы
                          	; безопасно обновить состояние светодиодной ленты
        rcall reset_led

        ldi XL, low(red)
        ldi XH, high(red)
        ldi YL, low(green)
        ldi YH, high(green)
        ldi ZL, low(blue)
        ldi ZH, high(blue)

        ldi tmp, led_count

        lent_cycle:		; Цикл, внутри которого передаются и обрабатываются
                        	; биты соответствующих цветовых каналов

            ld r, X+
            ld g, Y+
            ld b, Z+

            rcall led_control
            dec tmp
            brne lent_cycle

    sei		            	; Устанавливаем глобальный флаг прерываний, чтобы
                        	; разрешить обработку по таймеру/АЦП
    rjmp main_cycle


led_control:		; Функция:
                    	; - Передает данные на светодиодную ленту

    push tmp
    push r
    push g
    push b

    ldi bit_cnt, bit_count

    led_cycle:		; Цикл, отвечающий за загрузку данных в ленту
                    	; в соответствии с битами цветовых каналов

        ldi tmp, (0 << PB0)
        out PORTB, tmp

        lsl b
        rol r
        rol g

        brcc set_0

        ldi tmp, (1 << PB0)
        out PORTB, tmp
        nop			        ; Удержание определенного в соответствии с документацией
        nop			        ; тайминга для подачи управляющего сигнала
        nop

        rjmp end_check

    set_0:

        ldi tmp, (1 << PB0)
        out PORTB, tmp
        nop			        ; Удержание определенного в соответствии с документацией
                            		; тайминга для подачи управляющего сигнала
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


reset_led:		; Функция:
                    	; - Сбрасывает состояние ленты перед последующим обновлением

    ldi tmp, 0x20

    delay_cycle:

        dec tmp
        brne delay_cycle

	ret
