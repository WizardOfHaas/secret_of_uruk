;;Just a generic dude
_monster_dude:
db 92           ;;Char code for monder's map tile
db 00000000b    ;;Font bitmap for map tile
db 01100011b
db 01100011b
db 00000000b
db 00001000b
db 00001000b
db 00000000b
db 00111110b
db 00100010b
db 00100010b
db 00111110b
db 00000000b
db 00111110b
db 00011100b
db 00001000b
db 00000000b

;;Then the stat block...
dw 1	        ;;EXP
dw 15	        ;;HP
dw 0	        ;;AC
dw 0	        ;;PW

;;Handler, right now this has to be twice, the second is reserved for later use
dw _monster_dude_handler
dw _monster_dude_handler

;;0-terminated name for this new monster
db 'just some dude', 0

;;Include an image struct here
_monster_dude_img:
%include "./img/dude.img"

;Monster Combat handler, this is called whenever the monster needs to do something:
;	AL - event type to handle...
;		M: move (DI is monster table entry)
;		D: damaged
;		C: combat turn
;       R: player tries to run
_monster_dude_handler:
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
    ;;We need to add a routine to clear the combat menu pane
    call gui_clear_combat_menu
    mov bl, 60
    mov bh, 7
    mov si, menu_dude_main
    call menu_start
    jmp .done

.combat:
    ;;Called on the mosnter's turn each combat
	jmp .done

.run:
    ;;This is called when the player tries to run from combat
    ;;clc to let them run
    ;;stc to trap them
    clc
    jmp .done

.damaged:
    ;;Called when the monster is damaged by the player
    jmp .done

.move:
    ;;Called on each map refresh, use helper functions to move around the monster
    ;;ex: random walk
    ;call monster_move_rnd
    
.done:
    mov byte [char_attr], 0x07
	ret

%include "./libs/menus/dude_menu.asm"