;TTY routines - text screen control and such

db 'tty.asm'

tty_buffer: times 80*26*2 db 0 ;TTY text memory buffer
xpos: db 0
ypos: db 0
char_attr: db 0x07

;Scroll a block of the text-mode screen
;   BX - bottom left corner
;   CL - width (in bytes, so 2 * chars)
;   CH - last row in block
scroll_block:
    pusha
    push bx
.loop:
    call scroll_line

    inc bh
    cmp bh, ch
    jl .loop

    ;;We need to clear the last line
    pop bx

    push fs
    
    call screen_pos_to_offset
    
	mov ax, 0xB800
    mov fs, ax

    call screen_pos_to_offset
    mov di, ax
    movzx ax, cl
    xor bx, bx

    call print_regs

    call memset

    pop fs

    popa
    ret

;Scroll up a single line on screen
;   BX - top left corner
;   CL - width (in bytes, so 2 * chars)
scroll_line:
    pusha
    push es
    push fs

    ;;We will be using memcpy in a loop, so...
    ;;  get out pointers ready
	mov ax, 0xB800
	mov es, ax
    mov fs, ax

    call screen_pos_to_offset
    mov si, ax

    dec bh
    call screen_pos_to_offset
    mov di, ax

    movzx ax, cl
    call memcpy

    pop fs
    pop es
    popa
    ret

;Convert a x/y position to fancy offset, works on whole screen buffer
;	BX - x/y
;
;	AX - linear offset in map buffer
screen_pos_to_offset:
	push cx
	push dx
    push bx

	movzx ax, bh			;Get y cursor position
	mov dx, 160				;2 bytes (char/attrib)
	mul dx					;for 80 columns
	movzx bx, bl			;Get x cursor position
	shl bx, 1				;times 2 to skip attrib
    add ax, bx

    pop bx
	pop dx
	pop cx
	ret


;Print block of text at given location
; need to refactor to use block_blit and strlen...
;	BL - x pos
;	BH - y pos
;	CL - width
;	SI - string to print
block_print:
	pusha
	
	mov byte [.width], cl		;;Save over image width

	mov ax, bx					;;Save current cursor pos
	call get_cursor_pos
	push bx

	mov bx, ax					;;Set to initial position
	call set_cursor_pos
.loop:
	lodsb						;;Load up next char
	cmp al, 0					;;Bail if it's a terminator
	je .done

	call cprint					;;Print the character

	dec cl						;;Dec and check the current column
	cmp cl, 0
	jg .loop					;;As long as we have space keep looping

	;;Deal with the wrap
	mov cl, byte [.width]
	inc bh
	call set_cursor_pos
	jmp .loop
	
.done:
	pop bx
	call set_cursor_pos

	popa
	ret

	.width db 0

;	DX - length to zero out
block_clear:
	pusha
	
	mov byte [.width], cl		;;Save over image width

	mov ax, bx					;;Save current cursor pos
	mov bx, ax					;;Set to initial position
	call set_cursor_pos
.loop:
	mov al, 0
	call cprint					;;Print the character

	dec dx
	cmp dx, 0
	je .done

	dec cl						;;Dec and check the current column
	cmp cl, 0
	jg .loop					;;As long as we have space keep looping

	;;Deal with the wrap
	mov cl, byte [.width]
	inc bh
	call set_cursor_pos
	jmp .loop
	
.done:
	popa
	ret

	.width db 0

;Same as block print, but no null termination
;	See above...
;	DX - Length of block to print
block_blit:
	mov byte [.width], cl		;;Save over image width

	mov ax, bx					;;Save current cursor pos
	call get_cursor_pos
	push bx

	mov bx, ax					;;Set to initial position
	call set_cursor_pos
.loop:
	lodsb						;;Load up next char
	call cprint					;;Print the character

	dec dx
	cmp dx, 0
	je .done

	dec cl						;;Dec and check the current column
	cmp cl, 0
	jg .loop					;;As long as we have space keep looping

	;;Deal with the wrap
	mov cl, byte [.width]
	inc bh
	call set_cursor_pos
	jmp .loop
	
