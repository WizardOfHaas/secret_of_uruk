%define _ITEM_KEY_CHAR 14

_item_key:
db _ITEM_KEY_CHAR
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

    cmp al, 'H'
    je .hit

	call item_remove_from_map

    mov si, _item_key
    call player_add_to_inventory
    jmp .done
    
.use:
    mov si, .msg
    call gui_print_to_hud
    stc                     ;;Clear carry to "clear" out item, would stc to keep it after use
    jmp .done
.hit:
    clc
.done:
	ret

    .msg db 'AYYYLMAFO'
