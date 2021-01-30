	db 'menu.asm'

current_menu: dw 0

menu_clear:
	mov bl, 60
	mov bh, 1
	mov cx, 12
	mov dx, 48
	call block_clear
	ret

;Do all the menu stuff...
;	SI - menu struct
;
;	AX - item number that was picked
menu_start:
	call menu_render
	call menu_handle_input
	call menu_clear
	ret

;Throw up a menu
;	SI - menu to render
menu_render:
	push si
	mov word [current_menu], si

	mov bl, 60
	mov bh, 1
	call set_cursor_pos

	;;Get length of menu
	;;Loop over items
	;;Go pointer -> struct -> string
	;;Print # and string
	mov di, si
	movzx cx, byte [di]
	inc di

	;push cx
	;mov ch, cl
	;add cl, 2
	;mov cl, 15
	;call gui_frame
	;pop cx
	;inc bl
	;inc bh
	;call set_cursor_pos

	mov ax, 1
.loop:
	call iprint

	push si
	mov si, .divider
	call sprint
	pop si

	mov si, word [di]
	add si, 2
	call sprint

	inc bh
	call set_cursor_pos
	
	inc ax
	dec cx
	cmp cx, 0
	jg .loop

	pop si
	ret

	.divider db ' | ', 0

;Wait for fancy keystrokes, handle it all
;	SI - menu struct to handle for...
menu_handle_input:
	mov cl, byte [si]	;;Get max value
.wait:
	call keybd_read_char
	cmp al, 0
	je .wait

	call ctoi

	cmp al, cl
	jg .wait

	push ax
	cmp al, 0
	je .done

	;;Calculate the item in the struct
	mov ah, 0			;;Clear higher half so we can do word level ops
	dec al				;; 1 -> 0, since we are an actual array

	mov bx, 2			;;Each entry is 2 bytes long
	mul bx
	inc si				;;Move pointer into the table
	add si, ax			;;Advance it to the right element
	mov di, word [si]	;;Grab the pointer off to the item's struct

	call word [di]
.done:
	pop ax
	ret

test_menu:
	db 2			;;Menu length
	dw _option_help
	dw _option_help

_option_help:
	dw _option_help_handler
	db 'HELP ME!', 0

_option_help_handler:
	mov si, .msg
	call gui_print_to_hud
	ret

	.msg db 'THERE IS NO HELP IN SIGHT!', 0