.done:
	pop bx
	call set_cursor_pos

	popa
	ret

	.width db 0


;Move cursor to position
;	BL - x pos
;	BH - y pos
set_cursor_pos:
	mov byte [xpos], bl
	mov byte [ypos], bh
	ret

get_cursor_pos:
	mov bl, byte [xpos]
	mov bh, byte [ypos]
	ret

;Fetch character at given position
;	BL - x pos
;	BH - y pos
;
;	AL - Char
;	AH - Attributes
get_char_at:
	push dx
	push di
	push bx

	movzx ax, bh			;Get y cursor position
	mov dx, 160				;2 bytes (char/attrib)
	mul dx					;for 80 columns
	movzx bx, bl			;Get x cursor position
	shl bx, 1				;times 2 to skip attrib
 	
 	mov di, 0		        ;start of video memory
	add di, ax      		;add y offset
	add di, bx      		;add x offset

	push es
	mov ax, 0xB800
	mov es, ax

	mov ax, [es:di]

	pop es

	pop bx
	pop di
	pop dx
	ret

;Set char to bitmapped font
;	BP - char bitmap
;	DX - ASCII code of char to change
set_char_font:
	pusha

	mov	cx, 1			; we'll change just 2 of them
	mov	bh, 14			; 14 bytes per char
	xor	bl, bl			; RAM block
	mov	ax, 1100h		; change font to our font
	int	10h	
	
	popa
	ret

;Set character attribute byte
;	AL - new char attribute
set_char_attr:
	mov byte [char_attr], al
	ret

;Print [  OK  ] message
print_ok:
	pusha

	mov ah, byte [char_attr]	;Save over current char_attr

	mov al, 0x07				;Go grey on black
	call set_char_attr

	mov al, '['
	call cprint

	mov al, 0x02				;Set green on black
	mov si, .ok
	call attr_sprint

	mov al, 0x07
	call set_char_attr

	mov al, ']'
	call cprint

	mov al, ah					;Set back to old char_attr
	call set_char_attr

	call new_line

	popa
	ret

	.ok db '   OK   ',0

;Print string with given attr
;	SI - string
;	AL - attribute
attr_sprint:
	pusha

	mov ah, byte [char_attr]
	call set_char_attr

	call sprint

	mov al, ah
	call set_char_attr

	popa
	ret

;Print an integer to the screen in dec
;	AX - integer to print
iprint:
	pusha

	call itoa
	call sprint

	popa
	ret

;Print an integer to the screen in hex (word)
;	AX - integer to print
hprint:
	pusha

	mov bx, ax

	mov al, bh 
	call hprint_byte

	mov al, bl
	call hprint_byte

	popa
	ret

;Print an integer to the screen in hex (byte_)
;	AL - integer to print
hprint_byte:
	pusha

	call htoa
	call sprint

	popa
	ret

;Print a string to the screen
;	SI - address of string to print
sprint:
	pusha

.loop:				;Loop over string in [si]
	mov al, [si]
	cmp al, 0		;Have we reached the end?
	je .done
	inc si			;Go to next char

	call cprint 	;Print character

	jmp .loop

.done:
	popa
	ret

;Print a character X times
;	AL - char to print
;	AH - times to print
rep_cprint:
	pusha
.loop:
	call cprint
	dec ah
	cmp ah, 0
	jg .loop
	popa
	ret

;Print a char directly to the screen(no longer buffered)
;al - character to print to screen
bios_cprint:
	pusha
	mov ah, 0x0E
	mov bh, 0
	int 0x10
	popa
	ret

cprint:
	pusha

	push es
	push ax					;Save ax

	movzx ax, byte [ypos]	;Get y cursor position
	mov dx, 160				;2 bytes (char/attrib)
	mul dx					;for 80 columns
	movzx bx, byte [xpos]	;Get x cursor position
	shl bx, 1				;times 2 to skip attrib
 	
 	;mov di, tty_buffer		;start of video memory
	mov di, 0x00
	mov cx, 0xB800
	mov es, cx

	add di, ax      		;add y offset
	add di, bx      		;add x offset

	;Setup char and attributes to write
 	pop ax					;Retrive char value
 	mov ah, byte [char_attr];Set char attribute
	
 	cmp al, 10
 	je .nl

	mov word[es:di], ax		;Do the direct write to text ram

	call advence_cursor
	jmp .done

