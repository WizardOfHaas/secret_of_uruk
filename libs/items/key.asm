;;Item struct
;;Will need to include...
;;	Item char code
;;	Font tile
;;	Item event handler
;;	Item name

_item_key:
db 14
db 00000000b
db 01111110b
db 01000000b
db 01111000b
db 01111110b
db 01000000b
db 01000000b
db 01000000b
db 01000000b
db 01010000b
db 01101000b
db 01000100b
db 01000100b
db 01000100b
db 00101000b
db 00010000b

dw _item_key_handler

db 'SMALL CLAY KEY', 0

;   AL - 'U' if in 'use' context
_item_key_handler:
    cmp al, 'U'
    je .use

	call item_remove_from_map

    mov si, _item_key
    call player_add_to_inventory
    jmp .done
    
.use:
    mov si, .msg
    call gui_print_to_hud
    clc                     ;;Clear carry to "clear" out item, would stc to keep it after use
.done:
	ret

    .msg db 'AYYYLMAFO'
