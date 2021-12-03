_monster_bird_man:
db 93           ;;Char code for monder's map tile
db 00000000b    ;;Font bitmap for map tile
db 00110000b
db 01001000b
db 10000100b
db 10000010b
db 01001111b
db 01001000b
db 00110000b
db 01001000b
db 10000100b
db 10000100b
db 01111000b
db 01001000b
db 01001000b
db 11001100b
db 00000000b

;;Then the stat block...
dw 3	        ;;EXP
dw 50	        ;;HP
dw 2	        ;;AC
dw 3	        ;;PW

;;Handler, right now this has to be twice, the second is reserved for later use
dw _monster_bird_man_handler
dw _monster_bird_man_handler

;;0-terminated name for this new monster
db 'half bird, half not', 0

;;Include an image struct here
_monster_bird_man_img:
%include "./img/bird_man.img"


;Monster Combat handler, this is called whenever the monster needs to do something:
;	AL - event type to handle...
;		M: move (DI is monster table entry)
;		D: damaged
;		C: combat turn
;       R: player tries to run
_monster_bird_man_handler:
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
    ;;Called when the player tries to talk
    jmp .done

.combat:
    ;;Called on the mosnter's turn each combat
    mov si, .combat_msg
    call gui_print_combat_msg

    mov si, _monster_cat
	call monster_attack_phys
	jmp .done

.run:
    ;;This is called when the player tries to run from combat
    ;;stc to let them run
    ;;clc to trap them
    clc
    jmp .done

.damaged:
    ;;Called when the monster is damaged by the player
    jmp .done

.move:
    ;;Called on each map refresh, use helper functions to move around the monster
    ;;ex: random walk
    call monster_move_chase
    
.done:
    mov byte [char_attr], 0x07
	ret

    .combat_msg db 'PECK PECK PECK', 0