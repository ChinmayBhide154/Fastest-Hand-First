$NOLIST
$MODLP51
$LIST

org 0000H
   ljmp MyProgram
   
org 0x000B
	ljmp Timer0_ISR
; Timer/Counter 2 overflow interrupt vector
org 0x002B
	ljmp Timer2_ISR

; These register definitions needed by 'math32.inc'
DSEG at 30H
x:   ds 4
y:   ds 4
z:   ds 4
bcd: ds 5
T2ov: ds 2 ; 16-bit timer 2 overflow (to measure the period of very slow signals)
Seed: ds 4
p1Score: ds 1
p2Score: ds 1
capacitance: ds 4


BSEG
mf: dbit 1

$NOLIST
$include(math32.inc)
$LIST

cseg
; These 'equ' must match the hardware wiring
LCD_RS equ P3.2
;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
LCD_E  equ P3.3
LCD_D4 equ P3.4
LCD_D5 equ P3.5
LCD_D6 equ P3.6
LCD_D7 equ P3.7

$NOLIST
$include(LCD_4bit.inc) ; A library of LCD related functions and utility macros
$LIST

CLK           EQU 22118400 ; Microcontroller system crystal frequency in Hz
TIMER0_OFF_RATE    EQU 65536
TIMER0_OFF_RELOAD EQU ((65536-(CLK/TIMER0_OFF_RATE)))
TIMER0_RATE   EQU 783     ; 2048Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RATE_HIGH EQU 4096
TIMER0_RATE_LOW EQU 1000
TIMER0_RELOAD EQU ((65536-(CLK/TIMER0_RATE)))
TIMER0_RELOAD_HIGH EQU ((65536-(CLK/TIMER0_RATE_HIGH)))
TIMER2_RATE   EQU 1000     ; 1000Hz, for a timer tick of 1ms
;Timer0_Rate used to change pitch
TIMER2_RELOAD EQU ((65536-(CLK/TIMER2_RATE)))

;Music Frequencies
TIMER0_RATE_A   EQU 440 
TIMER0_RATE_E   EQU 659 
TIMER0_RATE_GH  EQU 784 
TIMER0_RATE_GL  EQU 392 
TIMER0_RATE_D   EQU 587 
TIMER0_RATE_B   EQU 493 

TIMER0_RELOAD_A EQU ((65536-(CLK/TIMER0_RATE_A)))
TIMER0_RELOAD_E EQU ((65536-(CLK/TIMER0_RATE_E)))
TIMER0_RELOAD_GH EQU ((65536-(CLK/TIMER0_RATE_GH)))
TIMER0_RELOAD_GL EQU ((65536-(CLK/TIMER0_RATE_GL)))
TIMER0_RELOAD_D EQU ((65536-(CLK/TIMER0_RATE_D)))
TIMER0_RELOAD_B EQU ((65536-(CLK/TIMER0_RATE_B)))


cseg

SOUND_OUT equ P1.1
SOUND_OUT1 equ P2.3
Player_One equ P2.1
Player_Two equ P0.0


;                    	1234567890123456    <- This helps determine the location of the counter
Initial_Message:  	db 'P1            P2', 0
Overflow_Str:    	db '00           00', 0
Player_One_Text: 	db 'Player 1: ', 0
Player_Two_Text: 	db 'Player 2: ',0
Player_Win1:		db 'Congratulations ', 0
Player_One_Win2:	db 'Player1 wins!   ', 0
Player_Two_Win2:	db 'Player2 wins!   ', 0
Ready_Str: 			db '     Ready?     ', 0
Ready_3: 			db '       3        ', 0
Ready_2: 			db '       2        ', 0
Ready_1: 			db '       1        ', 0
Go: 				db '      Go!       ', 0
Play_Again:			db '   Play Again?  ', 0
Hit_Reset: 			db '   Press Reset  ', 0



; Sends 10-digit BCD number in bcd to the LCD
Display_10_digit_BCD:
	Display_BCD(bcd+4)
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	ret

TIMER0_RATE_B_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_B)
	mov TL0, #low(TIMER0_RELOAD_B)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_B)
	mov RL0, #low(TIMER0_RELOAD_B)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret

TIMER0_RATE_D_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_D)
	mov TL0, #low(TIMER0_RELOAD_D)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret
TIMER0_RATE_GL_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_GL)
	mov TL0, #low(TIMER0_RELOAD_GL)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_GL)
	mov RL0, #low(TIMER0_RELOAD_GL)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret

Timer0_RATE_E_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_E)
	mov TL0, #low(TIMER0_RELOAD_E)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_E)
	mov RL0, #low(TIMER0_RELOAD_E)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret
	
TIMER0_RATE_A_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_A)
	mov TL0, #low(TIMER0_RELOAD_A)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_A)
	mov RL0, #low(TIMER0_RELOAD_A)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret
	
