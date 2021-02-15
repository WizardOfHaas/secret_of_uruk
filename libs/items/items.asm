	db 'items.asm'

%include "./libs/items/hp.asm"
%include "./libs/items/door.asm"
%include "./libs/items/glyphs.asm"

items_table: times 256 dw 0

items_load:
	mov si, _item_hp
	call item_register

	mov si, _item_door
	call item_register

	call items_load_glyphs
	ret

;Load up all glyph items
items_load_glyphs:
	mov si, _item_glyphs
	mov cx, 24

.loop:
	call item_register
	
	add si, 19
	call strlen
	inc si
	add si, ax

	dec cx
	cmp cx, 0
	jg .loop

	ret

;Register item!
;	SI - item to register
item_register:
	;;Load in the tile
	push si
	call item_load_tile

	;;Add item to the table
	movzx bx, byte [si]
	mov ax, 2
	mul bx
	mov di, items_table
	add di, ax
	pop si
	mov word [di], si
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

	xor si, si
	
	mov ah, 0
	mov bx, 2
	mul bx

	mov di, items_table
	add di, ax

	mov si, word [di]

	pop ax
	pop bx
	ret

;	BX - x/y location of item
item_remove_from_map:
	pusha
	mov al, '.'
	mov si, word [current_map]
	call gui_map_set_tile
	popa
	ret
