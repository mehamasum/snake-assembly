;-------------------------------Macro List --------------------------
;ascii1 	- Displays ASCII Graphics 1
;init		- Initializes all variables for restarting game properly
;popper		- Pops all the flags 
;printf		- Parameters : a-number of chars, b=co-ordinate,c=string	
;prints		- Prints String passed as parameter, example : Prints msg
;pusher		- Pushes all the registers and flags into stacks
;putchar	- Prints Character , Parameters: a=co-ordinate,b=character,c=color



;---------------------Procedure List-----------------------------
;--Main

;mild_sleep			- A sleep function for creating a short pause
;level_animation	- Level up animation
;sleep				- A sleep function for creating a modarate pause
;snake_animation	- Welcome screen animation

.model small
.stack 200

.data 
	seed 		dw  0
	pause_msg 	db 	'Game Paused'
	pause_rmv	db 	'           ' ;size 11
	print_inp	db	0
	time 		dw	0	
	s_size  	dw 	  4	; number of characters in the snake is 1 less than this size
	scorer      db 	'Score : '
	; [y, x]
	snake 		dw 	  90 dup(0)
	
	p2_val db 0		;used as parameter to print_2
	p2_digit db 0	;used as parameter to print_2
	level db 0
	
	counter db 0
	counter_str db '00'
	bonus_msg db '$ : '     ;size 4
	bonus_rmv db '                         ' ;size 24     
	bonus_interval equ	150	; After this time ,a bonus is created
	bonus_time	equ 50		; Duration of bonus
	bonus_flag	db 0
	bonus_yx	dw 0
	bonus_char	equ 36
	level_up_bound equ 20
	
	l1_pos1 equ 0B01h
	l1_pos2 equ 0B00h
	
	l2_pos1 equ 0B02h
	l2_pos2 equ 0B01h
	
	stack_init dw 0
	left    	equ   4bh
	right   	equ   4dh
	up      	equ   48h
	down    	equ   50h	
	pauser		equ   1bh	;esc
	
	l_border2	equ 0
	r_border2 equ 4fh
	u_border2 equ 2
	d_border2 equ 24
	
	l_border	equ -1
	r_border equ 80
	u_border equ 2
	d_border equ 24
	
	row_inp 	dw 	0
	row_attrib  dw  0
	column_inp 	dw 	0	
	column_attrib dw 0
	
	score dw 0
	scoreval db 5 dup('0')

	cur_dir 	db    right
	rev_cur_dir db 		left
	wait_time 	dw    0

	dead_msg 	db    'you are dead jon snow.'

	food_chk	db 0
	food_char 	equ 15
	
	randx	db 16
	randy   db 20 
	
	blank_line db 0dh,0ah,'$'
	space db 20h,'$'
    prompt db 'Name : $' 
    filename db 'score',0
    handle dw ?     
    buffer db 2560 dup(0)
	player db 20 dup(0)
    openerr db 0ah,0dh,'Open Error - Code : $'
	
	compare_result db 0 ; Stores result of two string comparison,0- Source loses, 1 - source greater or equal
	
	name_addr dw 6 dup(0)
	score_addr dw 6 dup(0)
	
	name1 db 30 dup(?)
	score1 db 5 dup(?)
	
	name2 db 30 dup(?)
	score2 db 5 dup(?)

	name3 db 30 dup(?)
	score3 db 5 dup(?)
	
	name4 db 30 dup(?)
	score4 db 5 dup(?)
	
	name5 db 30 dup(?)
	score5 db 5 dup(?)
	
	name6 db 30 dup(?)
	score6 db 5 dup(?)
	
	open_mode db 0
    errcode db 30h
	tempname db 30 dup(?)
    tempnum db 30 dup(?)
    numBytes dw 0     ;Stores number of Bytes in the file
	
	MenuPos db 1
	temp dw 0

	StartMenu db            "     Start      "
	StartMenuSelected db    "    >Start<     "
	StartMenuCor dw ?

	ScoreMenu db            "  Leaderboard    "
	ScoreMenuSelected db    " >Leaderboard<   " 
	ScoreMenuCor dw ?

	ExitMenu db             "     Exit       "
	ExitMenuSelected db     "    >Exit<      "
	ExitMenuCor dw ?
	
	msg1 db "              _______ _             _____             _         ", 0dh,0ah
		db  "             |__   __| |           / ____|           | |        ", 0dh,0ah
		db  "                | |  | |__   ___  | (___  _ __   __ _| | _____  ", 0dh,0ah
		db  "                | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ ", 0dh,0ah
		db  "                | |  | | | |  __/  ____) | | | | (_| |   <  __/ ", 0dh,0ah
		db  "               _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| ", 0dh,0ah
		db  "              / ____|                    | |                    ", 0dh,0ah
		db  "             | |  __  __ _ _ __ ___   ___| |                    ", 0dh,0ah
		db  "             | | |_ |/ _` | '_ ` _ \ / _ \ |                    ", 0dh,0ah
		db  "             | |__| | (_| | | | | | |  __/_|                    ", 0dh,0ah
		db  "              \_____|\__,_|_| |_| |_|\___(_)                    ", 0dh,0ah
		db  "                                                                ", 0dh,0ah
		db  "                            /^\/^\                                            ", 0dh,0ah
		db  "                          _|__|  O|                                           ", 0dh,0ah
		db  "                 \/     /~     \_/ \                                          ", 0dh,0ah
		db  "                  \____|__________/  \                                        ", 0dh,0ah
		db  "                         \_______      \                                      ", 0dh,0ah
		db  "                                 `\     \                    \                ", 0dh,0ah
		db  "                                  /     /                     \               ", 0dh,0ah
		db  "                                 /     /                       \\             ", 0dh,0ah
		db  "                               /      /                         \ \           ", 0dh,0ah
		db  "                              /     /                            \  \         ", 0dh,0ah
		db  "                            /     /             _----_            \   \       ", 0dh,0ah
		db  "                           /     /           _-~      ~-_         |    |       ", 0dh,0ah
		db  "                          (      (        _-~    _--_    ~-_     _/    |       "
	
    msg2 db  "              _______ _             _____             _         ", 0dh,0ah
		db  "             |__   __| |           / ____|           | |        ", 0dh,0ah
		db  "                | |  | |__   ___  | (___  _ __   __ _| | _____  ", 0dh,0ah
		db  "                | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ ", 0dh,0ah
		db  "                | |  | | | |  __/  ____) | | | | (_| |   <  __/ ", 0dh,0ah
		db  "               _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| ", 0dh,0ah
		db  "              / ____|                    | |                    ", 0dh,0ah
		db  "             | |  __  __ _ _ __ ___   ___| |                    ", 0dh,0ah
		db  "             | | |_ |/ _` | '_ ` _ \ / _ \ |                    ", 0dh,0ah
		db  "             | |__| | (_| | | | | | |  __/_|                    ", 0dh,0ah
		db  "              \_____|\__,_|_| |_| |_|\___(_)                    ", 0dh,0ah
		db  "                                                                ", 0dh,0ah
		db  "                            /^\/^\                                            ", 0dh,0ah
		db  "                          _|__|  O|                                           ", 0dh,0ah
		db  "                        /~     \_/ \                                          ", 0dh,0ah
		db  "                   ____|__________/  \                                        ", 0dh,0ah
		db  "                  /      \_______      \                                      ", 0dh,0ah
		db  "                 /\              `\     \                    \                ", 0dh,0ah
		db  "                                  /     /                     \               ", 0dh,0ah
		db  "                                 /     /                       \\             ", 0dh,0ah
		db  "                               /      /                         \ \           ", 0dh,0ah
		db  "                              /     /                            \  \         ", 0dh,0ah
		db  "                            /     /             _----_            \   \       ", 0dh,0ah
		db  "                           /     /           _-~      ~-_         |    |       ", 0dh,0ah
		db  "                          (      (        _-~    _--_    ~-_     _/    |       "	
		
	
	instruc	db  "[Use ARROW KEYS for movement and ESC to pause/resume]", 0dh,0ah
	
	credit	db  "The Snake Game 2.2 Beta  ", 0dh,0ah	
			db  "                           (c) Fahim and Meha, 2015  ", 0dh,0ah
	
	l_up1	db "                     _    __ _    __ ___ _      _   _ ___   ", 0dh,0ah
			db "                    | |  | __\ \ / /| __| |    | | | | _ \  ", 0dh,0ah
			db "                    | |__| _| \ V / | _|| |__  | |_| |  _/  ", 0dh,0ah
			db "                    |____|___| \_/  |___|____|  \___/|_|    ", 0dh,0ah

	l_up2	db "                      (                   (            (    ", 0dh,0ah
			db "                     )\ )                )\ )         )\ )  ", 0dh,0ah
			db "                    (()/( (   (   (  (  (()/(      ( (()/(  ", 0dh,0ah
			db "                     /(_)))\  )\  )\ )\  /(_))     )\ /(_)) ", 0dh,0ah
			db "                    (_)) ((_)((_)((_|(_)(_))    _ ((_|_))   ", 0dh,0ah

	top_msg db "                 ___ ___ ___ _____   ___  ___ ___  ___ ___ ___ ", 0dh,0ah
			db "                | _ ) __/ __|_   _| / __|/ __/ _ \| _ \ __/ __|", 0dh,0ah
			db "                | _ \ _|\__ \ | |   \__ \ (_| (_) |   / _|\__ \", 0dh,0ah
			db "                |___/___|___/ |_|   |___/\___\___/|_|_\___|___/", 0dh,0ah

