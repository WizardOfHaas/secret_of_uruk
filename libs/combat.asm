	db 'combat.asm'

current_monster: dw 0
current_monster_hp: dw 0

;	SI - monster to fight with
combat_start:
	mov word [current_monster], si
	call gui_render_combat

	mov di, word [si]
	mov ax, word [di + 19]
	mov word [current_monster_hp], ax

	mov si, word [current_monster]
	call gui_render_monster_health
.test_loop:
    ;;Show the combat menu
    mov bl, 60
    mov bh, 7
    mov si, menu_combat_main
    call menu_start
	jmp .test_loop

	ret

combat_roll_dice:
	call rnd	;;Get a big random number

	mov ah, 0	;;Shift it so we get 0-F
	shr al, 4

	ret

;Attack the current monster
combat_attack:
	call combat_roll_dice			;;AX is our base damage
	call itoa
	call gui_print_combat_msg

	mov si, word [current_monster]
	call monster_take_damage

	mov si, word [current_monster]
	call gui_render_monster_health
	ret
