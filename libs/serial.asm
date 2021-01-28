	db 'serial.asm'

;Right now this is all hardcoded...
init_serial:
	pusha

	mov ah, 0           ;Initialize opcode
    mov al, 11100011b   ;Parameter data. 9600 8N1
    mov dx, 0           ;COM1: port.
    int 0x14

	popa
	ret

serial_send_byte:
	pusha
    mov dx, 0 ;Echo out for safety...and it breaks if I remove this...
    mov ah, 1
    int 0x14
    popa
	ret

serial_recv_byte:
	push dx
	mov dx, 0
    mov ah, 2
    int 0x14
	pop dx
	ret
