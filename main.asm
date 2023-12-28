.def tocke = r20
.def tocke_to_ascii_enice = r21
.def tocke_to_ascii_desetice = r22
.def pinb_stanje = r23
.def gumb_checker = r24
.def krt_number = r25
.def temp_reg = r26
.org 0x0034
setup:
	ldi r16, 0xff
	out ddrb, r16
	out ddrd, r16
	cbi portb, 0
	rcall inicializacija
	ldi zh, high(load * 2)
	ldi zl, low(load * 2)

	.org 0x0200
load:
	.db 2, 1, 4, 3, 1, 2, 3, 4, 3, 1, 2, 4, 2, 3, 1, 4, 4, 1, 2, 3, 2, 4, 3, 1, 1, 3, 4, 2, 2, 4, 1, 3, 3, 2, 1, 4, 1, 3, 2, 4, 4, 1, 3, 2, 3, 4, 1, 2, 1, 4, 3, 2, 2, 4, 1, 3, 1, 2, 4, 3, 4, 3, 1, 2, 1, 4, 3, 2, 4, 2, 3, 1, 4, 3, 1, 2, 1, 2, 3, 4, 4, 3, 1, 2, 3, 2, 1, 4, 4, 1, 2, 3, 2, 4, 1, 3, 3, 1, 4, 2, 1, 2, 3, 4, 4, 3, 1, 2, 3, 2, 1, 4, 4, 1, 2, 3, 2, 4, 1, 3, 3, 1, 4, 2
	jmp program

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////// GLAVNI PROGRAM //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

program:
	call you_lost_screen
	jmp loop
	jmp program

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////// TUKAJ SO FUNKCIJE ZA PRAVILNE PRITISKE GUMBOV ////////////////////////////////////////////

pritisk_gumba:
	in pinb_stanje, pinb
	ori pinb_stanje, 0b0011_1100
	lsr pinb_stanje
	lsr pinb_stanje
	cpi pinb_stanje, 0
	brne krt_to_checker
	ret
	krt_to_checker:
		cpi gumb_checker, 1
		brne ena_v_ena
		cpi gumb_checker, 2
		brne dva_v_tri
		cpi gumb_checker, 3
		brne tri_v_stiri
		cpi gumb_checker, 4
		brne stiri_v_osem
		jmp krt_to_checker
	checker_krt1:
		cp pinb_stanje, gumb_checker
		breq krt1_ven_pravilno_loopx
		jmp krt1_ven_narobe_loopx
	checker_krt2:
		cp pinb_stanje, gumb_checker
		breq krt2_ven_pravilno_loopx
		jmp krt2_ven_narobe_loopx
	checker_krt3:
		cp pinb_stanje, gumb_checker
		breq krt3_ven_pravilno_loopx
		jmp krt3_ven_narobe_loopx
	checker_krt4:
		cp pinb_stanje, gumb_checker
		breq krt4_ven_pravilno_loopx
		jmp krt4_ven_narobe_loopx
	ena_v_ena:
		ldi gumb_checker, 1
		jmp checker_krt1
	dva_v_tri:
		ldi gumb_checker, 2
		jmp checker_krt2
	tri_v_stiri:
		ldi gumb_checker, 4
		jmp checker_krt3
	stiri_v_osem:
		ldi gumb_checker, 8
		jmp checker_krt4
	tocke_plus:
		inc tocke
	tocke_minus:
		dec r20
		brcs you_lost_loop
		dec r20 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
krt1_ven_pravilno_loopx:
	call krt1_ven_pravilno_loopx 
	ret
krt2_ven_pravilno_loopx:
	call krt2_ven_pravilno_loopx 
	ret
krt3_ven_pravilno_loopx:
	call krt3_ven_pravilno_loopx 
	ret
krt4_ven_pravilno_loopx:
	call krt4_ven_pravilno_loopx 
	ret
krt2_ven_narobe_loopx:
	call krt2_ven_narobe_loop
	ret
krt1_ven_narobe_loopx:
	call krt1_ven_narobe_loop
	ret
krt3_ven_narobe_loopx:
	call krt3_ven_narobe_loop
	ret
