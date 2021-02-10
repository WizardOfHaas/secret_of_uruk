	db 'gui.asm'

current_map: dw 0
field_of_view: times 1248 db 0

gui_render_map_screen:
	mov bl, 0
	mov bh, 6
	mov cl, 80
	mov dx, 78*19
	call block_clear


	mov si, word [current_map]
	call gui_render_map
	call player_display
	ret

;Print a message inside a fancy frame
;	SI - Message to alert
gui_alert:
	pusha
	
	call strlen		;;Get length of message

	mov cl, al
	mov ch, 4
	call gui_frame

	popa
	ret

;Print a fancy frame
;	BL - x position
;	BH - y position
;	CL - width
; 	CH - height
gui_frame:
	pusha

	mov ax, bx

	;Save over cursor pos
	call get_cursor_pos
	push bx

	mov bx, ax				;;Fetch param and set starting position
	call set_cursor_pos

	mov al, 1				;;Print first corner
	call cprint

	mov al, 2				;;Print top line
	mov ah, cl
	call rep_cprint

	mov al, 3				;;Print next corner
	call cprint
	
	inc bh
	call set_cursor_pos

.loop:
	mov al, 5
	call cprint
	
	mov al, ' '
	mov ah, cl
	call rep_cprint
	
	mov al, 5
	call cprint

	;call new_line
	inc bh
	call set_cursor_pos

	dec ch
	cmp ch, 0
	jg .loop

	mov al, 6
	call cprint
	
	mov al, 2
	mov ah, cl
	call rep_cprint

	mov al, 7
	call cprint

	pop bx
	call set_cursor_pos

	popa
	ret

;Throw up a map!
;	SI - map struct to display
;		...must be a null-terminated string, 78x16 font tile map => 1248 tiles
;	Also need to do field of view check here...
gui_render_map:
	push cx
	push bx

	mov word [current_map], si	;;Save current map struct

	;mov bl, 0
	;mov bh, 6
	;mov cl, 78
	;mov ch, 16
	;call gui_frame
	
	mov cl, 78
    mov bl, 1
    mov bh, 7
	call set_cursor_pos
    ;call block_print

	mov di, field_of_view
.loop:
	;;Print it out...
	mov al, byte [si]
	cmp al, 0
	je .done

	cmp byte [di], 0	;;Is this an unseen tile?
	je .darkness

	call cprint

.wrap:
	dec cl
	cmp cl, 0
	jg .next

	mov cl, 78
	inc bh
	mov bl, 1
	call set_cursor_pos
	jmp .next
.darkness:
	inc bl
	call set_cursor_pos
	jmp .wrap
.next:
	inc si
	inc di
	jmp .loop

.done:
	pop bx
	pop cx
	ret

;This is gross, all long form and dumb right now. May improve later...
;	SI - map struct
gui_update_fov:
	pusha

	;;Scan over left side of screen
	xor bx, bx
.loop_1:
	call gui_map_check_line
	jc .next_1

	;call gui_map_show_tile
.next_1:
	inc bh
	cmp bh, 16
	jl .loop_1

	;;Scan right side
	mov bl, 78
	mov bh, 0
.loop_2:
	call gui_map_check_line
	jc .next_2

	;call gui_map_show_tile
.next_2:
	inc bh
	cmp bh, 16
	jl .loop_2

	;;Do some tricks, worst case we need to scan 14 chars to either side of player
	;;	calculate if player is close enough to the edge
	;;	load up bl with proper start value, set end value
	;;	loop over and check each sight line

	xor bx, bx
	xor dx, dx

	mov cx, word [player_pos]
	cmp cl, 14
	jl .loop_3	;;We are going to start at 0

	mov bl, cl	;;Otherwise, we only need 14 lines
	sub bl, 14
	mov dx, bx	;;Save bx

	cmp cl, 64	;;Do we need to go to the total edge of the screen?
	jg .loop_3

	add cl, 14
	
.loop_3:
	call gui_map_check_line
	jc .next_3

.next_3:
	inc bl
	cmp bl, cl
	jl .loop_3

	mov bx, dx
	mov bh, 16
.loop_4:
	call gui_map_check_line
	jc .next_4

.next_4:
	inc bl
	cmp bl, cl
	jl .loop_4

	popa
	ret

;	SI - map struct
;	BX - tile x/y
gui_map_check_line:
	pusha
	mov word [.x], bx

	mov cx, word [player_pos]

	sub cl, 1
	sub ch, 7
	mov word [.px], cx

	mov bx, cx
.loop:
	cmp bl, byte [.x]
	jg .sub_x
	.sub_x_done:

	cmp bh, byte [.y]
	jg .sub_y
	.sub_y_done:

	cmp bl, byte [.x]
	jl .add_x
	.add_x_done:

	cmp bh, byte [.y]
	jl .add_y
	.add_y_done:

	call gui_map_get_tile
	cmp al, '.'
	jne .blocked

	;;Should add check for previosuly uncovered tiles... improve speed...

	call gui_map_show_tile

	cmp bx, word [.x]
	jne .loop
	jmp .ok

.sub_x:
	sub bl, 1
	jmp .sub_x_done
.sub_y:
	sub bh, 1
	jmp .sub_y_done
.add_x:
	add bl, 1
	jmp .add_x_done
.add_y:
	add bh, 1
	jmp .add_y_done

.blocked:
	call gui_map_show_tile
	stc
	jmp .done
.ok:
	clc
.done:
	popa
	ret

    .x db 0
    .y db 0

    .px db 0
    .py db 0

