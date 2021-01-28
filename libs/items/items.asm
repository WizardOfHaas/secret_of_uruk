	db 'items.asm'

%include "./libs/items/hp.asm"

items_table: times 256 dw 0

items_load:
	;;Load in the tile
	mov si, _item_hp
	call item_load_tile

	;;Add item to the table
	movzx bx, byte [si]
	mov ax, 2
	mul bx
	mov di, items_table
	add di, ax
	mov word [di], _item_hp

	;mov si, _item_hp
	;call print_regs

	ret

;	SI - tile to load
item_load_tile:
	pusha
	
	movzx dx, byte [si]
	inc si
	mov bp, si
	mov cx, 1
	call img_set_font

	popa
	ret

;Look for an item in our big 'ol table
;	AX - item number
;
;	SI - pointer to item, 0 if none found
item_lookup:	
	push bx
	push ax

	mov si, 0
	
	mov ah, 0
	mov bx, 2
	mul bx

	mov di, items_table
	add di, ax

	mov si, word [di]

	pop ax
	pop bx
	ret
