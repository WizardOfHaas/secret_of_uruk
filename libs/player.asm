	db 'player.asm'

player_pos:
	_player_x: db 40
	_player_y: db 10

player_stats:
	_player_lv:	dw 1	;;Level
	_player_hp: dw 1	;;Health
	_player_ac: dw 0	;;Armor Class
	_player_pw:	dw 0	;;Power

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
    push bx
    mov bx, word [player_pos]
    call set_cursor_pos
    mov al, 46
    call cprint
    pop bx

	mov word [player_pos], bx
	call player_display

	cmp si, 0
	je .done

	cmp ah, 'I'
	je .item_hit

	cmp ah, 'M'
	je .monster_hit

	jmp .done

	;;Need to do logic to deal with monster/item differently
.item_hit:
	mov di, si	
	add si, 19
	call gui_print_to_hud

	call word [di + 17]

	call gui_stats_to_hud
	jmp .done
.monster_hit:
	mov di, si
	add si, 29
	call gui_print_to_hud

	call word [di + 25]
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
	cmp si, 0
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
