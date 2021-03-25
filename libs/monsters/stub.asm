;;Stub for a new kind of monster!

_monster_stub:
db 92           ;;Char code for monder's map tile
db 00000000b    ;;Font bitmap for map tile
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

;;Then the stat block...
dw 1	        ;;EXP
dw 15	        ;;HP
dw 0	        ;;AC
dw 0	        ;;PW

;;Handler, right now this has to be twice, the second is reserved for later use
dw _monster_stub
dw _monster_stub

;;0-terminated name for this new monster
db 'i have no name yet', 0

;;Include an image struct here
_monster_stub_img:
;;ex: %include "./img/lion.img"


;Monster Combat handler, this is called whenever the monster needs to do something:
;	AL - event type to handle...
;		M: move (DI is monster table entry)
;		D: damaged
;		C: combat turn
;       R: player tries to run
_monster_stub:
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
	jmp .done

.run:
    ;;This is called when the player tries to run from combat
    ;;stc to let them run
    ;;clc to trap them
    jmp .done

.damaged:
    ;;Called when the monster is damaged by the player
    jmp .done

.move:
    ;;Called on each map refresh, use helper functions to move around the monster
    ;;ex: random walk
    call monster_move_rnd
    
.done:
    mov byte [char_attr], 0x07
	ret