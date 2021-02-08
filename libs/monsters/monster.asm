	db 'monster.asm'

%include "./libs/monsters/cat.asm"

monsters_table: times 256 dw 0

;;Struct table, each element as:
;;	x|y|hp|pointer -> 6 bytes wide
monsters_count: db 0
monsters_on_map: times 64 dw 0

monsters_load:
	mov si, _monster_cat
	call monster_add_to_table
	ret

;	SI - monster struct
monster_add_to_table:
	mov di, monsters_table
	movzx ax, byte [si] ;;Get char number
	mov bx, 2
	mul bx

	add di, ax
	mov word [di], si

	ret

;	SI - monster struct
;	BL - X
;	BH - y
monster_add_to_map:
	movzx ax, byte [monsters_count]
	mov cx, 6
	mul cx

	mov di, monsters_on_map
	add di, ax

	mov ax, word [si + 19]

	mov byte [di], bl		;;Set position
	mov byte [di + 1], bh
	mov word [di + 2], ax	;;Set HP
	mov word [di + 4], si	;;Set struct pointer
	
	inc byte [monsters_count]
	ret

;	SI - monster table entry
monster_remove_from_map:
	dec byte [monsters_count]
	ret

;Render monsters out to map
;	Also tells each monster to make a move...
monsters_render_to_map:
	pusha
	mov di, monsters_on_map
	movzx dx, byte [monsters_count]
	mov cx, 0
.loop:				;;Only works for 1 right now, will need a fix...
	cmp cx, dx
	jge .done

	mov ax, 6
	mul cx
	add di, ax

	push cx
	push dx

	mov si, word [di + 4]	;;Get pointed to struct
	movzx dx, byte [si]
	mov bp, si
	inc bp
	mov cx, 1
	
	call img_set_font

	;;Tell the monster to update it's position
	;mov bl, byte [di]		;;Get location of monster
	;mov bh, byte [di + 1]
	
	mov bx, word [di]
	mov al, 'M'
	call word [si + 25]
	mov bx, word [di]

	call set_cursor_pos

	mov al, byte [si]
	call cprint
	pop dx
	pop cx

	;cmp bx, word [player_pos]	;;Is it combat time?
	;je .combat

	inc cx
	jmp .loop
.combat:
	mov si, di
	call combat_start
.done:
	popa
	ret

;	DI - monster table entry
;	BX - prospective x/y location
monster_move:
	pusha
	push bx
	sub bl, 1
	sub bh, 7
	mov si, word [current_map]
	call gui_map_get_tile
	pop bx

	cmp al, '.'
	jne .done

	push bx
	mov bx, word [di]
	call set_cursor_pos
	mov al, '.'
	call cprint
	pop bx

	mov word [di], bx
.done:
	popa
	ret

;;Some pre-defined monster paths...
;Chase the player
monster_move_chase:
	cmp bl, byte [_player_x]
	jl .inc_x
	jg .dec_x

	cmp bh, byte [_player_y]
	jl .inc_y
	jg .dec_y

	jmp .done
.inc_x:
	inc bl
	jmp .done
.dec_x:
	dec bl
	jmp .done
.inc_y:
	inc bh
	jmp .done
.dec_y:
	dec bh
.done:
	call monster_move
	ret

;Check table for monster at char, return pointer to table entry
monster_lookup:
	push bx
	push ax

	mov ah, 0
	mov bx, 2
	mul bx

	mov si, monsters_table
	add si, ax

	pop ax
	pop bx
	ret

;	SI - monster
;	AX - how much to hurt the monster
monster_take_damage:
	mov di, si
	mov si, word [di]

	mov bx, word [current_monster_hp]

	cmp word [current_monster_hp], ax
	jl .dead

	sub word [current_monster_hp], ax

	jmp .done
.dead:
	mov word [current_monster_hp], 0
.done:
	ret

;	SI - monster
monster_attack_phys:
	call combat_roll_dice

	;;Need to adjust based on POW here...
	
	call itoa
	call gui_print_combat_msg

	call player_take_damage

	ret