TIMER0_RATE_GH_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_GH)
	mov TL0, #low(TIMER0_RELOAD_GH)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_GH)
	mov RL0, #low(TIMER0_RELOAD_GH)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
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

Timer0_OFF_Init:
	mov a, TMOD
	anl a, #0xf0 ; Clear the bits for timer 0
	orl a, #0x01 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_OFF_RELOAD)
	mov TL0, #low(TIMER0_OFF_RELOAD)
	; Set autoreload value
	mov RH0, #high(TIMER0_OFF_RELOAD)
	mov RL0, #low(TIMER0_OFF_RELOAD)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret
	


Timer0_ISR:
	;clr TF0  ; According to the data sheet this is done for us already.
	cpl SOUND_OUT ; Connect speaker to P1.1!
	cpl SOUND_OUT1
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
    
    mov p1Score, #0
    mov p2Score, #0
    
	Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)
    
    lcall Timer0_Init
    lcall InitTimer2
    
    mov Seed+0, TH2
    mov Seed+1, #0x01
    mov Seed+2, #0x87
    mov Seed+3, TL2
    
    lcall Start_Lights
    lcall Make_Music
    lcall Make_Music
    
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    
    lcall End_Round
    
    lcall One_Cycle
forever:
    ; synchronize with rising edge of the signal applied to pin P0.0
    clr TR2 ; Stop timer 2
    mov TL2, #0
    mov TH2, #0
    mov T2ov+0, #0
    mov T2ov+1, #0
    clr TF2
    setb TR2
    
    lcall synch1
    lcall synch2
    lcall measure1
    lcall measure2
    lcall skip_this
    ret
synch1:
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal ; If the count is larger than 0x01ffffffff*45ns=1.16s, we assume there is no signal
    jb P0.0, synch1
    ret
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
    ret
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
    Send_Constant_String(#Overflow_Str)
    ljmp forever ; Repeat! 
    
skip_this:
	; Make sure [T2ov+1, T2ov+2, TH2, TL2]!=0
	mov a, TL2
	orl a, TH2
	orl a, T2ov+0
	orl a, T2ov+1
	jz no_signal
	
	lcall Calculate_Period

    ret
forever2:
    ; synchronize with rising edge of the signal applied to pin P0.0
    clr TR2 ; Stop timer 2
    mov TL2, #0
    mov TH2, #0
    mov T2ov+0, #0
    mov T2ov+1, #0
    clr TF2
    setb TR2
    
    lcall synch1b
    lcall synch2b
    lcall measure1b
    lcall measure2b
    lcall skip_this2
    ret
synch1b:
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal ; If the count is larger than 0x01ffffffff*45ns=1.16s, we assume there is no signal
    jb P2.1, synch1b
    ret
synch2b:    
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal_jump
    jnb P2.1, synch2b
    ; Measure the period of the signal applied to pin P0.0
    clr TR2
    mov TL2, #0
    mov TH2, #0
    mov T2ov+0, #0
    mov T2ov+1, #0
    clr TF2
    setb TR2 ; Start timer 2
    ret
measure1b:
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal_jump 
    jb P2.1, measure1b
measure2b:    
	mov a, T2ov+1
	anl a, #0xfe
	jnz no_signal_jump
    jnb P2.1, measure2b
    clr TR2 ; Stop timer 2, [T2ov+1, T2ov+0, TH2, TL2] * 45.21123ns is the period
	sjmp skip_this2

no_signal_jump:	
	ljmp no_signal
    
skip_this2:
	; Make sure [T2ov+1, T2ov+2, TH2, TL2]!=0
	mov a, TL2
	orl a, TH2
	orl a, T2ov+0
	orl a, T2ov+1
	jz no_signal_jump
	lcall Calculate_Period
    ret
    
Inc_Score:
	lcall forever

	load_y(928000)
	lcall x_gt_y
	;if the capacitance is greater than 200, mf will be set to 1
	
	jb mf, Add_Score
	ret
	
Add_Score:
	clr mf
	;inc p1Score
	clr a
	Set_Cursor(2, 1)
	
	mov a, p1Score
	add a, #0x01
	da a
	mov p1Score, a
	Display_BCD(p1Score)
	lcall Green_light
	lcall Compare_Score_p1
	ljmp End_Round
	
Inc_Score_p2:
	clr mf
	lcall forever2
	load_y(935000)
	lcall x_gt_y
	jb mf, Add_Score_p2
	ret

Add_Score_p2:
	clr mf
	clr a
	Set_Cursor(2, 15)
	mov a, p2Score
	add a, #0x01
	da a
	mov p2Score, a
	Display_BCD(p2Score)
	lcall Green_Light
	lcall Compare_Score_p2
	ljmp End_Round

Bridge_Forever:
	ljmp forever
	
; pseudocode:
; 	if P1 capacitance > 50 (Can replace this number), increment P1
;   if P2 capacitance > 50 , increment P2
;	lcall compareScores
;	ret

Dec_Score:
	clr mf
	lcall forever
	;lcall Calculate_Capacitance
	;mov x+0, capacitance+0
	;mov x+1, capacitance+1
	;mov x+2, capacitance+2
	;mov x+3, capacitance+3
	Set_Cursor(2, 1)
	Display_BCD(p1Score)
	load_y(928000)
	lcall x_gt_y
	;if the capacitance is greater than 200, mf will be set to 1
	
	jb mf, Sub_Score
	ret
	
Sub_Score:
	clr mf
	;dec p1Score

	;load_x(p1Score)
	mov a, p1Score
	add a, #0x99
	da a
	mov p1Score, a
		
	Set_Cursor(2, 1)
	;lcall hex2bcd
	Display_BCD(p1Score)
	lcall Timer0_OFF_Init
	lcall Red_Light
	
	;ret
	ljmp End_Round

Dec_Score_p2:
	clr mf
	lcall forever2
	Set_Cursor(2, 15)
	Display_BCD(p2Score)
	load_y(935000)
	lcall x_gt_y
	;if the capacitance is greater than 200, mf will be set to 1
	
	jb mf, Sub_Score_p2
	ret

Sub_Score_p2:
	clr mf
	mov a, p2Score
	add a, #0x99
	da a
	mov p2Score, a
		
	Set_Cursor(2, 15)
	Display_BCD(p2Score)
	lcall Red_Light
	ljmp End_Round
; pseudocode:
; 	if P1 capacitance > 50 (Can replace this number), decrement P1
;   if P2 capacitance > 50 , decrement P2
;	ret    

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
    ret
    
Wait_Random_Time:
    lcall Random
	Wait_Milli_Seconds(Seed+0)
	lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+1)
    ;Inc_Score ... so on in between each random wait time
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+2)
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+3)
    lcall Dec_Score
	lcall Dec_Score_p2
	
	Wait_Milli_Seconds(Seed+0)
	lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+1)
    ;Inc_Score ... so on in between each random wait time
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+2)
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+3)
    lcall Dec_Score
	lcall Dec_Score_p2
	
	Wait_Milli_Seconds(Seed+0)
	lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+1)
    ;Inc_Score ... so on in between each random wait time
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+2)
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+3)
    lcall Dec_Score
	lcall Dec_Score_p2
	
	Wait_Milli_Seconds(Seed+0)
	lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+1)
    ;Inc_Score ... so on in between each random wait time
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+2)
    lcall Dec_Score
	lcall Dec_Score_p2
    Wait_Milli_Seconds(Seed+3)
    lcall Dec_Score
	lcall Dec_Score_p2
    
    ret    
    
