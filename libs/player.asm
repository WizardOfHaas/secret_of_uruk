	db 'player.asm'

player_map_cell: dw 0

player_last_pos: dw 0

player_pos:
	_player_x: db 40
	_player_y: db 19

player_stats:
	_player_xp:	dw 1	;;EXP
	_player_hp: dw 100	;;Health
	_player_ac: dw 1	;;Armor Class, subtracted from damage
	_player_pw:	dw 1	;;Power

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

    ;;Need to add edge detection
    mov ah, 'E'     ;Exit East...
    cmp bl, 78
    jg .left_map

    mov ah, 'W'
    cmp bl, 0
    je .left_map

    mov ah, 'S'
    cmp bh, 23
    jge .left_map

    mov ah, 'N'
    cmp bh, 7
    jl .left_map

	call player_check_move
	jc .done

.disp:
	push ax
    push bx
    mov bx, word [player_pos]
	mov word [player_last_pos], bx
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

    cmp ah, 'L'
    je .link_hit

	jmp .next_turn

	;;Need to do logic to deal with monster/item differently
.left_map:
    call player_move_to_map
    jmp .done
.link_hit:
    call map_load
    jmp .done
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
    cmp word [si + 2], 0
    je .done

	push si
	mov di, word [si + 4]
	add di, 29
	mov si, di
	call gui_print_to_hud
	pop si

	call combat_start
.next_turn:
.done:
	ret

;Move to the next map...
;   AH - Direction player is trying to go: N/S/E/W
player_move_to_map:
    ;Figure out where the player is attempting to move to
    ;Is this a valid map? Are we at an edge?
    ;Grab the map ID
    ;Refrence the map table for map ID -> address(later will be file name)
    ;Load up the new map
    ;Adjust player world map and local map locations
    mov bx, word [player_map_cell] ;;BL -> X, BH -> Y
    mov cx, word [player_pos]

    cmp ah, 'N'
    je .north

    cmp ah, 'S'
    je .south

    cmp ah, 'E'
    je .east

    cmp ah, 'W'
    je .west

    jmp .done

.north:
    dec bh
    mov ch, 22
    jmp .check
.south:
    inc bh
    mov ch, 7
    jmp .check
.east:
    inc bl
    mov cl, 1
    jmp .check
.west:
    dec bl
    mov cl, 78

.check:
    cmp bl, byte [world_map_size]
    jg .done

    cmp bl, 0
    jl .done

    cmp bh, byte [world_map_size]
    jg .done

    cmp bh, 0
    jl .done

    mov word [player_map_cell], bx
    mov word [player_pos], cx

    call map_fetch_from_table
    call map_load

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

    ;;Add in check for a map link
    mov ah, 'L'
    
    call map_check_links
    cmp si, 0
    jne .ok

	mov ah, 'I' ;;Mark as item

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

;Need to implement magic vs physical damage, AC will only affect phys damage
;	AX - how much it hurts
player_take_damage:
    ;Sub off armor class
    sub ax, word [_player_ac]

	cmp word [_player_hp], ax
	jl .dead

	sub word [_player_hp], ax

	jmp .done
.dead:
	mov word [_player_hp], 0
.done:
	ret

;Handle player losing XP, either for damage or payment. Keep it from rolling over...
; sets carry flag if XP is too low
;   AX - how much XP to lose
player_lose_xp:
    cmp word [_player_xp], ax
    jl .fail

    sub word [_player_xp], ax
    clc
    jmp .done

.fail:
    stc
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

	call gui_glyphs_to_hud
	pop bx
	ret

;Turn a string of glyphs into letters
;	SI - the CURSED STRING, it will be PARTLY UNCURSED
player_decode_glyph_string:
	pusha
	mov di, .tmp

.loop:
	mov al, byte [si]
	cmp al, 0
	je .done

	call player_decode_glyph
	mov byte [di], al

	inc si
	inc di
	jmp .loop

.done:
	popa

	mov si, .tmp
	ret

	.tmp times 32 db 0

;Decode a single glyph
;	AL - char code of glyph
player_decode_glyph:
	push si
	push bx
	;;Check if the player has found the glyph
	xor bx, bx
	mov bl, al
	sub bl, 97				;;Shift this down so we cah use AL as a table id

	mov si, player_glyphs	;;Grab the list of known glyphs
	add si, bx				;;Do we know this one?

	cmp byte [si], '-'		;;Check if this is a placeholder
	je .done

	sub al, 32				;;Shift over to UPPER CASE LETTERS, which are left unmodified
.done:
	pop bx
	pop si
	ret

;   AX - XP to add
player_add_xp:
    add word [_player_xp], ax
    ret
