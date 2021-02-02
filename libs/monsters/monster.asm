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

monster_remove_from_map:
	ret

;Render monsters out to map
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
	mov bl, byte [di]		;;Get location of monster
	mov bh, byte [di + 1]
	call set_cursor_pos
	
	mov si, word [di + 4]	;;Get pointed to struct
	movzx dx, byte [si]
	mov bp, si
	inc bp
	mov cx, 1
	
	call img_set_font

	mov al, byte [si]
	call cprint
	pop dx
	pop cx

	inc cx
	jmp .loop
.done:
	popa
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