Wait_Constant_Time:
	Wait_Milli_Seconds(#255)
	lcall Inc_Score
	lcall Inc_Score_p2
    Wait_Milli_Seconds(#255)
    lcall Inc_Score
	lcall Inc_Score_p2
    Wait_Milli_Seconds(#255)
    lcall Inc_Score
	lcall Inc_Score_p2
    Wait_Milli_Seconds(#255)
    lcall Inc_Score
	lcall Inc_Score_p2
    Wait_Milli_Seconds(#255)
    lcall Inc_Score
	lcall Inc_Score_p2
    Wait_Milli_Seconds(#255)
    lcall Inc_Score
	lcall Inc_Score_p2
    Wait_Milli_Seconds(#255)
    lcall Inc_Score
	lcall Inc_Score_p2
    Wait_Milli_Seconds(#255)
    ret
    
One_Cycle:
	lcall forever
	lcall Timer0_Init
	lcall Wait_Random_Time ; in here, we are continuously checking if someone slaps, if they do, we decrement
	lcall forever
    lcall Timer0_HIGH_Init
    lcall forever
    ;Wait for slap, if slapped, increment score
    lcall Wait_Constant_Time ; in here, we are continuously checking if someone slaps, if they do we increment
    lcall forever
    lcall Timer0_Init
    ;Wait for slap, if slapped, decrement score
    ljmp One_Cycle
    
Compare_Score_p1:
;   if p1Score == 5 , ljmp P1_Wins
	mov x+0, p1Score
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	load_y(5)
	lcall x_eq_y
	jb mf, P1_Wins
	ret
	
Compare_Score_p2:
;	if p2Score == 5 , ljmp P2_Wins
	mov x+0, p2Score
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	load_y(5)
	lcall x_eq_y
	jb mf, P2_Wins
	ret
	
Check_0_p1:
	

Check_0_p2:
	

P1_Wins:
; Display some sort of message
	Set_Cursor(1, 1)
	Send_Constant_String(#Player_Win1)
	Set_Cursor(2, 1)
	Send_Constant_String(#Player_One_Win2)
	lcall Game_Over
	;possibly leave in this state til reset
	
P2_Wins:
; display some sort of message
	Set_Cursor(1, 1)
	Send_Constant_String(#Player_Win1)
	Set_Cursor(2, 1)
	Send_Constant_String(#Player_Two_Win2)
	;possibly leave in this state til reset
	lcall Game_Over
	
Start_Screen:

Green_Light:
	lcall Timer0_OFF_Init
	cpl P2.5
	Wait_Milli_Seconds(#255)
	cpl P2.7
	Wait_Milli_Seconds(#255)
	cpl P0.7
	Wait_Milli_Seconds(#255)
	cpl P0.5
	Wait_Milli_Seconds(#255)
	cpl P2.5
	Wait_Milli_Seconds(#255)
	cpl P2.7
	Wait_Milli_Seconds(#255)
	cpl P0.7
	Wait_Milli_Seconds(#255)
	cpl P0.5
	ret
	
Red_Light:
	lcall Timer0_OFF_Init
	cpl P0.1
	Wait_Milli_Seconds(#255)
	cpl P0.2
	Wait_Milli_Seconds(#255)
	cpl P0.3
	Wait_Milli_Seconds(#255)
	cpl P0.4
	Wait_Milli_Seconds(#255)
	cpl P0.1
	Wait_Milli_Seconds(#255)
	cpl P0.2
	Wait_Milli_Seconds(#255)
	cpl P0.3
	Wait_Milli_Seconds(#255)
	cpl P0.4
	ret
	
Start_Lights:
	lcall Timer0_OFF_Init
	cpl P2.5
	cpl P0.1
	Wait_Milli_Seconds(#255)
	cpl P2.7
	cpl P0.2
	Wait_Milli_Seconds(#255)
	cpl P0.7
	cpl P0.3
	Wait_Milli_Seconds(#255)
	cpl P0.5
	cpl P0.4
	Wait_Milli_Seconds(#255)
	cpl P2.5
	cpl P0.1
	Wait_Milli_Seconds(#255)
	cpl P2.7
	cpl P0.2
	Wait_Milli_Seconds(#255)
	cpl P0.7
	cpl P0.3
	Wait_Milli_Seconds(#255)
	cpl P0.5
	cpl P0.4
	ret
	
Calculate_Period:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, T2ov+0
	mov x+3, T2ov+1
	
	load_y(45) ; One clock pulse is 1/22.1184MHz=45.21123ns
	lcall mul32
	load_y(10) ;mult by 1.44 by mult 144/100
	lcall mul32
	ret
	
	
End_Round:
	lcall Timer0_OFF_Init
;	Wait_Milli_Seconds(#255)
   ; Wait_Milli_Seconds(#255)
    ;Wait_Milli_Seconds(#255)
    ;Wait_Milli_Seconds(#255)
    ;Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Set_Cursor(1, 1)
    Send_Constant_String(#Ready_Str)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Set_Cursor(1, 1)
    Send_Constant_String(#Ready_3)
    
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Set_Cursor(1, 1)
    Send_Constant_String(#Ready_2)
    
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Set_Cursor(1, 1)
    Send_Constant_String(#Ready_1)
    
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Set_Cursor(1, 1)
    Send_Constant_String(#Go)
    
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)
    ljmp One_Cycle

Game_Over:
	lcall Timer0_OFF_Init
	
	Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    
    Set_Cursor(1,1)
	Send_Constant_String(#Play_Again)
	Set_Cursor(2, 1)
	Send_Constant_String(#Hit_Reset)	
	ljmp Game_Over
	
Make_Music:
	lcall Timer0_Rate_E_Init
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	lcall Timer0_Rate_D_Init
	lcall Timer0_OFF_Init
	
	lcall Timer0_Rate_D_Init
	Wait_Milli_Seconds(#150)
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#20)
	
	lcall Timer0_Rate_D_Init
	Wait_Milli_Seconds(#150)
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#20)
	
	lcall Timer0_Rate_D_Init
	Wait_Milli_Seconds(#150)
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#20)
	
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	
	lcall Timer0_Rate_A_Init
	Wait_Milli_Seconds(#150)
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#20)
	
	lcall Timer0_Rate_A_Init
	Wait_Milli_Seconds(#150)
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#20)
	
	lcall Timer0_Rate_A_Init
	Wait_Milli_Seconds(#150)
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#20)
	
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	
	lcall Timer0_Rate_GH_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_Rate_E_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_Rate_D_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_Rate_B_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_Rate_A_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_Rate_B_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_Rate_A_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_Rate_GL_Init
	Wait_Milli_Seconds(#150)
	
	lcall Timer0_OFF_Init
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	Wait_Milli_Seconds(#255)
	
	ret
	
end
;At end, program jumps back to the very top