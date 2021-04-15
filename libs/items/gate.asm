_item_gate:
db 15
db 00111100b
db 00111100b
db 00111100b
db 00111100b
db 00111100b
db 00111100b
db 00111100b
db 00100100b
db 00100100b
db 00100100b
db 00111100b
db 00111100b
db 00111100b
db 00111100b
db 00111100b
db 00111100b

dw _item_gate_handler

db 'THE GATE YIELDS', 0

;   AL -    'U' if in 'use' context (stc to keep item, clc to remove after use)
;           'H' to check for 'hit'-ability (stc if player can step here, clc if solid)
_item_gate_handler:
    cmp al, 'H'
    je .key_check

    call item_remove_from_map
    clc
    jmp .done

.key_check:
    ;;Check if player has a key
    ;;If not, push player back
    ;;Otherwise remove gate
    mov al, _ITEM_KEY_CHAR
    call player_check_inventory
    jnc .unlocked

.locked:
    mov si, .locked_msg
    call gui_print_to_hud
    stc
    jmp .done

.unlocked:
    call player_remove_item
    clc

.done:
	ret

    .locked_msg db 'THE GATE IS LOCKED', 0
