    db 'map.asm'

%include "./libs/maps/test_maps.asm"

current_map: dw 0
current_map_id: db 0

map_load:
    mov si, test_map_font
    call img_load_font_pack
    ret

;Get the map struct from the overworld map -> map table -> struct address
;   BX - overworld coordinates
map_fetch_from_table:
    movzx ax, bh			;Get y cursor position
	movzx dx, byte [world_map_size]				;2 bytes (char/attrib)
	mul dx					;for 80 columns
	movzx bx, bl			;Get x cursor position
    add ax, bx
    call print_regs
    ret