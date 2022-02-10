$NOLIST
$MODLP51
$LIST
; my edit

;timer closer to LCD: is connected to pin 2.0
; other timer is connected to pin 2.1

org 0000H
   ljmp MyProgram

; Timer/Counter 0 overflow interrupt vector
org 0x000B
	ljmp Timer0_ISR   
; Timer/Counter 2 overflow interrupt vector
org 0x002B
	ljmp Timer2_ISR

; These register definitions needed by 'math32.inc'
DSEG at 30H
x:   ds 4
y:   ds 4
bcd: ds 5
T2ov: ds 2 ; 16-bit timer 2 overflow (to measure the period of very slow signals)
Seed: ds 4
p1Score: ds 3
p2Score: ds 3

BSEG
mf: dbit 1

$NOLIST
$include(math32.inc)
$LIST


CLK           EQU 22118400 ; Microcontroller system crystal frequency in Hz
TIMER0_RATE   EQU 1000     ; 2048Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RATE_HIGH EQU 4096
TIMER0_RATE_LOW EQU 1000
TIMER0_RELOAD EQU ((65536-(CLK/TIMER0_RATE)))
TIMER0_RELOAD_HIGH EQU ((65536-(CLK/TIMER0_RATE_HIGH)))
TIMER2_RATE   EQU 1000     ; 1000Hz, for a timer tick of 1ms
;Timer0_Rate used to change pitch
TIMER2_RELOAD EQU ((65536-(CLK/TIMER2_RATE)))

cseg
; These 'equ' must match the hardware wiring
LCD_RS equ P3.2
;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
LCD_E  equ P3.3
LCD_D4 equ P3.4
LCD_D5 equ P3.5
LCD_D6 equ P3.6
LCD_D7 equ P3.7
SOUND_OUT equ P1.1

$NOLIST
$include(LCD_4bit.inc) ; A library of LCD related functions and utility macros
$LIST

;                     1234567890123456    <- This helps determine the location of the counter
Initial_Message:  db 'P1            P2', 0
No_Signal_Str:    db '', 0

Timer0_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD)
	mov TL0, #low(TIMER0_RELOAD)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD)
	mov RL0, #low(TIMER0_RELOAD)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret
	
Timer0_HIGH_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_HIGH)
	mov TL0, #low(TIMER0_RELOAD_HIGH)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_HIGH)
	mov RL0, #low(TIMER0_RELOAD_HIGH)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret
Timer0_ISR:
	;clr TF0  ; According to the data sheet this is done for us already.
	cpl SOUND_OUT ; Connect speaker to P1.1!
	reti

; Sends 10-digit BCD number in bcd to the LCD
Display_10_digit_BCD:
	Display_BCD(bcd+4)
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	ret

;Initializes timer/counter 2 as a 16-bit timer
InitTimer2:
	mov T2CON, #0 ; Stop timer/counter.  Set as timer (clock input is pin 22.1184MHz).
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
	setb ET2
    ret

Timer2_ISR:
	clr TF2  ; Timer 2 doesn't clear TF2 automatically. Do it in ISR
	push acc
	inc T2ov+0
	mov a, T2ov+0
	jnz Timer2_ISR_done
	inc T2ov+1
Timer2_ISR_done:
	pop acc
	reti

;---------------------------------;
; Hardware initialization         ;
;---------------------------------;
Initialize_All:
    lcall InitTimer2
    lcall LCD_4BIT ; Initialize LCD
    setb EA
	ret

;---------------------------------;
; Main program loop               ;
;---------------------------------;
MyProgram:
    ; Initialize the hardware:
    mov SP, #7FH
    lcall Initialize_All
    setb P0.0 ; Pin is used as input
    
    lcall Timer0_Init
    lcall InitTimer2

	Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)
    
    Set_Cursor(2, 1)
    mov x, p1Score
    add a, #0x00
    da a
    mov p1Score, a
    Display_BCD(p1Score)
    
    Set_Cursor(2, 15)
    mov x, p2Score
    add a, #0x00
    da a
    mov p2Score, a
    Display_BCD(p1Score)
    
    lcall Calculate_Capacitance_P21 
    