.code
org 100h


;---------------------Macro List--------------------------
; the_msg=string, xxxx=x cor, yyyy=y cor, cxcx=no of char
ascii macro the_msg, xxxx, yyyy, cxcx
; ascii graphics2
	mov bh,0
    mov ah,13h
    mov al,0
    mov dh,yyyy
    mov dl,xxxx 
    mov bl,10
    mov cx,cxcx
    mov bp,offset the_msg
    int 10h 
    inc dh
endm

init macro

	mov time,0
	mov s_size,4	; number of characters in the snake is 1 less than this size
	mov level,0
	mov score,0
	mov scoreval[0],'0'
	mov scoreval[1],'0'
	mov scoreval[2],'0'
	mov scoreval[3],'0'
	mov scoreval[4],'$'
	
	mov counter_str[0],'0'
	mov counter_str[1],'0'
	
	mov p2_val,0		;used as parameter to print_2
	mov p2_digit,0	;used as parameter to print_2
	mov level,0
	
	mov counter,0 
	mov bonus_flag,0
	mov bonus_yx,0301h
	mov counter,0
	mov cur_dir,right
	mov rev_cur_dir, left

	mov wait_time,0

	mov food_chk,0
	
	mov compare_result,0 ; Stores result of two string comparison,0- Source loses, 1 - source greater or equal
	mov open_mode,0
    mov errcode,30h
    mov numBytes,0     ;Stores number of Bytes in the file
	
	mov MenuPos,1
	mov temp,0
	clear_stack:
	pop ax
	mov bp,sp
	cmp bp,stack_init
	je end_stack
	jmp clear_stack
	
	end_stack:
