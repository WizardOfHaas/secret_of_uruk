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

db 'A LOCKED GATE', 0

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
.done:
	ret

    .msg db 'YOU UNLOCK THE GATE'
