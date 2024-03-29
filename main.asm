.def gumb_checker = r23
.def gumb_stanje = r24
.def random = r19
.def sprememba_casa = r2
.def tocke = r10
.def temp_reg = r26
.def tocke_to_ascii_enice = r8
.def tocke_to_ascii_desetice = r9
setup:
	clr r10
	clr r9
	clr r8
	clr r26
	ldi r21, 0
	ldi r22, 0
	ldi r16, 200
	mov r2, r16
	ldi r25, 22
	mov r3, r25
	ldi r16, 0xff
	out ddrb, r16
	out ddrd, r16
	cbi portb, 0
	rcall inicializacija
	ldi zh, high(load * 2)
	ldi zl, low(load * 2)
	cbi ddrb, 2
	cbi ddrb, 3
	cbi ddrb, 4
	cbi ddrb, 5
	call loading_screen_loop

	.org 0x0050
load:
	.db 3,1,4,2,3,4,1,3,2,4,1,3,2,4,1,3,2,1,4,1,3,4,3,1,2,4,3,1,3,2,3,1,2,3,4,1,3,2,1,3,2,4,1,3,2,3,1,3,4,2,3,1,4,0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////// GLAVNI PROGRAM //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

program:
	call lcd_off
	call screen
	call delay_seconds
	call lcd_off
	call read
	call delay_seconds
	clr r19
	jmp program

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

loading_screen_loop:
	call loading_screen_1
	call delay_loading
	call delay_loading
	call lcd_off
	call loading_redy
	call delay_loading
	call lcd_off
	ret

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

read:
clr r20
	jmp read_r19
	read_r19:
		lpm r19, z+
		cpi r19, 0
		brne pick_random_krt
		call end_screen_loop
		ret
	pick_random_krt:
		cpi r19, 1
		breq krt1_ven_loop
		cpi r19, 2
		breq krt2_ven_loop
		cpi r19, 3
		breq krt3_ven_loop
		cpi r19, 4
		breq krt4_ven_loop
		ret

end_screen_loop:
	mov r21, r12
	cpi r21, 1
	breq cheater_loop
	mov r21, r10
	cpi r21, 50
	breq x_loop
	cpi r21, 50 
	brsh cheater_loop
	cpi r21, 0
	breq looser_screen_loop
	call load_tocke
	call end_screen
	jmp end_screen_loop

krt1_ven_loop:
	call load_tocke
	call krt1_ven
	ret 
krt2_ven_loop:
	call load_tocke
	call krt2_ven
	ret
krt3_ven_loop:
	call load_tocke
	call krt3_ven
	ret
krt4_ven_loop:
	call load_tocke
	call krt4_ven
	ret

x_loop:
	call x_screen
	jmp x_loop

looser_screen_loop:
	call looser_screen
	jmp looser_screen_loop

cheater_loop:
	call cheater_screen
	jmp cheater_loop

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
krt1_ven_narobe_loop:
	call lcd_off
	call load_tocke
	call krt1_ven_narobe
	call delay_msx3
	jmp program
	ret
krt2_ven_narobe_loop:
	call lcd_off
	call load_tocke
	call krt2_ven_narobe
	call delay_msx3
	jmp program
	ret
krt3_ven_narobe_loop:
	call lcd_off
	call load_tocke
	call krt3_ven_narobe
	call delay_msx3
	jmp program
	ret
krt4_ven_narobe_loop:
	call lcd_off
	call load_tocke
	call krt4_ven_narobe
	call delay_msx3
	jmp program
	ret

gumb_pritisk:
	mov r23, r19
	cp r23, r24
	breq dodaj_tocke
	jmp krt_narobe
dodaj_tocke:
	inc r10
	jmp krt_pravilno
krt_narobe:
	cpi gumb_stanje, 0x01
	breq krt1_ven_narobe_loop
	cpi gumb_stanje, 0x02
	breq krt2_ven_narobe_loop
	cpi gumb_stanje, 0x03
	breq krt3_ven_narobe_loop
	cpi gumb_stanje, 0x04
	breq krt4_ven_narobe_loop	
	ret
krt_pravilno:
	cpi gumb_stanje, 0x01
	breq krt1_ven_pravilno_loop
	cpi gumb_stanje, 0x02
	breq krt2_ven_pravilno_loop
	cpi gumb_stanje, 0x03
	breq krt3_ven_pravilno_loop
	cpi gumb_stanje, 0x04
	breq krt4_ven_pravilno_loop	
	ret

krt1_ven_pravilno_loop:
	call lcd_off
	call load_tocke
	call krt1_ven_pravilno
	call delay_msx3
	jmp program
	ret
krt2_ven_pravilno_loop:
	call lcd_off
	call load_tocke
	call krt2_ven_pravilno
	call delay_msx3
	jmp program
	ret
