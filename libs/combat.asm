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
	cmp word [current_monster_hp], 0
	je .player_wins

	cmp word [_player_hp], 0
	je .player_dies

    ;;Show the combat menu
    mov bl, 60
    mov bh, 7
    mov si, menu_combat_main
    call menu_start

	mov al, 'C'
	call word [si + 25]

	jmp .test_loop
.player_wins:
	;;Will need to...
	;;	let monster know it died
	;;	load back in main tileset for map
	;;	remove monster
	;;	handle cleanup
	;;	handle loot

	push es
	mov ax, 0 ;word [_default_font]
	mov es, ax
	mov bp, 0x0500 ;word [_default_font + 2]
	mov di, bp

	xor dx, dx
	mov cx, 512
	;call img_set_font
	pop es

	call gui_render_map_screen
	jmp .done
.player_dies:
	mov si, .msg
	call gui_print_combat_msg
.done:
	ret

	.msg db 'lol, ded', 0

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
