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
