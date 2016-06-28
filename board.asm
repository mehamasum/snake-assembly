; ------Board Procedures section ------
;close		-Closes File
;compare	- Compares and re-orders records
;getname	-Gets Username
;high_score	-Checks and updates leaderboard
;leaderboard-Displays Leaderboard
;open		-Opens an existing file, parameter from open_mode
;print_file	-Print Updated Leaderboard to file	
;read		-Reads from file to buffer
;recorder	-Reads names and scores from buffer to 2 Arrays
;rewriter	-Opens existing file in rewrite mode
;score_read	-Reads Initial Leaderboard from file
;strcmp		-Compares Two Strings,Returns 0 if source<dest,else 1
;strcpy	 	-Used to copy Strings after read into buffer,uses numBytes to determine end point
;strcpy1 	-Copies String at si to String at di
;write		-Writes to File

close proc near  
    mov ah,3eh
    int 21h
    ret
close endp
	
;Prints Records One by One
compare proc near  
    
    mov bx,8 
    
    checker: 
   
	lea si,scoreval
	mov di,score_addr[bx]
	call strcmp
	
	cmp compare_result,0
	je end_compare
	
	;move current name and score to temp
	mov si, score_addr[bx]
	lea di,tempnum
	call strcpy1
	
	mov si,name_addr[bx]
	lea di,tempname
	call strcpy1
		
	
	;insert current player
	lea si, scoreval
	mov di, score_addr[bx]
	call strcpy1	    
	
	lea si,player
	mov di,name_addr[bx]
	call strcpy1        
	
	
	;move previous record
	lea si,tempnum
	mov di, score_addr[bx+2]
	call strcpy1
	
	lea si,tempname
	mov di,name_addr[bx+2] 
	call strcpy1
    
    sub bx,2
	cmp bx,0
	jae checker
	
	end_compare:
	ret
compare endp
	
get_name proc near
    push ax
    push dx
    push di
	
	mov     al, 0  ; page number.			
	mov     ah, 05h			
	int     10h			
				
	;show cursor back			
	mov     ah, 1			
	mov     ch, 0bh			
	mov     cl, 0bh			
	int     10h			
		
	; set cursor at dl,dh			
	mov 	dx, 0000			
	mov     ah, 02h			
	int     10h			
	        			
	mov 	ah,9			
	mov     bl, 0eh ; attribute			
	int 	10h			
	        			
	prints prompt

    cld
    lea di,player
    mov ah,1
    jmp read_name
		
	backer:
	dec di
	mov ah,3
	mov bh,0
	int 10h
	;dec dl
	mov ah,2
	int 10h
	
	mov dl,' '
	mov ah, 02h
	int 21h

	mov ah,3
	mov bh,0
	int 10h
	dec dl
	mov ah,2
	int 10h
	
	mov ah,1
	
    read_name:
    int 21h
	cmp al,8
	je backer
    cmp al,0dh
    je done
    stosb
    jmp read_name
    
    done:
    mov al,'$'
    stosb
    pop di
    pop dx
    pop ax
    ret
get_name endp

high_score proc near
	
	mov scoreval[4],'$'

	lea si,scoreval
	mov di,score_addr[8]
	call strcmp
	
	cmp compare_result,0
	je continu
	
	call get_name
	
	
	call rewriter
	
	call compare
	
	call print_file
		
	mov bx,handle
    call close        ;close file 	
	
	continu:
	ret
high_score endp

leaderboard proc near
	mov     al, 0  ; page number.			
	mov     ah, 05h			
	int     10h			
				
	;show cursor back			
	mov     ah, 1			
	mov     ch, 0bh			
	mov     cl, 0bh			
	int     10h			
		
	; set cursor at dl,dh			
	mov dh, 12 ;row
	mov ch, 12   ;safety
	mov dl, 33
	mov     ah, 02h			
	int     10h			
						
	mov ah,9			
	mov     bl, 0eh ; attribute			
	int 10h			
	
	mov bx,0
    
	leader:
	inc ch
	mov dh, ch
	mov dl, 33
	mov     ah, 02h			
	int     10h	
    cmp bx,8
    jg end_leader
	
	mov dx,name_addr[bx]
	mov ah,9
	int 21h
    
	mov dl,' '
	mov ah,2
	int 21h
	
    mov dx,score_addr[bx]
    mov ah,9
	int 21h
	
	prints blank_line
	
	add bx,2
    jmp leader
	
	end_leader:
	ascii top_msg, 0, 5, 260
	; hide text cursor: Function 2 prints the cursor from row ch to row cl. as ch<cl, no cursor is printed
	mov     ah, 1
	mov     ch, 20h
	int     10h           

	;wait for any key:
	mov ah, 00h
	int 16h
	ret
