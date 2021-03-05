    db 'map.asm'

%include "./libs/maps/test_maps.asm"

current_map: dw 0
current_map_id: db 0

;   SI - struct of map to load
map_load:
    push si
    ;;Load font pack
    mov si, test_map_font
    call img_load_font_pack

    ;;Clear FOV
    call map_clear_fov

    ;mov bl, 0
	;mov bh, 6
	;mov cl, 80
	;mov dx, 78*16
	;call block_clear
    pop si

    ;;Load up this map
    call map_load_monsters
    call map_fill_placeholders
    call gui_render_map

    ;;Make new field of view
    call gui_update_fov

    call player_display

    ;;Deal with monsters on old map
    ret

;   SI - map struct
map_load_monsters:
    pusha
    ;;Get size of monster table
    ;;  -> Move to current table count
    ;;memcpy monster table
    add si, 1249   ;;Push pointer up to monster data

    xor ax, ax
    mov al, byte [si]
    mov byte [monsters_count], al

    inc si

    mov bx, 6
    mul bx

    mov di, monsters_on_map

    call memcpy
    popa
    ret

map_clear_fov:
    pusha
    mov di, field_of_view
    mov ax, 1248
    mov bx, 0
    call memset
    popa
    ret

;Get the map struct from the overworld map -> map table -> struct address
;   BX - overworld coordinates
;
;   SI - map struct
map_fetch_from_table:
    push bx
    movzx ax, bh			;Get y cursor position
	movzx dx, byte [world_map_size]				;2 bytes (char/attrib)
	mul dx					;for 80 columns
	movzx bx, bl			;Get x cursor position
    add ax, bx

    mov cx, ax  ;;For debug purposes
    pop bx

    ;;Get ID of map
    mov di, world_map
    add di, ax
    movzx ax, byte [di]

	call print_regs

    ;;Refrence loaded maps table
    mov di, loaded_maps
    mov cx, 2
    mul cx
    add di, ax
    mov si, word [di]
    ret

;Basically a wrapper for cprint... for now...
;   AL - character to print
map_plot_tile:
    call cprint
    ret

;Replace "?" with a random tile, from weighted list
;  SI - map struct
map_fill_placeholders:
    pusha
.loop:
    mov al, byte [si]
    cmp al, 0
    je .done

    cmp al, '?' ;;Do we need to randomize?
    jne .next

    call rnd
    mov ah, 0
    shr al, 3
    mov di, map_random_tiles
    add di, ax
    mov al, byte [di]

    mov byte [si], al

.next:
    inc si
    jmp .loop

.done:
    popa
    ret

map_check_links:
    push bx
    push ax
    ;;Get us to the links table
    push bx
    mov si, word [current_map]
    add si, 1249

    movzx ax, byte [si]
    inc si

    mov bx, 6
    mul bx

    add si, ax
    pop bx

    movzx cx, byte [si] ;;Get size of table
    inc si
.loop:
    mov dx, word [si]
    cmp word [si], bx
    je .ok

    dec cx
    add si, 5
    cmp cx, 0
    jg .loop

    mov si, 0
    jmp .done
.ok:
    movzx ax, byte [si + 4]
    mov bx, 2
    mul bx
    mov di, loaded_maps
    add di, ax
    mov si, word [di]
.done:
    pop ax
    pop bx
    ret

;;32 sweet random tiles...
map_random_tiles:
    db 11, 11, 11, 11, 11, 11, 11, 11
    db 219,219,219,219,219,219,219,219
    db 219,219,219,219,219,219,219,219
    db "~","~","~","~","~","~","~","~"