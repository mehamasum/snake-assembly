; ------GamePlay Procedures section ------
;Bonus 		- Generates Bonus Foods
;clear_screen-Clears Screen 
;dead_display-displays message of death
;draw_border1-Draws border for level 0
;draw_border2-Draws border for level 1
;draw_column -Draws a column
;draw_row	 -Draws a row ,Parameters - Character in row_attrib's  low byte, Color in row_attrib's High Byte,Co-ordinate in row_inp
;game_play 	- Main Game Loop
;Level_up_1	- Initializes everything for level up	
;move_head_1- Snake Movement for Level 0
;move_head_2- Snake Movement for Level 1
;move_snake - Shift the Snake array one position right
;print 		- p2_val- value to be converted,si- string to be used,p2_digit- number of digits to be printed
;print_count- prints the countdown for bonus
;Print_score- Prints the Score
;Rand		- Generates random co-ordinates without conflicting with existing structures-snakes,borders,foods
;set_dir 	- Sets Direction of snake according to input and used to ignore input if direction is reversed

bonus proc near
		pusher
		mov 	bonus_flag,1
		call 	rand
		mov 	dh,randy
		mov 	dl,randx
		mov 	bonus_yx,dx
		putchar dx,bonus_char,12;0eh	
		printf 4,0102h,bonus_msg		
		popper
	ret
bonus endp

clear_screen proc near	
	pusher
	;Initializing cursor to 0
	mov     dx, 0000h
	mov 	ch, 0
	mov 	cl, 0

	clear_scrn:			;Clear the Screen Row by Row	 
		mov 	row_inp,dx
		mov 	ah,0
		mov     al,' ' 
		push 	cx
		mov 	row_attrib,ax
		call 	draw_row
		pop 	cx
		
		inc 	ch
		cmp 	ch, 25
		je 		scrn_clr_done
		inc 	dh
		mov 	dl, 0
	jmp 	clear_scrn

	scrn_clr_done:

		popper
		ret
clear_screen endp


dead_display proc near  
	pusher
	putchar snake[0],178,10;0fh
	putchar snake[2],176,10	
	
	mov 	al,1
	mov 	bh,0 
	mov 	bl,10 ;0eh
	mov 	cx,22
	mov     dx, 0B1Ch
	lea 	bp,dead_msg
	mov 	ah,13h
	int 	10h
	mov 	ah,1
	int 	21h
	
	call clear_screen
	call high_score
	call leaderboard
	
	popper
	jmp new
	ret
	
dead_display endp

;Draw border on line 2
draw_border1 proc near
	pusher
	;Initializing cursor to 0
	mov     ah, 10;0eh
	mov     al, 95 ;95, 250, 240, 254
	mov	row_attrib,ax
	mov 	row_inp,0200h
	call 	draw_row
	popper
	ret
draw_border1 endp

;Draw border on line 2 and line 24
draw_border2 proc near
	pusher
	mov     ah,0eh
	mov     al,220
	mov	row_attrib,ax
	mov 	row_inp,0200h
	call 	draw_row

		
	mov 	dh,24
	mov 	dl,0
	mov 	row_inp,dx
	mov 	ah,0eh
	mov     al,223
	mov 	row_attrib,ax 
	call 	draw_row

;Draw column at column 0 and 4Fh	
	mov     column_inp,0300h
	mov     ah,0eh
	mov     al,219  
	mov     column_attrib,ax
	call    draw_column 

	mov     column_inp,034Fh
	mov     ah,0eh
	mov     al,219
	mov     column_attrib,ax
	call    draw_column 
	
	popper
	ret
draw_border2 endp  

draw_column proc near
	pusher
    mov dx,column_inp
    
    column_start:
    ; set cursor at (dh,dl)
	mov     ah, 02h
	int     10h
    
    mov     ax,column_attrib
    mov     bl,ah
	mov     ah, 09h
	mov     cx, 1   	; single char.
	int     10h 
	inc		dh

	cmp 	dh, 24
	je 		end_column
	jmp 	column_start    
	
    end_column:
	popper
    ret
			
