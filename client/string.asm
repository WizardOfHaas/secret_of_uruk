;Int to dec string
;	AX - integer to convert
;	SI - converted string
itoa:
    pusha
    mov cx, 0
    mov bx, 10
    mov di, .t

.push:
    mov dx, 0
    div bx
    inc cx
    push dx
    test ax, ax
    jnz .push

.pop:
    pop dx
    add dl, '0'
    mov [di], dl
	inc di
    dec cx
    jnz .pop

    mov byte [di], 0
    popa
    mov si, .t
	ret

    .t times 8 db 0

;Int to hex string
;	AL - integer to convert
;	SI - converted string
htoa:
	pusha

   	push ax
	shr al, 4
   	cmp al, 10
	sbb al, 69h
   	das
 
	mov byte [.temp], al

   	pop ax
   	ror al, 4
   	shr al, 4
   	cmp al, 10
   	sbb al, 69h
   	das

   	mov byte [.temp + 1], al
   	popa

   	mov si, .temp

   	ret

   .temp db 0, 0, 0
