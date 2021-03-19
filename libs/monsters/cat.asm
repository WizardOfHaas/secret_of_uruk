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

dw 1	;;EXP
dw 15	;;HP
dw 0	;;AC
dw 0	;;PW

dw _monster_cat_handler
dw _monster_cat_handler

db 'the chonk', 0

_monster_cat_img:
%include "./img/lion.img"

;Monster Combat handler, ran each turn of combat
;	AL - event type to handle...
;		M: move (DI is monster table entry)
;		D: damaged
;		C: combat turn
;       R: player tries to run
_monster_cat_handler:
    mov byte [char_attr], 0x02

	cmp al, 'C'
	je .combat

	cmp al, 'D'
	je .damaged

	cmp al, 'M'
	je .move

    cmp al, 'R'
    je .run

    cmp al, 'T',
    je .talk

	jmp .done

.talk:
    mov si, .talk_msg
    call gui_print_combat_msg
    jmp .done

.combat:
	;;Decide on phys or magic attack
	call rnd
	cmp al, 0
	jg .cast

	mov si, .combat_msg
	call gui_print_combat_msg
	mov si, _monster_cat
	call monster_attack_phys
	jmp .done
.cast:
	mov si, .cast_msg
	call gui_print_combat_msg

	mov al, 0
	mov ah, 'M'
	call cast_magic
	jmp .done
.run:
	call rnd
	cmp al, 0x10
	jg .run_trapped

	clc			;;Clear carry, used to flat a failed run
	jmp .done
.run_trapped:
	mov si, .trapped_msg
	call gui_print_combat_msg
	stc
    jmp .done
.damaged:
.move:
	;call monster_move_chase
    call monster_move_rnd
.done:
    mov byte [char_attr], 0x07
	ret

	.combat_msg db 'IT SWIPES WITH CLAWS', 0
	.cast_msg db 'IT SPEAKS', 0
	.trapped_msg db 'YOU ARE TRAPPED', 0
    .talk_msg db 'im a cat lol', 0