.nl:
	call new_line

.done:
	call display_buffer

	pop es
 	popa
 	ret

;Scroll buffer and update tty
scroll:
	call scroll_buffer
	call display_buffer
	ret

;Scroll buffer
scroll_buffer:
	pusha
    push es

	;Scroll screen buffer
	mov ax, 0x00				;Set fs to text memory
	mov fs, ax
	mov es, ax

	mov di, tty_buffer			;Sex di to start of tty_buffer
	mov si, tty_buffer + 80*2	;Set si to 2nd line of tty buffer

	mov ax, 80*25*2				;80x24 section of screen

	call memcpy					;Shift buffer down

	;Scroll cursor
	mov byte [xpos], 0
	mov byte [ypos], 24

    pop es
	popa
	ret

;Push buffer into text memory
display_buffer:
	ret	;;Lets try direct... for speed...

	pusha
	push es
	push fs

	mov ax, 0xB800			;Set fs to text memory
	mov fs, ax
	xor di, di				;Sex di to start of memory

	mov ax, 0x00			;Set es to code/data segment
	mov es, ax
	mov si, tty_buffer 		;Set si to tty text buffer

	mov ax, 80*25*2			;80x25 screen

	call memcpy				;Copy over buffer

	pop fs
	pop es
	popa
	ret

;Set all text memory to '0'
clear_screen:
	pusha

	mov ax, 0x00			;Set es to code/data segment
	mov fs, ax
	mov di, tty_buffer 		;Set si to tty btext buffer

	mov ax, 80*25*2			;80x25 screen

 	mov bh, 0x0F			;White on black attribute
 	mov bl, 0				;ascii value of 0 to display
 
 	call memset				;Set buffer memory

 	;Reset cursor position
 	mov byte [xpos], 0
	mov byte [ypos], 0

	call display_buffer 	;Push buffer into text memory

	popa
	ret

;Move cursor to (xpos, ypos)
update_cursor:
	pusha

	cmp byte [xpos], 80		;Do we need to wrap?
	jle .next

	;Wrap cursor
	mov byte [xpos], 0
	add byte [ypos], 1

.next:
	cmp byte [ypos], 25		;Do we need to scroll?
	jl .done

	call scroll_buffer
	jmp .done

.done:

	mov dl, byte [xpos]
	mov dh, byte [ypos]

    mov  ah, 2
    mov  bh, 0
    int  10h

	popa
	ret

;Turn on cursor
cursor_on:
	pusha
	mov  ah, 1
	mov  cx, 4
	int  10h
	popa
	ret

;Advance cursor
advence_cursor:
	pusha

	add byte [xpos], 1		;advance to right
 	
	call update_cursor
	
	popa
	ret

new_line:
	pusha

	mov byte [xpos], 0
	add byte[ypos], 1
	call update_cursor

	popa
	ret

;Print regesters to TTY
print_regs:
	pusha

	;Push regs to display to stack
	push fs
	push es
	push di
	push si
	push dx
	push cx
	push bx
	push ax

	mov bl, 1
	mov bh, 23
	call set_cursor_pos

	xor cx, cx
.loop:					;Iterate over registers on stack
	mov si, .labels		;Fetch register's label
	mov ax, 6
	mul cx
	add si, ax

	call sprint 		;Print register

	inc cx				;Inc for next loop

	pop ax				;Grab register from stack
	call hprint

	cmp cx, 8			;Loop until we print out all registers
	jne .loop

	call new_line

	popa
	ret

	.labels:
		db ' ax: ', 0
		db ' bx: ', 0
		db ' cx: ', 0
		db ' dx: ', 0
		db ' si: ', 0
		db ' di: ', 0
		db ' es: ', 0
		db ' fs: ', 0
