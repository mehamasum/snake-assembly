;------------------------------------Procedure List----------------------------------
;MainMenuListener	- Action listener for main menu
;ChangeMenuPos		- Changes the arrows from one menu to another upon user input
;showMainMenu		- Draws the main menu window

MainMenuListener proc 
    PromptAgain:
    mov ah,1h  ; check if any key was pressed
    int 16h
    jnz UpDownPressed  ;pressed
    jmp PromptAgain    ;no-key
    
    UpDownPressed:
    mov ah,0h	;get which key in ah
    int 16h    
    cmp ah,48h ;up key
    je UpKey
    cmp ah,50h ;down key
    je DownKey
    cmp al,13
    je OptionSelected
    jmp PromptAgain
    
    UpKey:
    cmp MenuPos,1
    je MenuPosOne
    mov dh,MenuPos
    mov dl,0
    push dx
    call ChangeMenuPos    
    dec MenuPos
    mov dh,MenuPos
    mov dl,1
    push dx
    call ChangeMenuPos
    jmp PromptAgain
    
    ;>1
    MenuPosOne:
    mov dh,MenuPos  ;unmark that
    mov dl,0
    push dx
    call ChangeMenuPos
    
    mov MenuPos,3
     
    mov dh,MenuPos    ;mark this
    mov dl,1
    push dx
    call ChangeMenuPos
  
    jmp PromptAgain
    
    DownKey:    
    cmp MenuPos,3
    je Top
    mov dh,MenuPos
    mov dl,0
    push dx
    call ChangeMenuPos
    inc MenuPos   
    mov dh,MenuPos
    mov dl,1 
    push dx
    call ChangeMenuPos
    jmp PromptAgain
    
    ;<3
    Top:    
    mov dh,MenuPos  ;unmark that
    mov dl,0
    push dx
    call ChangeMenuPos 
    mov MenuPos,1
    mov dh,MenuPos   ;mark this
    mov dl,1
    push dx
    call ChangeMenuPos
    jmp PromptAgain
    
    OptionSelected: ; push to stack
    xor ax,ax
    pop temp
    mov al, MenuPos
    push ax
    push temp 
    ret
endp MainMenuListener    

;Changes the arrows from one menu to another upon user input
ChangeMenuPos proc 
    pop temp
    pop dx
    cmp dh,1
    je StartMenuSel
    cmp dh,2
    je ScoreMenuSel
    cmp dh,3
    
    ;Exit
    cmp dl,1
    je ExitMarked
    ExitUnmarked:
    mov dx,ExitMenuCor 
    mov bp,offset ExitMenu 
    jmp doneMarking
    
    ExitMarked:
    mov dx,ExitMenuCor 
    mov bp,offset ExitMenuSelected
    
    jmp doneMarking
    
    ;Start 
    StartMenuSel:
    cmp dl,1
    je StartMarked
    StartUnmarked:
    mov dx,StartMenuCor 
    mov bp,offset StartMenu
    jmp doneMarking
    
    StartMarked:
    mov dx,StartMenuCor 
    mov bp,offset StartMenuSelected
    
    jmp doneMarking
    
    ;Scoreboard
    ScoreMenuSel:
    cmp dl,1
    je ScoreMarked
    ScoreUnmarked:
    mov dx,ScoreMenuCor 
    mov bp,offset ScoreMenu
    jmp doneMarking
    
    ScoreMarked:
    mov dx,ScoreMenuCor 
    mov bp,offset ScoreMenuSelected
    
    doneMarking:
    mov bh,0
    mov ah,13h
    mov al,0 
    mov bl,10
    mov cx,16d
    int 10h
    push temp
    ret    
endp ChangeMenuPos

ShowMainMenu proc
pusher            
    mov cx,10
    mov dh, 0
	
    mov bh,0
    mov ah,13h
    mov al,0
    mov dl,32
    add dh,4
    mov bl,10
    mov cx,16
    mov bp,offset StartMenuSelected
    int 10h
    mov StartMenuCor,dx
    
    add dh,3
    mov bp,offset ScoreMenu
    int 10h
    mov ScoreMenuCor,dx
    
	add dh,3
    mov bp,offset ExitMenu
    int 10h
    mov ExitMenuCor,dx  
    
	; ascii graphics
	mov bh,0
    mov ah,13h
    mov al,0
    mov dh, 16
    mov dl, 14 
    mov bl,0eh
    mov cx,53
    mov bp,offset instruc
    int 10h 
	
	; ascii graphics
	mov bh,0
    mov ah,13h
    mov al,0
    mov dh, 22
    mov dl, 28 
    mov bl,10
    mov cx,78
    mov bp,offset credit
    int 10h 
popper   
    ret
endp ShowMainMenu