;	SI - map struct
;	BL - X pos
;	BH - y pos
gui_map_show_tile:
	pusha

	;;Need to fix for underlfow, also...
	
	cmp bl, 77
	jg .done

	cmp bh, 15
	jg .done

	cmp bh, 0xFF
	je .done
	
	cmp bl, 0xFF
	je .done

	push bx

	;mov byte [char_attr], 2

	xor cx, cx
	xor dx, dx

	mov cl, bh

	mov ax, 78
	mul cx
	
	mov dl, bl
	add ax, dx

	pop bx
	add bl, 1
	add bh, 7
	call set_cursor_pos

	cmp byte [di], 1
	je .done

	mov di, field_of_view
	add di, ax
	
	mov byte [di], 1

	add si, ax
	mov al, byte [si]
	call cprint

.done:
	;mov byte [char_attr], 7	
	popa
	ret

;	SI - map struct
;	BL - x
;	BH - y
;
;	AL - char at point
gui_map_get_tile:
	push si
	push bx
	push cx
	push dx

    xor cx, cx
    xor dx, dx

    mov cl, bh

    mov ax, 78
    mul cx

    mov dl, bl
    add ax, dx

    add si, ax
    mov al, byte [si]	

	pop dx
	pop cx
	pop bx
	pop si
	ret

gui_map_set_tile:
	push si
	push bx
	push cx
	push dx
	push ax

    xor cx, cx
    xor dx, dx

    mov cl, bh

    mov ax, 78
    mul cx

    mov dl, bl
    add ax, dx

    add si, ax

	pop ax
    mov byte [si], al

	pop dx
	pop cx
	pop bx
	pop si
	ret

;Throw stuff in the heads up display
gui_render_hud:
	pusha
	
	mov bl, 0
	mov bh, 0
	mov cl, 78
	mov ch, 4
	call gui_frame

	popa
	ret

;Print in HUD message area
;	SI - message
;		...it will be wrapped...
;	Should change to scroll later...
gui_print_to_hud:
	pusha

	mov cl, 20
	mov bl, 1
	mov bh, 1
	mov dx, 80
	call block_clear
	call block_print

	popa
	ret

;Show stats block in HUD
gui_stats_to_hud:
	pusha

	mov bl, 25
	mov bh, 1
	mov cl, 16
	mov dx, 16*4
	call block_clear

	call set_cursor_pos

	mov si, .lv_msg
	call sprint	
	mov ax, [_player_lv]
	call iprint

	inc bh
	call set_cursor_pos
	mov si, .hp_msg
	call sprint
	mov ax, [_player_hp]
	call iprint

	inc bh
	call set_cursor_pos
	mov si, .ac_msg
	call sprint
	mov ax, [_player_ac]
	call iprint

	inc bh
	call set_cursor_pos
	mov si, .pw_msg
	call sprint
	mov ax, [_player_pw]
	call iprint

	popa
	ret

	.lv_msg db 'LEVEL: ', 0
	.hp_msg db 'HEALTH:', 0
	.ac_msg db 'ARMOR: ', 0
	.pw_msg db 'POWER: ', 0

;Show glyphs
gui_glyphs_to_hud:
	pusha

	mov bl, 42
	mov bh, 1
	mov cl, 7
	mov si, player_glyphs
	call block_print

	popa
	ret

;Show combat screen
;	SI - monster table entry
gui_render_combat:
	push si
	push si					;;Save the monster pointer
	push si
	
	;;Start by rendering the combat screen
	mov bl, 0
	mov bh, 6
	mov cl, 25
	mov ch, 16
	call gui_frame

	mov bl, 59
	mov bh, 6
	mov cl, 19
	mov ch, 16
	call gui_frame

	pop si

	;;Show the monster image
	mov bl, 3
	mov bh, 10
	call set_cursor_pos

	mov di, si
	mov si, word [di]
	add si, 29
	call strlen
	add si, ax
	inc si

	call img_display

	mov bl, 27
	mov bh, 6
	mov cl, 32
	mov dx, 576
	call block_clear

	pop si
	call gui_render_monster_health
	pop si

	ret

;	SI - monster table entry
gui_render_monster_health:
	mov di, word [current_monster]

	mov bl, 2
	mov bh, 8
	call set_cursor_pos

	mov si, .clear
	call sprint

	call set_cursor_pos

	mov ax, word [current_monster_hp]
	call iprint

	add bl, 5
	call set_cursor_pos
	mov si, .divider
	call sprint

	add bl, 3
	call set_cursor_pos
	mov si, word [di]
	mov ax, word [si + 19]
	call iprint

	ret

	.divider db ' / ', 0
	.clear db '            ', 0

gui_print_combat_msg:
	mov bl, byte [.pos]
	mov bh, byte [.pos + 1]
	mov cl, 32
	
	call block_print
	inc byte [.pos + 1]
	cmp byte [.pos + 1], 24
	jl .done
	
	;;For now clear on overflow, block_print needs to be rewritten to scroll blocks...
	mov byte [.pos + 1], 7
	mov bl, 27
    mov bh, 6
    mov cl, 32
    mov dx, 576
    call block_clear

.done:
	ret

	.pos db 27, 7

gui_clear_combat_msg:
	pusha
	mov byte [gui_print_combat_msg.pos + 1], 7
    mov bl, 27
    mov bh, 6
    mov cl, 32
    mov dx, 576
    call block_clear
	popa
	ret

;Prompt user for text input
;	SI - prompt
;	DI - where to store input string
gui_combat_prompt:
	call gui_clear_combat_msg
	call gui_print_combat_msg

	inc byte [gui_print_combat_msg.pos + 1]
	mov bl, 27
	mov bh, 8
	call set_cursor_pos

	call keybd_get_string
	ret