draw_column endp 

;Draw_row parameters- Character in row_attrib's  low byte, Color in row_attrib's High Byte,Co-ordinate in row_inp
draw_row proc near
	pusher
    mov ch,0
    mov cl,0
    
	mov dx,row_inp
    row_start:
    ; set cursor at (dh,dl)
	mov     ah, 02h
	int     10h

	; print '' at the location:
    mov 	ax,row_attrib
	mov     bl, ah		; color of the border
	mov     ah, 09h
	mov     cx, 1   	; single char.
	int     10h 
	inc		dl
	
	cmp 	dl, 80
	je 		end_row
	jmp 	row_start    
	
    end_row:
	popper
    ret
          
draw_row endp

game_play proc near
	pusher
	game_loop:
		inc time
		
		; === select first video page
		mov     al, 0  ; page number.
		mov     ah, 05h
		int     10h


		;--------------------------PRINT HEAD----------------------------
		putchar snake[0],178,10;0fh
		putchar snake[2],176,10		

		;---------------------------REMOVE TAIL------------------------------
		; === get old tail: 2*s_size-2
		mov 	di,s_size
		add 	di,di
		sub 	di,2
		
		putchar snake[di],' ',0

		
		bonus_check:
		cmp time,bonus_interval		; tim=bonus_interval, set time=0 and create bonus
		jne	bonus_remover
		mov time,0
		call bonus

		bonus_remover:				
		cmp bonus_flag,1	
		jne food_checker	;if no bonus , don't check
		
		mov counter,bonus_time
		mov ax,time
		sub counter,al
		call print_count		;if bonus is displayed, print the remaining time
		
		cmp time,bonus_time		; if bonus has matched its time limit, delete it
		jne food_checker
		
		printf 24,0102h,bonus_rmv	;removes bonus
		putchar bonus_yx,' ',0
		mov bonus_flag,0
		
		food_checker:
		cmp		food_chk,1
		je		movement_chk
		
		foody:
			call rand
			mov dh,randy
			mov dl,randx
			putchar dx,15,10;0eh
			mov	food_chk,1
			call print_score
		
		movement_chk:
		;----------------------CALC THE NEW COORDINATES---------------------
		call    move_snake
		
		cmp level,0
		jne level1_move
		call	move_head_1 ; --------BORDER CHECK
		jmp check_for_key
		
		level1_move:
		call	move_head_2 ; 
		
		check_for_key:

			; check for key
			mov     ah, 01h
			int     16h
			jz      no_key

			mov     ah, 00h
			int     16h

			cmp     al, pauser    ; esc 
			je      pause_game ;
			
			cmp 	ah,53h
			je 		stop_game
			
			cmp 	ah,rev_cur_dir
			je  	check_for_key
			
			call set_dir
			

		no_key:

			; wait
			; get number of clock ticks since midnight into cx:dx
			mov     ah, 00h
			int     1ah
			
			cmp     dx, wait_time
			jb      check_for_key
			add     dx, 2
			mov     wait_time, dx

		; game loop:
		jmp     game_loop

	pause_game:
	printf 	11,0124h,pause_msg
	mov     ah, 00h
	int     16h
	cmp     al, 1bh    ; esc 
	printf 	11,0124h,pause_rmv
	je      check_for_key  ;
	jmp 	pause_game
		
	stop_game:
		popper
		ret
game_play endp
	
level_up1 proc near
	pusher
	putchar snake[0],178,10;0fh
	putchar snake[2],176,10
	
	call sleep
	call level_animation
	
	mov food_chk,0
	mov level,1
	mov s_size, 4
	call clear_screen
	call draw_border2
	
	; hide text cursor: Function 2 prints the cursor from row ch to row cl. as ch<cl, no cursor is printed
	mov     ah, 1
	mov     ch, 20h
	int     10h 
	
	printf 8,0140h,scorer
	call print_score
		
	mov counter,0 
	mov bonus_flag,0
	
	mov ah,0ch
	mov al,0
	int 21h
	
	mov cur_dir,right
	mov rev_cur_dir, left
	
	mov snake[0], l2_pos1		;Snake starts at row 11, column 0
	mov snake[2], l2_pos2
	mov bx,4
	memset:
	mov snake[bx],0
	add bx,2
	cmp bx,90
	jbe memset
	popper
	ret
