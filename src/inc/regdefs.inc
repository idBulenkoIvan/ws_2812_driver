/*  
 *   file: regdefs.inc
 *	 Author: Bulenko Ivan
 */ 

.def temp        = r16		; Временные регистр
.def bit_counter = r17      ; Счетчик бит
.def led_counter = r18      ; Счетчик светодиодов

.def red_reg     = r19      ; Текущее значение красной составляющей
.def green_reg   = r20		; Текущее значение зеленой составляющей
.def blue_reg    = r21      ; Текущее значение синей составляющей

.def mode_reg    = r22      ; Текущий режим работы
.def adcl_val    = r23      ; Младший байт АЦП
.def adch_val    = r24      ; Старший байт АЦП

.def save_sreg   = r25      ; Для сохранения SREG в прерываниях