krt3_ven_pravilno_loop:
	call lcd_off
	call load_tocke
	call krt3_ven_pravilno
	call delay_msx3
	jmp program
	ret
krt4_ven_pravilno_loop:
	call lcd_off
	call load_tocke
	call krt4_ven_pravilno
	call delay_msx3
	jmp program
	ret
////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

load_tocke:
	mov r16, r12
	sbrc r16, 0
	clr r10	
	call deljenje_tock
	call ascii_converter
	ret
	deljenje_tock:
		clr tocke_to_ascii_desetice
		mov tocke_to_ascii_enice, r10
		ldi temp_reg, 10
	deljenje:
		sub tocke_to_ascii_enice, temp_reg
		brcs rezultat
		inc tocke_to_ascii_desetice
		jmp deljenje
	rezultat:
		add tocke_to_ascii_enice, temp_reg
		ret
	ascii_converter:
		ldi temp_reg, '0'
		add tocke_to_ascii_enice, temp_reg	
		add tocke_to_ascii_desetice, temp_reg
		ret

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// TUKAJ SO SLIKE KRTOV IN NJIHOVE FUNKCIJE ////////////////////////////////////////////////
lcd_off:
	ldi   R16, 0x01         ;zbrišemo LCD
    rcall komanda           ;pošlemo komando
    rcall delay_ms
	ret

loading_redy:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'g'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 't'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'r'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'd'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'y'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '.'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '.'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '.'
	RCALL podatki          
    RCALL delay_ms
	ret


loading_screen_1:
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'G'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'A'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'M'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'E'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '_'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'w'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'h'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'c'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'k'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'm'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'o'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'l'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '_'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	ret

cheater_screen:
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'c'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'c'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'o'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'u'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'n'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 't'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'b'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'n'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'n'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'd'
	RCALL podatki          
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 'r'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'm'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'o'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'v'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'b'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'n'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ':'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '9'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '.'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '9'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, '9'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b00100100
	RCALL podatki          
    RCALL delay_ms
	ret

x_screen:
	LDI   R16, 'P'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'o'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'p'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'l'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 's'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'w'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'h'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 't'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 't'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'h'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'y'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'w'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'a'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'n'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 't'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 't'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'o'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 's'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki
	RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki
	RCALL delay_ms
	ret

looser_screen:
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'Y'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'O'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'L'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'O'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'S'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'T'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'L'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'O'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'S'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'E'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'R'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki
	RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki
	RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki
	RCALL delay_ms
	ret

end_screen:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'G'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'A'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'M'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'E'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'E'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'N'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'D'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'E'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'D'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'y'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'o'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'u'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'r'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 's'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'c'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'o'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'r'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'e'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ':'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
screen:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret

krt1_ven:
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret

krt2_ven:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice
	RCALL podatki          
    RCALL delay_ms
	ret

krt3_ven:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, r9
	RCALL podatki          
    RCALL delay_ms
	mov   R16, r8 
	RCALL podatki          
    RCALL delay_ms
	ret

krt4_ven:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b11111100
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice
	RCALL podatki          
    RCALL delay_ms
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	krt1_ven_narobe:
	LDI   R16, 'X'
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret

krt2_ven_narobe:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'X'
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret

krt3_ven_narobe:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'X'
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret

krt4_ven_narobe:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'X'
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

krt1_ven_pravilno:
	LDI   R16, 0b1111_1111
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret

krt2_ven_pravilno:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b1111_1111
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret

krt3_ven_pravilno:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b1111_1111
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice
	RCALL podatki          
    RCALL delay_ms
	ret

krt4_ven_pravilno:
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 0b1111_1111
	RCALL podatki          
    RCALL delay_ms
	////////////////////////////////////
	LDI   R16, 0xC0         ;kursor naštimamo na drugo vrstico
    RCALL komanda
    RCALL delay_ms
	///////////////////////////////////
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'U'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, ' '
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_desetice
	RCALL podatki          
    RCALL delay_ms
	mov   R16, tocke_to_ascii_enice 
	RCALL podatki          
    RCALL delay_ms
	ret
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// FUNKCIJE PODATEK, INICIALIZACIJA IN KOMANDA /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
inicializacija:
	LDI   R16, 0x33         ;inicializiramo lcd za 4bitno pošiljanje podatkov
    RCALL komanda       ;pošljemo v komandni register
    RCALL delay_ms
    LDI   R16, 0x32         ;inicializiramo lcd za 4bitno pošiljanje podatkov
    RCALL komanda
    RCALL delay_ms
    LDI   R16, 0x28         ;povemo, da ima zaslon 2 liniji, 5x7 matrix
    RCALL komanda
    RCALL delay_ms
    LDI   R16, 0x0C         ;disp ON, cursor OFF
    RCALL komanda
    LDI   R16, 0x01         ;zbrišemo lcd
    RCALL komanda
    RCALL delay_ms
    LDI   R16, 0x06         ;premaknemo kursor desno
    RCALL komanda
    RET  

