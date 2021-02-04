;;Item struct
;;Will need to include...
;;	Item char code
;;	Font tile
;;	Item event handler
;;	Item name

_monster_cat:
db 91
db 00000000b
db 10000001b
db 01000010b
db 00100100b
db 01100110b
db 01100110b
db 00000000b
db 10000001b
db 01000010b
db 00100100b
db 11111111b
db 00100100b
db 01000010b
db 10011001b
db 00100100b
db 00000000b

dw 1	;;LVL
dw 15	;;HP
dw 0	;;AC
dw 0	;;PW

dw _monster_cat_handler
dw _monster_cat_mover

db 'THE CHONK', 0

_monster_cat_img:
%include "./img/cat.img"

;Monster Combat handler, ran each turn of combat
;	AL - event type to handle...
;		M: move
;		D: damaged
;		C: combat turn
_monster_cat_handler:
	cmp al, 'C'
	je .combat

	cmp al, 'D'
	je .damaged

	jmp .done

.combat:
	mov si, .combat_msg
	call gui_print_combat_msg
	mov si, _monster_cat
	call monster_attack_phys
	jmp .done
.damaged:
.done:
	ret

	.combat_msg db 'IT SWIPES WITH CLAWS', 0

;Monster moving sub, ran each turn on map screen
_monster_cat_mover:
	ret