endm

popper macro
	popf
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
endm

;a-number of chars, b=co-ordinate,c=string	
printf macro a,b,c
	pusher	
	mov 	al,1
	mov 	bh,0 
	mov 	bl,0eh
	mov 	cx,a
	mov     dx,b 
	lea 	bp,c
	mov 	ah,13h
	int 	10h
	popper
endm
	
prints macro msg
	lea dx,msg
	mov ah,9
	int 21h
endm	
	
; a=co-ordinate,b=character,c=color
putchar macro a,b,c
	
	mov 	dx,a
	mov		al,b
	mov		bl,c
	
	mov     ah, 02h
	int     10h

	mov     ah, 09h
	mov     cx, 1   	; single char.
	int     10h 
endm
	

pusher macro
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	pushf
endm
	
;---------------------------Procedures------------------	

level_animation proc near
	call clear_screen	
	ascii l_up1, 0, 10, 250
	call mild_sleep
	ascii l_up2, 0, 6, 310
	call sleep
	call sleep
	ret
level_animation endp

mild_sleep proc
	push cx	
	mov cx, 500
	in_sleep1:
	push cx
	mov cx, 1000
	out_sleep_loop1:
	loop out_sleep_loop1
	pop cx
	loop in_sleep1
	pop cx
	ret
mild_sleep endp

rand_init proc
	pusher
	mov ah,2ch
    int 21h 
    mov seed,dx
	popper
rand_init endp

sleep proc
	push cx
	mov cx, 1000
	in_sleep:
	push cx	
	mov cx, 1000
	out_sleep_loop:
	loop out_sleep_loop
	pop cx	
	loop in_sleep	
	pop cx
	ret
sleep endp

snake_animation proc near
	call clear_screen
	ascii msg1, 0, 0, 1830
	call sleep
	ascii msg2, 0, 0, 1830
	call sleep
	ascii msg1, 0, 0, 1830
	call sleep
	ascii msg2, 0, 0, 1830
	call sleep
	ascii msg1, 0, 0, 1830
	call sleep
	ascii msg2, 0, 0, 1830
	call sleep
	ascii msg1, 0, 0, 1830
		
	;wait for any key:
	mov ah, 00h
	int 16h
	ret
snake_animation endp



;-----------------------------MAIN--------------------------------
main proc
	pusher
	mov     ax,@data
	mov     ds,ax
	mov 	es,ax
	
	mov bp,sp
	mov stack_init,bp
	call rand_init

	; hide text cursor: 
	mov     ah, 1
	mov     ch, 20h
	int     10h           

	mov     al, 0  		; Load Page 0
	mov     ah, 05h
	int     10h
	
	call snake_animation
	
new:
	init
	
	
	; hide text cursor:
	mov     ah, 1
	mov     ch, 20h
	int     10h           

	mov     al, 0  		; Load Page 0
	mov     ah, 05h
	int     10h

	call score_read


MAIN_MENU_VIEW:	
	call clear_screen
	
	; main menu
	call ShowMainMenu
	call MainMenuListener ; pushes pressed key to stack
	pop ax
	cmp ax,1
	je game_screen
	cmp ax,2
	je show_lead
	cmp ax,3
	je EXIT 
	
	show_lead:
	call clear_screen	
	call leaderboard

	mov MenuPos,1
	jmp MAIN_MENU_VIEW
	
game_screen:

    call clear_screen
	call draw_border1

	; hide text cursor:
	mov     ah, 1
	mov     ch, 20h
	int     10h 
	
	printf 8,0140h,scorer
	
	call print_score;
	
	;-------------GAME STARTS-------------------
	mov snake[0], l1_pos1		;Snake starts at row 11, column 0
	mov snake[2], l1_pos2
	call game_play

	DOS_EXIT:	
	call clear_screen
	
EXIT:
	popper
	mov     ah,4ch
	int     21h
main    endp


include board.asm
include gameplay.asm
include menu.asm
end main