$NOLIST
$MODLP51
$LIST

org 0000H
   ljmp MyProgram
   
; Timer/Counter 2 overflow interrupt vector
org 0x002B
	ljmp Timer2_ISR

; These register definitions needed by 'math32.inc'
DSEG at 30H
x:   ds 4
y:   ds 4
bcd: ds 5
T2ov: ds 2 ; 16-bit timer 2 overflow (to measure the period of very slow signals)

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

<<<<<<< Updated upstream
;                     1234567890123456    <- This helps determine the location of the counter
Initial_Message:  db 'Capacitance: nF', 0
No_Signal_Str:    db 'No signal      ', 0
=======
CLK           EQU 22118400 ; Microcontroller system crystal frequency in Hz
TIMER0_OFF_RATE    EQU 65536
TIMER0_OFF_RELOAD EQU ((65536-(CLK/TIMER0_OFF_RATE)))
TIMER0_RATE   EQU 1000     ; 2048Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RATE_HIGH EQU 4096
TIMER0_RATE_LOW EQU 1000
TIMER0_RELOAD EQU ((65536-(CLK/TIMER0_RATE)))
TIMER0_RELOAD_HIGH EQU ((65536-(CLK/TIMER0_RATE_HIGH)))
TIMER2_RATE   EQU 1000     ; 1000Hz, for a timer tick of 1ms
;Timer0_Rate used to change pitch
TIMER2_RELOAD EQU ((65536-(CLK/TIMER2_RATE)))

;Music Frequencies
TIMER0_RATE_A   EQU 440 


cseg

SOUND_OUT equ P1.1
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

>>>>>>> Stashed changes

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

	Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)
    
forever:
    ; synchronize with rising edge of the signal applied to pin P0.0
    clr TR2 ; Stop timer 2
    mov TL2, #0
    mov TH2, #0
    mov T2ov+0, #0
    mov T2ov+1, #0
    clr TF2
    setb TR2
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
<<<<<<< Updated upstream
	; Using integer math, convert the period to frequency:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, T2ov+0
	mov x+3, T2ov+1
	Load_y(45) ; One clock pulse is 1/22.1184MHz=45.21123ns
	lcall mul32
	
	Load_y(10)
	lcall div32
=======
	
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

	load_y(940000)
	lcall x_gt_y
	;if the capacitance is greater than 200, mf will be set to 1
>>>>>>> Stashed changes
	
	Load_y(10)
	lcall div32
	
	Load_y(144)
	lcall mul32
	
<<<<<<< Updated upstream
	Load_y(100)
	lcall div32
	
	Load_y(220)
	lcall div32
	
	Load_y(10)
	lcall div32
	
	Load_y(100)
	lcall mul32
=======
	mov a, p1Score
	add a, #0x01
	da a
	mov p1Score, a
	Display_BCD(p1Score)
	lcall Compare_Score_p1
	ljmp End_Round
	
Inc_Score_p2:
	clr mf
	lcall forever2
	load_y(940000)
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
	load_y(940000)
	lcall x_gt_y
	;if the capacitance is greater than 200, mf will be set to 1
>>>>>>> Stashed changes
	
	Load_y(100)
	lcall sub32
	
	; Convert the result to BCD and display on LCD
	Set_Cursor(2, 1)
<<<<<<< Updated upstream
	lcall hex2bcd
	lcall Display_10_digit_BCD
    ljmp forever ; Repeat! 
    

end
=======
	;lcall hex2bcd
	Display_BCD(p1Score)
	
	;ret
	ljmp End_Round

Dec_Score_p2:
	clr mf
	lcall forever2
	Set_Cursor(2, 15)
	Display_BCD(p2Score)
	load_y(940000)
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
	Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    Wait_Milli_Seconds(#255)
    ljmp One_Cycle

Game_Over:
	lcall Timer0_OFF_Init	
	ljmp Game_Over
end
;At end, program jumps back to the very top
>>>>>>> Stashed changes
