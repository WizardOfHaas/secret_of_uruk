	db 'player.asm'

player_pos:
	_player_x: db 40
	_player_y: db 19

player_stats:
	_player_lv:	dw 1	;;Level
	_player_hp: dw 100	;;Health
	_player_ac: dw 0	;;Armor Class
	_player_pw:	dw 0	;;Power

player_glyphs: times 26 db '-'
	db 0

;Deal with keyboard inputs on map screen
player_keybd_handle:
    call keybd_read_char    ;;Fetch the latest key press off our buffer
    cmp al, 0               ;;Bail if we didn't get anything
    je .done

    ;;Lets try moving around the screen...
    mov bx, word [player_pos];;Get current player position

    cmp al, 'w'
    je .up

    cmp al, 'a'
    je .left

    cmp al, 's'
    je .down

    cmp al, 'd'
    je .right
    jmp end

.up:
    dec bh
    jmp .check
.down:
    inc bh
    jmp .check
.left:
    dec bl
    jmp .check
.right:
    inc bl

.check:
    ;;Is thi s new position valid?
    cmp bh, 25
    jge .done

    cmp bl, 80
    jge .done

	call player_check_move
	jc .done

.disp:
	push ax
    push bx
    mov bx, word [player_pos]
    call set_cursor_pos
    mov al, 46
    call cprint
    pop bx
		
	mov word [player_pos], bx

	push si
	mov si, word [current_map]
	call gui_update_fov
	pop si

	call player_display

    call monsters_render_to_map
	pop ax

	cmp si, 0
	je .done

	cmp ah, 'I'
	je .item_hit

	cmp ah, 'M'
	je .monster_hit

	jmp .next_turn

	;;Need to do logic to deal with monster/item differently
.item_hit:
	mov di, si	
	add si, 19
	call gui_print_to_hud

	mov bx, word [player_pos]
	sub bl, 1
	sub bh, 7
	call word [di + 17]

	call gui_stats_to_hud
	jmp .done
.monster_hit:
	push si
	mov di, word [si]
	add di, 29
	mov si, di
	call gui_print_to_hud
	pop si

	call combat_start
.next_turn:
.done:
	ret

;Check if new space is clear, item, or enemy
;	BX - new x/y position of player
;	Sets carry on collision
;	SI - item/entity handler, if found
player_check_move:
	call get_char_at
	xor si, si

	cmp al, 46
	je .ok

	mov ah,'I' ;;Mark as item

	call item_lookup
	cmp si, 0
	jne .ok

	mov ah, 'M'	;;Mark as monster

	call monster_lookup
	cmp word [si], 0
	jne .ok

	stc
	jmp .done
.ok:
	clc
.done:
	ret

player_display:
	push bx
	mov bx, word [player_pos]
	call set_cursor_pos
	mov al, '@'
	call cprint
	pop bx
	ret

;	AX - how much it hurts
player_take_damage:
	cmp word [_player_hp], ax
	jl .dead

	sub word [_player_hp], ax

	jmp .done
.dead:
	mov word [_player_hp], 0
.done:
	ret

;We got a new glyph!
;	AL - glyph char code
player_add_glyph:
	push bx
	xor bx, bx
	mov bl, al
	sub bl, 97

	mov si, player_glyphs
	add si, bx
	mov byte [si], al

	call print_regs

	call gui_glyphs_to_hud
	pop bx
	ret