leaderboard endp

 ;open an existing file in the mode specified by open_mode	 
open proc near 
	mov al,open_mode
    mov ah,3dh
    int 21h
    ret 
open endp

print_file proc near

	mov bx,0
	
	store:
    cmp bx,8
	ja end_print
	mov dx,name_addr[bx]
	call write
	lea dx,blank_line
	call write
    mov dx,score_addr[bx]  
	call write
	lea dx,blank_line
	call write
	add bx,2
	jmp store

	end_print:
	ret
	print_file endp

;completes reading a file and stores it in buffer    
read proc near

    mov open_mode,0       
    call open         ;open the asked file in read mode,al is a parameter to open,al=0 means read mode
    jc open_error                                                                         
    
	mov handle,ax     ;save handle                                                        
    lea dx,buffer  
	
	read_loop:            ;reads maximum 512 bytes in every loop
    mov bx,handle                   
    push cx
    mov ah,3fh    ;read a sector from a file
    mov cx,512
    int 21h
    pop cx
	or ax,ax          ;end of file?  
	mov numBytes,dx   ;store the final index of buffer
    je end_inp          ;yes,exit  
    add dx,ax         ;every iteration of this loop writes after the previously saved buffer
    jmp read_loop  
	jmp end_inp
	
	open_error:           ;Print the error
    add errcode,al
    prints openerr
    
    mov dl,errcode
    mov ah,2
    int 21h	
    
	end_inp:
	 ret
read endp

;reads from file to name & score array
recorder proc near

	lea dx,name1
	mov word ptr name_addr[0],dx

	lea dx,name2
	mov word ptr name_addr[2],dx

	lea dx,name3
	mov word ptr name_addr[4],dx

	lea dx,name4
	mov word ptr name_addr[6],dx

	lea dx,name5
	mov word ptr name_addr[8],dx

	lea dx,name6
	mov word ptr name_addr[10],dx

	lea dx,score1
	mov word ptr score_addr[0],dx

	lea dx,score2
	mov word ptr score_addr[2],dx

	lea dx,score3
	mov word ptr score_addr[4],dx

	lea dx,score4
	mov word ptr score_addr[6],dx

	lea dx,score5
	mov word ptr score_addr[8],dx

	lea dx,score6
	mov word ptr score_addr[10],dx
	
	lea dx,buffer
	mov si,dx
	mov bx,0
    
	recording:
    cmp si,numBytes
    jge end_record
	mov di,name_addr[bx] 
    call strcpy
	
    mov di,score_addr[bx]
    call strcpy
	
	add bx,2
    jmp recording
	
	end_record:  
	ret
recorder endp

rewriter proc near 
	
	;Rewrite an existing file
    lea dx,filename
	mov cl,0
	mov ah,3ch
    int 21h
    jc write_error
	
    mov handle,ax
	mov bx,handle
    
    mov ah,42h
    mov al,0    ;start pointer
    mov cx,0
    mov dx,0
    int 21h	
    jmp end_write
	
	write_error:           ;Print the error
    add errcode,al
    prints openerr
	
    
    mov dl,errcode
    mov ah,2
    int 21h	
	
	end_write:
    ret 
rewriter endp
	
score_read proc near
	lea dx,filename    
    call read

    mov bx,handle
    call close        ;close file 
    
	call recorder
	ret
	score_read endp

;compares two strings, first string passed in si,second string passed in di
strcmp proc near
	push cx
	mov cx,20
	cld
	repe cmpsb
	jb source_lose
	mov compare_result,1
	jmp strcmp_end
	
	source_lose:
	mov compare_result,0

	strcmp_end:
	pop cx
	ret
strcmp endp		
	
;source string in si, destination di
strcpy proc near
    cld  
    cpy:
    mov al,[si]
    inc si    
    cmp si,numBytes
    jge end_cpy
    cmp al,0dh
    je end_cpy
    stosb
    jmp cpy 
    
    end_cpy:
    inc si
    mov al,'$'
    stosb
    ret
strcpy endp		
	
strcpy1 proc near
	cld
	cpy1:
    mov al,[si]
    inc si    
    cmp al,'$'
    je end_cpy1
    stosb
    jmp cpy1 
    
    end_cpy1:
    inc si
    mov al,'$'
    stosb
    ret
strcpy1 endp	
		
write proc near
	push ax
	push bx
	push cx
	push dx
     mov ah,40h
     mov bx,handle
     mov cx,0  
     mov si,dx
	 
     count:
     mov al,[si]
     inc si
     cmp al,'$'
     je pr
     inc cx
     jmp count   
	 
     pr:   
     int 21h
	pop dx
	pop cx
	pop bx
	pop ax
     ret
write endp