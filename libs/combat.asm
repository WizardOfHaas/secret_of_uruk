	db 'combat.asm'

current_monster_tab: dw 0
current_monster: dw 0
current_monster_hp: dw 0
current_monster_ac: dw 0

combat_status: db 0		;;Generic status for combat, for fancy async stuff

;;Table for scaling POW-based damage
combat_power_scale:
	
;	SI - monster table entry to fight with
combat_start:
	mov byte [combat_status], 1
	mov word [current_monster_tab], si

    mov ax, word [si + 4]
    mov word [current_monster], ax

	mov di, ax
    mov ax, word [di + 21]
    mov word [current_monster_ac], ax
	mov ax, word [di + 19]
	mov word [current_monster_hp], ax

	call gui_render_combat

.test_loop:
	cmp word [current_monster_hp], 0
	je .player_wins

	cmp byte [combat_status], 0
	je .bail_combat

	cmp word [_player_hp], 0
	je .player_dies

    ;;Show the combat menu
    mov bl, 60
    mov bh, 7
    mov si, menu_combat_main
    call menu_start

	xor cx, cx
	mov dx, 0x1000
	call bios_wait

	mov al, 'C'
	mov di, word [current_monster_tab]	;;This is a pointer to a pointer, so... **&& fun
	mov si, word [di + 4]
	call word [si + 25]

	call gui_render_monster_health
	call gui_stats_to_hud

	jmp .test_loop

.bail_combat:
	call combat_end
	jmp .done

.player_wins:
	;;Will need to...
	;;	let monster know it died
	;;	load back in main tileset for map
	;;	remove monster
	;;	handle cleanup
	;;	handle loot

	mov si, .win_msg
	call gui_print_combat_msg
	call keybd_wait

    mov si, word [current_monster_tab]

    ;;Get Monster XP
    mov di, word [si + 4]
    mov ax, word [di + 17]
    call player_add_xp

	call monster_remove_from_map

	call combat_end
	jmp .done

.player_dies:
	mov si, .msg
	call gui_print_combat_msg

.done:
	ret

	.msg db 'YOUR LIFE DRAWS TO A CLOSE', 0
	.win_msg db 'YOU LIVE, THIS TIME   ', 'PRESS A KEY TO CONTINUE...', 0

combat_end:
    mov si, test_map_font
    call img_load_font_pack

	call gui_render_map_screen
    call gui_stats_to_hud
	mov byte [combat_status], 0
	ret

combat_roll_dice:
	call rnd	;;Get a big random number

	mov ah, 0	;;Shift it so we get 0-F
	shr al, 4

	ret

;Try to run away...
combat_run:
    mov al, 'R'
    mov si, word [current_monster]
    call word [si + 25]
    ret

;Attack the current monster
combat_attack:
	call combat_roll_dice			;;AX is our base damage
    add ax, word [_player_pw]

	call itoa
	call gui_print_combat_msg

	mov si, word [current_monster]
	call monster_take_damage

	mov si, word [current_monster]
	call gui_render_monster_health
	ret

combat_cast_spell:
	ret
