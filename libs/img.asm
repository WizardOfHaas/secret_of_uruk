	db 'img.asm'

;Convert bitmap image to font set
;	SI - Image to convert
;	DI - where to put it
;	Currently will assume 128 x 128 image -> 16 x 8 font tiles -> 128 total tiles
;	Addressed by bytes that's 8 x 16, not a big issue...
;	tile(N) = (1 + ROW) * N, (1 + ROW) * N + 8
img_to_font:
	pusha

	;For 0 to 128...
	;ROW = int(N / 32)
	;Fetch tile(N)
	;Store in [DI]
	;DI += 2

	mov cx, 0
.loop:
	;AX -> (N / 32) * N
	mov ax, cx
	mov bx, 32
	div bx
	mul cx

	push si

	add si, ax
	mov bl, byte [si]
	mov byte [di], bl

	mov bl, byte[si + 16]
	mov byte [di + 1], bl
	
	pop si

	add di, 2

	;Loop 32 times
	inc cx
	cmp cx, 128
	jle .loop

	popa
	ret

;	ES:DI - where to store font
img_save_font:
	pusha
	
    mov  bh, 06h                  ; get font table information
    mov  ax, 1130h                ;
    int  10h                     ;

    mov  si, bp                   ; make ds:si = offset font table
    mov  cx, 512                  ; 512 chars
.loop:
    movsw                       
    movsw
    movsw
    movsw                  ; *** on VGA's we need 16 bytes per char
    movsw                  ; ***  if we are on an EGA, delete one of
    movsw                  ; ***  the movsw's
	movsw
	movsw
    loop .loop                  ; loop

	popa
	ret

;Load up custom image font
;	BP - "font" to load
;	CX - Number of tiles to load
;	DX - Starting char code to load
img_set_font:
    pusha
	
    mov bh, 16          ; 14 bytes per char
    mov bl, 0          ; RAM block
    mov ax, 1100h       ; change font to our font
    int 10h

    popa
    ret

;Lets display an image in the worst way possible...
;	...god help me
;	SI - Image struct to blit out
;		Should be formed as...
;	BL - x pos
;	BH - y pos
;
;	db NUMBER OF FONT TILES
;	...set of 8x16 bit font tiles...
;	db NUMBER OF TILES TO DISPLAY
;	...map of tiles ot display...
img_display:
	pusha
	push bx

	;;Get size of font pack
	xor cx, cx				;;Clear CX, this will hold the size of the font pack
	mov cl, byte[si]		;;Grab the pack's size

	;;Load font back
	inc si					;;Advance our pointer to the actual pack data
	mov bp, si				;;Setup params
	mov dx, 127				;;Start at char code 127
	call img_set_font		;;Call out to update font tiles

	;;Calculate location of tile mapping
	mov ax, 16				;;Each char is 16 bits of data
	mul cx					;;CX holds the count of chars in our font pack
	add si, ax				;;Advence out pointer past the font pack

	xor cx, cx				;;Clear CX, this will hold the number of tiles to render
	mov cl, byte[si]		;;Grab the length of the tile map

	inc si					;;Advance pointer to next value
	xor bx, bx				;;Clear BX, this will hold the map's width
	mov cl, byte[si]		;;Grab the width

	inc si					;;Advance pointer into actual tile map
	pop bx
	call block_print

	popa
	ret

;Display an image in a frame...
;	SI - pointer to image struct
img_framed:
	pusha

	push si				;;Save the pointer from our danger code
	xor ax, ax
	xor cx, cx

	mov cl, byte [si]	;;Get size of tile pack
	mov al, 16			;;Calculate end of pack
	mul cl

	add si, ax			;;Advance pointer, we are not at the tile map

	inc si
	xor ax, ax
	mov al, byte [si]	;;Number of tiles in image

	inc si
	xor cx, cx
	mov cl, byte [si]	;;Width of image

	div cl				;;Divide num times / width => height
	mov ch, al

	call get_cursor_pos
	call gui_frame

	add bl, 1
	add bh, 1
	call set_cursor_pos

	pop si
	call img_display

	popa
	ret