level_up1 endp
	
move_head_1 proc near
	pusher
	cmp     cur_dir, left
	  je    move_left1
	cmp     cur_dir, right
	  je    move_right1
	cmp     cur_dir, up
	  je    move_up1
	cmp     cur_dir, down
	  je    move_down1
	jmp     stop_move1     ; no direction.


	move_left1:
	  mov   al, byte ptr snake[0]
	  dec   al
	  mov   byte ptr snake[0], al
	  cmp   al, l_border
	  jne   stop_move1       

	  mov   al,r_border                ;  max window X
	  dec   al
	  mov   byte ptr snake[0], al 
	  jmp   stop_move1

	move_right1:
	  mov   al, byte ptr snake[0]
	  inc   al
	  mov   byte ptr snake[0], al
	  cmp   al, r_border                ; max window X   
	  jb    stop_move1
	  
	  mov   byte ptr snake[0], l_border
	  inc 	byte ptr snake[0]
	  jmp   stop_move1

	move_up1:
	  mov   al, byte ptr snake[1]
	  dec   al
	  mov   byte ptr snake[1], al
	  cmp   al, u_border
	  jne   stop_move1
	  
	  mov   al, d_border               ; max window Y
	  mov   byte ptr snake[1], al
	  jmp   stop_move1

	move_down1:
	  mov   al, byte ptr snake[1]
	  inc   al
	  mov   byte ptr snake[1], al
	  cmp   al, d_border                ; max window Y
	  jbe   stop_move1
	  
	  mov   byte ptr snake[1], u_border 
	  inc  	byte ptr snake[1]
	  jmp   stop_move1

	stop_move1:
	
	mov dh,byte ptr snake[1]
	mov dl,byte ptr snake[0]
	mov bh,0
	mov ah,2
	int 10h
	
	mov ah,8
	int 10h
	
	cmp al,176
	je 	dead1
	
	cmp al,food_char
	jne bonus_check1
	mov food_chk,0
	inc score
	inc s_size
	
	bonus_check1:
	cmp al,bonus_char
	jne bonus_level_up1
	mov bonus_flag,0	
	printf 24,0102h,bonus_rmv	;removes bonus countdown message
	add score,10
	call print_score
	
	bonus_level_up1:
	cmp score,level_up_bound
	jb end_mov1
	call level_up1
	
	end_mov1:
	popper
	ret
	
	dead1:
	popper
	call dead_display
move_head_1 endp

move_head_2 proc near
	pusher
	cmp     cur_dir, left
	  je    move_left2
	cmp     cur_dir, right
	  je    move_right2
	cmp     cur_dir, up
	  je    move_up2
	cmp     cur_dir, down
	  je    move_down2

	jmp     stop_move2       ; no direction.


	move_left2:
	  mov   al, byte ptr snake[0]
	  dec   al
	  mov   byte ptr snake[0], al
	  cmp   al, l_border2
	  jne  	stop_move2       
	  jmp 	dead2
	  
	move_right2:
	  mov   al, byte ptr snake[0]
	  inc   al
	  mov   byte ptr snake[0], al
	  cmp   al, r_border2               ; max window X   
	  jne    stop_move2
	  jmp 	dead2
	  
	move_up2:
	  mov   al, byte ptr snake[1]
	  dec   al
	  mov   byte ptr snake[1], al
	  cmp   al, u_border2
	  jne   stop_move2
	  jmp 	dead2
	  
	move_down2:
	  mov   al, byte ptr snake[1]
	  inc   al
	  mov   byte ptr snake[1], al
	  cmp   al, d_border2               ; max window Y
	  jne   stop_move2
	  jmp 	dead2
	  
	  
	stop_move2:
	mov dh,byte ptr snake[1]
	mov dl,byte ptr snake[0]
	mov bh,0
	mov ah,2
	int 10h
	
	mov ah,8
	int 10h
	
	cmp al,176
	je 	dead2
	
	cmp al,food_char
	jne	bonus_check2
	mov food_chk,0
	inc score
	inc s_size
	
	bonus_check2:
	cmp al,bonus_char
	jne end_mov2
	mov bonus_flag,0	
	printf 24,0102h,bonus_rmv	;removes bonus countdown message
	add score,10
	call print_score
	
	end_mov2:
	popper
	ret
	
	dead2:
	popper
	call dead_display
