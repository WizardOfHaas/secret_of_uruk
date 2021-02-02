	db 'gui.asm'

current_map: dw 0
field_of_view: times 1248 db 1

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

	mov bl, 0
	mov bh, 6
	mov cl, 78
	mov ch, 16
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
%define _VIEW 5
gui_update_fov:
	pusha

	mov bl, byte [_player_x]
	mov bh, byte [_player_y]

	sub bl, 1
	sub bh, 7

	xor cx, cx

	push bx

	call print_regs
.loop_h_minus:
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_h_minus_done

	call gui_map_show_tile

	inc cx
	cmp cx, _VIEW
	jge .loop_h_minus_done

	dec bl
	cmp bl, 0
	jg .loop_h_minus

.loop_h_minus_done:
	call gui_map_show_tile

	xor cx, cx

	pop bx
	push bx
.loop_h_plus:	
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_h_plus_done

	call gui_map_show_tile

    inc cx
    cmp cx, _VIEW
    jge .loop_h_plus_done

	inc bl
	cmp bl, 78
	jl .loop_h_plus

.loop_h_plus_done:
	call gui_map_show_tile

	xor cx, cx

	pop bx
	push bx
.loop_v_minus:
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_v_minus_done

	call gui_map_show_tile

    inc cx
    cmp cx, _VIEW
    jge .loop_v_minus_done

	dec bh
	cmp bh, 0
	jg .loop_v_minus

.loop_v_minus_done:
	call gui_map_show_tile

	xor cx, cx

	pop bx
	push bx
.loop_v_plus:
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_v_plus_done

	call gui_map_show_tile

    inc cx
    cmp cx, _VIEW
    jge .loop_v_plus_done

	inc bh
	cmp bh, 16
	jl .loop_v_plus

.loop_v_plus_done:
	call gui_map_show_tile

	xor cx, cx

	pop bx
	push bx
.loop_hm_vm:
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_hm_vm_done

	call gui_map_show_tile

    inc cx
    cmp cx, _VIEW
    jge .loop_hm_vm_done

	dec bl
	dec bh
	cmp bh, 0
	jg .loop_hm_vm

.loop_hm_vm_done:
	call gui_map_show_tile

	xor cx, cx

	pop bx
	push bx
.loop_vm_hp:
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_vm_hp_done

	call gui_map_show_tile

    inc cx
    cmp cx, _VIEW
    jge .loop_vm_hp_done

	inc bl
	dec bh
	cmp bh, 0
	jg .loop_vm_hp

.loop_vm_hp_done:
	call gui_map_show_tile

	xor cx, cx

	pop bx
	push bx
.loop_hp_vp:
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_hp_vp_done

	call gui_map_show_tile

    inc cx
    cmp cx, _VIEW
    jge .loop_hp_vp_done

	inc bl
	inc bh
	cmp bh, 16
	jl .loop_hp_vp

.loop_hp_vp_done:
	call gui_map_show_tile

	xor cx, cx

	pop bx
	push bx
.loop_vp_hm:
	call gui_map_get_tile
	cmp al, '.'
	jne .loop_vp_hm_done

	call gui_map_show_tile

    inc cx
    cmp cx, _VIEW
    jge .loop_vp_hm_done

	dec bl
	inc bh
	cmp bh, 16
	jl .loop_vp_hm

.loop_vp_hm_done:
	call gui_map_show_tile

	pop bx

	popa
	ret

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

	mov byte [char_attr], 2

	xor cx, cx
	xor dx, dx

	mov cl, bh

	mov ax, 78
	mul cx
	
	mov dl, bl
	add ax, dx

	mov di, field_of_view
	add di, ax
	mov byte [di], 1

	pop bx
	add bl, 1
	add bh, 7
	call set_cursor_pos

	add si, ax
	mov al, byte [si]
	call cprint

	mov byte [char_attr], 7	
.done:
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
