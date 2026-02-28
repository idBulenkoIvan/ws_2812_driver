/*
 *   file: constants.inc
 *   Author: Bulenko Ivan
 */ 

; Конфигурация ленты 
.equ LED_COUNT      = 0x08		; Количество светодиодов в ленте
.equ BIT_COUNT      = 0x18      ; Количество бит на светодиод

; Защита от нуля на АЦП
.equ ADC_MIN_VAL    = 0x5F		; Минимальное значение для таймера

; Режимы работы
.equ MODE_CYAN      = 0x01 
.equ MODE_RED       = 0x02
.equ MODE_GREEN     = 0x03

; Цвета для режимов в формате RGB
.equ COLOR_CYAN_G   = 0x95     
.equ COLOR_CYAN_R   = 0x66     
.equ COLOR_CYAN_B   = 0xDC     

.equ COLOR_RED_G    = 0x66     
.equ COLOR_RED_R    = 0xFC     
.equ COLOR_RED_B    = 0x66     

.equ COLOR_GREEN_G  = 0xEC     
.equ COLOR_GREEN_R  = 0x66     
.equ COLOR_GREEN_B  = 0x7D     

; Задержка для сброса ленты
.equ RESET_DELAY    = 0x20