move_head_2 endp
  
move_snake proc near
	pusher
  ; point di to tail
	mov 	di,s_size
	add 	di,di
	sub 	di,2
	mov     dx,snake[di]
	  
	; move all body parts
	mov   	cx, s_size
	dec 	cx
	
	;---Label for Loop
	move_array:
		mov   ax,snake[di-2]
		mov   snake[di], ax
		sub   di, 2
		loop  move_array
	  
	popper
	ret
move_snake endp	
	
	
print proc near
	pusher
	mov bl,10
    mov al,p2_val
    mov bh,al
    mov cx,0
    mov ah,0

	printer:
    mov al,bh ;al gets changed after every print
    div bl    ;ax divided by 10
        
    mov bh,al
    mov dl,ah       
    add dl,30h
    mov dh,0
    inc cx
    push dx 
    
    mov ah,0 
    
    cmp cl,p2_digit 
    je stringer
    jmp printer
    
    stringer: 
    pop dx
    mov byte ptr [si],dl
    inc si
    loop stringer

	popper
	ret
print endp

print_count proc near 
	pusher
    mov al,counter
    mov p2_val,al
	mov p2_digit,2
	lea si, counter_str
	call print
	printf 2,0106h,counter_str
	popper
    ret
print_count endp

print_score proc near
	pusher
	lea si,scoreval
	mov bx,10
    mov ax,score
    mov temp,ax
	mov dx,0
    mov cx,0

	sprinter:
    mov ax,temp ;ax gets changed after every print
    div bx    
        
    mov temp,ax       
    add dx,30h
    inc cx
    push dx 
    
    mov dx,0 
    
    cmp cx,4  
    je sstringer
    jmp sprinter
    
    sstringer: 
    pop dx
    mov byte ptr [si],dl
    inc si
    loop sstringer

	printf 4,0148h,scoreval
	
	popper
    ret
print_score endp


rand proc near  
	
	pusher
	start_rand:
	
	mov dx,17
	mov ax,seed
	mul dx  
	
	mov bx,21
	div bx
	
	add dx,3
	
	mov randy,dl
	mov byte ptr seed[1], dl
	
	mov dx,17
	mov ax,seed
	mul dx  
	
	mov bx,78
	div bx
	
	inc dx
	
	mov randx,dl
	
	mov byte ptr seed[0],dl
	
	;check if food is on snake
	mov dh,randy
	mov dl,randx
	mov bh,0
	mov ah,2
	int 10h
	
	mov ah,8
	int 10h
	
	cmp ah,10	; color green
	je start_rand
    	
	;cmp ah,12
	;je start_rand
	
	popper
	ret
rand endp  

set_dir proc near

	cmp ah,left
	je lefter
	
	cmp ah,right
	je righter
	
	cmp ah,up
	je upper
	
	cmp ah,down
	je downer
	
	jmp end_set
	
	lefter:
		mov cur_dir,left
		mov rev_cur_dir,right
		jmp end_set
		
	righter:
		mov cur_dir,right
		mov rev_cur_dir,left
		jmp end_set
		
	upper:
		mov cur_dir,up
		mov rev_cur_dir,down
		jmp end_set
		
	downer:
		mov cur_dir,down
		mov rev_cur_dir,up
		
	end_set:
	ret
set_dir endp