forever:
	; Repeated Random time wait calls are here for show just for now
	;Set_Cursor(1, 1)
	;lcall Random
	;wait random amount of time
    lcall Wait_Random_Time
    lcall Timer0_HIGH_Init
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    lcall Timer0_Init
    lcall Calculate_Capacitance_P21 
    ;change
    
    lcall Random
	;wait random amount of time
    lcall Wait_Random_Time
    lcall Random
	;wait random amount of time
    lcall Wait_Random_Time
    lcall Random
	;wait random amount of time
    lcall Wait_Random_Time
    lcall Random
	;wait random amount of time
    lcall Wait_Random_Time
    
    
    clr TR2 ; Stop timer 2
    mov TL2, #0
    mov TH2, #0
    mov T2ov+0, #0
    mov T2ov+1, #0
    clr TF2
    setb TR2
    
    ;Randomize button connected at P2.4
    jb P2.4, $
    
    mov Seed+0, TH2
    mov Seed+1, #0x01
    mov Seed+2, #0x87
    mov Seed+3, TL2
    clr TR2
    
synch1:
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal ; If the count is larger than 0x01ffffffff*45ns=1.16s, we assume there is no signal
    jb P0.0, synch1
synch2:    
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal
    jnb P0.0, synch2
    
    ; Measure the period of the signal applied to pin P0.0
    clr TR2
    mov TL2, #0
    mov TH2, #0
    mov T2ov+0, #0
    mov T2ov+1, #0
    clr TF2
    setb TR2 ; Start timer 2
measure1:
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal 
    jb P0.0, measure1
measure2:    
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal
    jnb P0.0, measure2
    clr TR2 ; Stop timer 2, [T2ov+1, T2ov+0, TH2, TL2] * 45.21123ns is the period

	sjmp skip_this
no_signal:	
	Set_Cursor(2, 1)
    Send_Constant_String(#No_Signal_Str)
    ljmp forever ; Repeat! 
skip_this:

	; Make sure [T2ov+1, T2ov+2, TH2, TL2]!=0
	mov a, TL2
	orl a, TH2
	orl a, T2ov+0
	orl a, T2ov+1
	jz no_signal
	; Using integer math, convert the period to frequency:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, T2ov+0
	mov x+3, T2ov+1
	
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(2, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD
    ljmp forever ; Repeat! 


;Generates random number
Random: 
	; Dont worry about this, it is just some math that is good enough to randomize numbers enough for our purposes
    mov x+0, Seed+0
    mov x+1, Seed+1
    mov x+2, Seed+2
    mov x+3, Seed+3
    Load_y(214013)
    lcall mul32
    Load_y(2531011)
    lcall add32
    mov Seed+0, x+0
    mov Seed+1, x+1
    mov Seed+2, x+2
    mov Seed+3, x+3
    
    ;Set_Cursor(1, 3)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD
	lcall Timer0_ISR ;Why no alarm trigger?
    ret
    
Wait_Random_Time:
	Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    ret
    
Calculate_Capacitance_P21: ; Left one
	Load_y(45) ; One clock pulse is 1/22.1184MHz=45.21123ns
	lcall mul32
	
	Load_y(10)
	lcall div32
	
	Load_y(10)
	lcall div32
	
	Load_y(144)
	lcall mul32
	
	Load_y(100)
	lcall div32
	
	Load_y(100)
	lcall div32
	
	Load_y(10)
	lcall div32
	
	Load_y(3)
	lcall div32
	
	Load_y(100)
	lcall mul32
	
	Load_y(100)
	lcall sub32
	
	Load_y(95)
	lcall sub32
	
	; Convert the result to BCD and display on LCD
	Set_Cursor(1, 3)
	lcall hex2bcd
	lcall Display_10_digit_BCD
	ret

Calculate_Capacitance_P20: ; Right one
    
end