komanda:
	MOV   R27, R16
    ANDI  R27, 0xF0         ;zbrišemo spodnje 4 bite
    OUT   PORTD, R27        ;pošljemo zgornje 4bite zaslonu
    CBI   PORTB, 1          ;pin rs=0 za komando
    SBI   PORTB, 0          ;en = 1
    RCALL delay_short       ;podaljšamo pulz
    CBI   PORTB, 0          
    RCALL delay_us          ;delajamo
    ;----------------------------------------------------
    MOV   R27, R16
    SWAP  R27               ;zamenjamo zgornje 4 bite za spodnje
    ANDI  R27, 0xF0         ;ponovimo masko
    OUT   PORTD, R27        ;ponovno pošljemo 4 bitne podatke
    SBI   PORTB, 0          ;EN = 1
    RCALL delay_short       
    CBI   PORTB, 0          
    RCALL delay_us          
    RET

podatki:  
	cbi portb, 0            //isto kot komanda
    MOV   R27, R16
    ANDI  R27, 0xF0         
    OUT   PORTD, R27        
    SBI   PORTB, 1         
    SBI   PORTB, 0          
    RCALL delay_short      
    CBI   PORTB, 0          
    RCALL delay_us          
    ;----------------------------------------------------
    MOV   R27, R16
    SWAP  R27              
    ANDI  R27, 0xF0        
    OUT   PORTD, R27       
    SBI   PORTB, 0         
    RCALL delay_short       
    CBI   PORTB, 0          
    RCALL delay_us          
    RET
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////// DELAJI ///////////////////////////////////////////////////////////////////

delay_short:
      NOP
      NOP
      RET

delay_us:
      LDI   R17, 80
l3:   RCALL delay_short
      DEC   R17
      BRNE  l3
      RET

delay_ms:
      LDI   R28, 40
l4:   RCALL delay_us 
      DEC   R28
      BRNE  l4
      RET

delay_seconds:    
	cpi r25, 0
	breq delay_shortener
	dec r25
	mov r28, r2
l5: LDI   R29, 255     
l6: LDI   R18, 20     ;inner loop counter to give 0.25s delay
l7: sbic pinb, 2
	ldi  r24, 1
	sbic pinb, 2
	jmp gumb_pritisk_loop
	sbic pinb, 3
	ldi r24, 2
	sbic pinb, 3
	jmp gumb_pritisk_loop
	sbic pinb, 4
	ldi r24, 3
	sbic pinb, 4
	jmp   gumb_pritisk_loop
	sbic pinb, 5
	ldi r24, 4
	sbic pinb, 5
	jmp gumb_pritisk_loop
	DEC   R18   
    BRNE  l7          ;loop if not zero
    DEC   R29         ;decrement mid loop
    BRNE  l6          ;loop if not zero
    DEC   R28         ;decrement outer loop
    BRNE  l5          ;loop if not zero
    RET               ;return to calle

gumb_pritisk_loop:
	inc r20
	cpi r20, 3
	brsh anti_cheat
	call delay_ms
	call delay_ms
	call gumb_pritisk
	ret

anti_cheat:
	clr r20
	mov r16, r12
	cpi r16, 1
	breq gumb_pritisk_loop
	inc r12
	lsr r2
	lsr r2
	lsr r2
	lsr r2
	jmp gumb_pritisk_loop

delay_shortener:
	ldi r25, 20
	lsr r2
	ldi r21, 10
	mov r22, r2
	add r22, r21
	mov r2, r22
	jmp delay_seconds

delay_loading:
	LDI   R28, 255    ;outer loop counter 
la: LDI   R29, 255    ;mid loop counter
lb: LDI   R18, 160     ;inner loop counter to give 0.25s delay
lc: DEC   R18  
    BRNE  lc          ;loop if not zero
    DEC   R29         ;decrement mid loop
    BRNE  lb        ;loop if not zero
    DEC   R28         ;decrement outer loop
    BRNE  la        ;loop if not zero
    RET

delay_msx3:
	call delay_msx10
	call delay_msx10
	call delay_msx10
	ret

delay_msx10:
	call delay_msx6
	call delay_msx6
	call delay_msx6
	ret

delay_msx6:
	call delay_ms
	call delay_ms
	call delay_ms
	call delay_ms
	call delay_ms
	call delay_ms
	call delay_ms
	call delay_ms
	call delay_ms
	call delay_ms
	ret
