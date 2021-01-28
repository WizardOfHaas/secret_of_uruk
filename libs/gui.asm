	db 'gui.asm'

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
;		...must be a null-terminated string, 78x16 font tile map
gui_render_map:
	push cx
	push bx

	mov bl, 0
	mov bh, 6
	mov cl, 78
	mov ch, 16
	call gui_frame

	mov cl, 78
    mov bl, 1
    mov bh, 7
    call block_print

	pop bx
	pop cx
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
gui_print_to_hud:
	pusha

	mov cl, 20
	mov bl, 1
	mov bh, 1
	call block_print

	popa
	ret

;Show stats block in HUD
gui_stats_to_hud:
	pusha

	mov bl, 21
	mov bh, 1
	call set_cursor_pos

	mov si, .hp_msg
	call sprint
	
	mov ax, [_player_hp]
	call iprint

	popa
	ret

	.hp_msg db 'HP: ', 0
