	db 'keybd.asm'

keylayoutlower:
	db 0x00, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x0e, 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 10, 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',';', "'", '`', 0, 0, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, 0, 0, ' ', 0

keylayoutupper:
	db 0x00, 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0x0e, 0, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 10, 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~', 0, 0, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0, 0, 0, ' ', 0
	;;  0e = backspace

shift_state: db 0
caps_lock: db 0

keybd_buff: times 256 db 0	;Keyboard buffer
keybd_buff_i: db 0, 0				;Keyboard buffer index

keybd_event_table: times 256 db 0

init_keybd:
	cli	
	mov si, word keybd_isr
	mov ax, 0x09
	
	xor bx, bx
	mov es, bx
	
	mov bx, 4
	mul bx
	mov di, ax
	mov word [es:di], si
	mov word [es:di + 2], cs
	sti
	ret

__old_keyb_isr:
	xor ax, ax
	in al, 0x60   ; get key data
	mov bl, al   ; save it
	mov word [.isr_key], ax
 
	in al, 0x61   ; keybrd control
	mov ah, al
	or al, 0x80   ; disable bit 7
	out 0x61, al   ; send it back
	xchg ah, al   ; get original
	out 0x61, al   ; send that back
 
	mov al, 0x20   ; End of Interrupt
	out 0x20, al   ;
 
	and bl, 0x80   ; key released
	jnz .done   ; don't repeat
.done:
	mov ax, word [.isr_key]

	call print_regs
	
	iret

	.isr_key dw 0

keybd_isr:
	pushad

	in al, 0x60					;Get key data
	push ax

	in al, 0x61					;Keybrd control
	mov ah, al
	or al, 0x80					;Disable bit 7
	out 0x61, al				;Send it back
	xchg ah, al					;Get original
	out 0x61, al				;Send that back

	pop ax						;Make sure AX just show AL data
	mov ah, 0

	;Check for and run any registered keybd events
	;mov si, keybd_event_table
	;call run_events

	;Handle shift, capslock, meta-keys
	cmp ax, 0x2A				;Left-shift down
	je .shift_down
	cmp ax, 0x36				;Right-shift down
	je .shift_down

	cmp ax, 0xAA				;Left-shift up
	je .shift_up
	cmp ax, 0xB6				;Right-shift up
	je .shift_up

	cmp ax, 0x3A				;Caps lock down
	je .shift_toggle

	cmp ax, 0x0E				;Backspace
	je .backspace

	cmp ax, 0x81				;Do we have a key up scancode?
	jge .key_up

	;Are we shifted?
	mov si, keylayoutlower 		;Use un-shifted scancode table

	;Handle compination of caps lock and shifts
	mov bl, byte [caps_lock]
	mov bh, byte [shift_state]
	xor bl, bh

	cmp bl, 0
	je .decode

	mov si, keylayoutupper 		;Use shifter scancode table, if shifted

.decode:
	;Decode scancode -> character
	add si, ax
	mov al, byte [si]

	;Add to buffer
	movzx di, byte [keybd_buff_i]
	add di, keybd_buff
	mov byte [di], al
	inc byte [keybd_buff_i]

	jmp .done

.shift_toggle:
	mov al, byte [caps_lock]
	xor al, 1
	mov byte [caps_lock], al
	jmp .done

.shift_down:
	mov byte [shift_state], 1	;We are shifted up
	jmp .done

.shift_up:
	mov byte [shift_state], 0	;We are not shifted
	jmp .done

.backspace:
	;Remove from buffer
	movzx di, byte [keybd_buff_i]
	add di, keybd_buff
	sub di, 1
	mov byte [di], 0
	dec byte [keybd_buff_i]

	jmp .done

.key_up:
.done:
	;Send EOI
	mov al, 0x20
	out 0xA0, al
	out 0x20, al

	popad
	iret

;Clear keyboard buffer and reset buffer index
keybd_clear_buff:
	pusha
	cli

	mov word [keybd_buff_i], 0	;Reset buffer index

	;Reset buffer to 0's
	mov ax, 254
	mov di, keybd_buff
	mov cx, cs
	mov fs, cx
	mov bx, 0

	call memset

	sti
	popa
	ret

;Pop off key from the buffer
;	AL - newest character!
keybd_read_char:
	xor ax, ax

	mov al, byte [keybd_buff_i]
	cmp al, 0
	je .done

	cli
	sub al, 1
	mov byte [keybd_buff_i], al

	push si
	mov si, keybd_buff
	add si, ax

	mov al, byte [si]
	pop si
	sti
.done:
	ret

keybd_wait:
.loop:
	call keybd_read_char
	cmp al, 0
	je .loop
	ret

;Get this call a string!
;	DI - where to put the string
keybd_get_string:
	pusha
.loop:
	call keybd_read_char
	cmp al, 0
	je .loop

	cmp al, 0x0A
	je .done

	call cprint
	mov byte [di], al
	inc di

	jmp .loop

.done:
	inc di
	mov byte [di], 0

	popa
	ret