krt4_ven_narobe_loopx:
	call krt4_ven_narobe_loop
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
you_lost_loop:
	jmp you_lost_screen
	call loop
	loop:
		rjmp loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_tocke:
	ldi r20, 46
	call deljenje_r20
	call ascii_converter
	ret
	deljenje_r20:
		mov tocke_to_ascii_enice, r20
		ldi temp_reg, 10
		rjmp deljenje
	deljenje:
		inc tocke_to_ascii_desetice
		sub tocke_to_ascii_enice, temp_reg
		brcs rezultat
		jmp deljenje
	rezultat:
		add tocke_to_ascii_enice, temp_reg
		dec tocke_to_ascii_desetice
		ret
	ascii_converter:
		ldi temp_reg, '0'
		add tocke_to_ascii_enice, temp_reg
		add tocke_to_ascii_desetice, temp_reg
		ret

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

read:
	jmp read_r19
	read_r19:
		lpm r19, z+
		cpi r19, 0
		brne pick_random_krt
		jmp set_z_reg
		ret
	set_z_reg:
		ldi zh, high(load * 2)
		ldi zl, low(load * 2)
		jmp read_r19
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
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// FUNKCIJE ZA PRIKLIC ZASLONOV /////////////////////////////////////////////////////////	

krt1_ven_loop:
	mov gumb_checker, r19
	jmp krt1_ven
	call delay_seconds
	call delay_seconds
	call delay_seconds
	clr gumb_checker
	ret
krt2_ven_loop:
	mov gumb_checker, r19
	jmp krt2_ven
	call delay_seconds
	call delay_seconds
	call delay_seconds
	clr gumb_checker
	ret
krt3_ven_loop:
	mov gumb_checker, r19
	jmp krt3_ven
	call delay_seconds
	call delay_seconds
	call delay_seconds
	clr gumb_checker
	ret
krt4_ven_loop:
	mov gumb_checker, r19
	jmp krt4_ven
	call delay_seconds
	call delay_seconds
	call delay_seconds
	clr gumb_checker
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
krt1_ven_pravilno_loop:
	call load_tocke
	jmp krt1_ven_pravilno
	call delay_seconds
	ret
krt2_ven_pravilno_loop:
	call load_tocke
	jmp krt2_ven_pravilno
	call delay_seconds
	ret
krt3_ven_pravilno_loop:
	call load_tocke
	jmp krt3_ven_pravilno
	call delay_seconds
	ret
krt4_ven_pravilno_loop:
	call load_tocke
	jmp krt4_ven_pravilno
	call delay_seconds
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
krt1_ven_narobe_loop:
	jmp krt1_ven_narobe
	call load_tocke
	ret
krt2_ven_narobe_loop:
	jmp krt2_ven_narobe
	call load_tocke
	ret
krt3_ven_narobe_loop:
	jmp krt3_ven_narobe
	call load_tocke
	ret
krt4_ven_narobe_loop:
	jmp krt4_ven_narobe
	call load_tocke
	ret

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// TUKAJ SO SLIKE KRTOV IN NJIHOVE FUNKCIJE ////////////////////////////////////////////////
lcd_off:
	ldi   R16, 0x01         ;zbrišemo LCD
    rcall komanda           ;pošlemo komando
    rcall delay_ms
	ret

you_lost_screen:
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
	ret

display1:
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
	LDI   R16, 'O'
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
	LDI   R16, 'O'
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
	LDI   R16, 'O'
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
	LDI   R16, 'O'
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// TUKAJ SO VSE SLIKE ZA PRAVILNE IN NAPA?NE PRITISKE GUMBOV //////////////////////////////////////////////////////
	krt1_ven_narobe:
	LDI   R16, 'X'
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

krt1_ven_pravilno:
	LDI   R16, 0b1111_1111
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
      LDI   R28, 90
l3:   RCALL delay_short
	  call pritisk_gumba
      DEC   R28
      BRNE  l3
      RET

delay_ms:
      LDI   R28, 40
l4:   RCALL delay_us
	  call pritisk_gumba
      DEC   R28
      BRNE  l4
      RET

delay_seconds:        ;nested loop subroutine (max delay 3.11s)
    LDI   R28, 255    ;outer loop counter 
l5: LDI   R29, 255    ;mid loop counter
l6: LDI   R18, 20     ;inner loop counter to give 0.25s delay
l7: DEC   R18 
	CALL pritisk_gumba        
    BRNE  l7          ;loop if not zero
    DEC   R29         ;decrement mid loop
    BRNE  l6          ;loop if not zero
    DEC   R28         ;decrement outer loop
    BRNE  l5          ;loop if not zero
    RET               ;return to calle