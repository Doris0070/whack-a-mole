.def tocke_to_ascii_enice = r21
.def tocke_to_ascii_desetice = r22
.def temp_reg = r26
.def gumb_checker = r23
.def random = r19
.def gumb_stanje = r24
.def sprememba_casa = r2
.def stevilo_krtov = r3
setup:
	ldi r16, 244
	mov r2, r16
	ldi r17, 10
	mov r3, r17
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
	cbi portb, 2
	cbi portb, 3
	cbi portb, 4
	cbi portb, 5

	.org 0x0050
load:
	.db 3,1,4,2,3,4,1,3,2,4,1,3,2,4,1,3,2,1,4,1,3,4,3,1,2,4,3,1,3,2,3,1,2,3,4,1,3,2,1,3,2,4,1,3,2,3,1,3,4,2,3,1,4,0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////// GLAVNI PROGRAM //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

program:
	call screen
	call delay_seconds
	call lcd_off
	call read
	call delay_seconds
	call lcd_off
	jmp program



read:
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

gumb_pritisk:
	mov gumb_checker, r19
	cp gumb_checker, gumb_stanje
	breq dodaj_tocke
	jmp krt_narobe
dodaj_tocke:
	inc r20
	jmp krt_pravilno
krt_pravilno:
	cpi gumb_stanje, 1
	breq krt1_ven_pravilno_loop
	cpi gumb_stanje, 2
	breq krt2_ven_pravilno_loop
	cpi gumb_stanje, 3
	breq krt3_ven_pravilno_loop
	cpi gumb_stanje, 4
	breq krt4_ven_pravilno_loop	
	ret
krt_narobe:
	cpi gumb_stanje, 1
	breq krt1_ven_narobe_loop
	cpi gumb_stanje, 2
	breq krt2_ven_narobe_loop
	cpi gumb_stanje, 3
	breq krt3_ven_pravilno_loop
	cpi gumb_stanje, 4
	breq krt4_ven_pravilno_loop	
	ret

end_screen_loop:
	call end_screen
	jmp end_screen_loop

krt1_ven_loop:
	call krt1_ven
	ret 
krt2_ven_loop:
	call krt2_ven
	ret
krt3_ven_loop:
	call krt3_ven
	ret
krt4_ven_loop:
	call krt4_ven
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
krt1_ven_pravilno_loop:
	call krt1_ven_pravilno
	call delay_seconds
	jmp program
	ret
krt2_ven_pravilno_loop:
	call krt2_ven_pravilno
	call delay_seconds
	jmp program
	ret
krt3_ven_pravilno_loop:
	call krt3_ven_pravilno
	call delay_seconds
	jmp program
	ret
krt4_ven_pravilno_loop:
	call krt4_ven_pravilno
	call delay_seconds
	jmp program
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
krt1_ven_narobe_loop:
	call krt1_ven_narobe
	call delay_seconds
	jmp program
	ret
krt2_ven_narobe_loop:
	call krt2_ven_narobe
	call delay_seconds
	jmp program
	ret
krt3_ven_narobe_loop:
	call krt3_ven_narobe
	call delay_seconds
	jmp program
	ret
krt4_ven_narobe_loop:
	call krt4_ven_narobe
	call delay_seconds
	jmp program
	ret

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// TUKAJ SO SLIKE KRTOV IN NJIHOVE FUNKCIJE ////////////////////////////////////////////////
lcd_off:
	ldi   R16, 0x01         ;zbrišemo LCD
    rcall komanda           ;pošlemo komando
    rcall delay_ms
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
	LDI   R16, 'x'
	RCALL podatki          
    RCALL delay_ms
	LDI   R16, 'x'
	RCALL podatki          
    RCALL delay_ms
	ret

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
	ret

krt1_ven:
	LDI   R16, '0'
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
	LDI   R16, '0'
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
	LDI   R16, '0'
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
	LDI   R16, '0'
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
	ret

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
	ret

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
	ret
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// FUNKCIJE PODATEK, INICIALIZACIJA IN KOMANDA /////////////////////////////////////////////////////////////
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

podatki:              //isto kot komanda
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
      LDI   R20, 90
l3:   RCALL delay_short
      DEC   R20
      BRNE  l3
      RET

delay_ms:
      LDI   R28, 40
l4:   RCALL delay_us 
      DEC   R28
      BRNE  l4
      RET

delay_seconds:    
	cpi r17, 0
	breq delay_shortener
	dec r3
	mov r28, r2
l5: LDI   R29, 255    ;mid loop counter
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
	call gumb_pritisk
	ret

delay_shortener:
	ldi r17, 10
	lsr r2
	jmp delay_seconds
