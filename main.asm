	org 0x7E00		;Same as boot sector's %ENTRY

	jmp short start	;Jump to startup

	db 'main.asm'

	_default_font: dw 0x0000, 0x0500

start:
	cli
	xor ax, ax		;make it zero
	mov ss, ax		;stack starts at 0
	mov sp, 0FFFFh	;star stack at end of segment
 	sti

	xor ax, ax
	mov al, 0x02
	int 10h

 	;Setup cursor and screen
 	;call cursor_on
 	call clear_screen

 	;Print booting message
 	mov si, boot_msg
 	call sprint

 	;Initialize memory manager
 	mov si, mm_msg
 	call sprint
 	call init_mm
 	call print_ok

	;Print out total memory detected
	mov ax, [total_mem]
	call iprint
	mov si, kb_msg
	call sprint

	;;Save over default font set
	push es
	mov ax, 0; word [_default_font]
	mov es, ax
	mov di, 0x0500 ;word [_default_font + 2]
	call img_save_font
	pop es

	mov bp, alert_frame
	mov cx, 7
	mov dx, 1
	call img_set_font

	call rnd_init	;;Seed up the random number generator

	;;Load up the starting map...
	mov si, test_map
	call gui_render_map
	call gui_update_fov

	;;Load the hud, print intro message, show stats
	call gui_render_hud
	mov si, hud_msg
	call gui_print_to_hud
	call gui_stats_to_hud

	;;Load item data and font tiles
	call items_load

	;;Lets try loading in a monster!
	call monsters_load

	mov bl, 40
	mov bh, 15
	call monster_add_to_map

	mov si, word [current_map]
	call gui_update_fov

	call player_display

	call monsters_render_to_map

	call gui_glyphs_to_hud

	;;Load keyboard ISR and start up buffer
	call init_keybd
end: ;;Enter the input loop...
	call player_keybd_handle

	jmp end

boot_msg: 		
    db "     ______               ____  _____", 10
   	db "    / ____/_  ______     / __ \/ ___/", 10
  	db "   / /_  / / / / __ \   / / / /\__ \------------Hobby-----", 10
	db "  / __/ / /_/ / / / /  / /_/ /___/ /----------Operating--", 10
	db " /_/    \__,_/_/ /_/   \____//____/------------System---", 10
	db 0, 0, 0

panic_msg:		db 'Kernel Panic!', 0
mm_msg:			db 'Init memory manager...   ', 0
kb_msg:			db 'kb detected', 10, 0
hud_msg:		db 'Welcome to the...    ', 'D A N G E R Z O N E!', 10, 0

%include "./libs/mem.asm"
%include "./libs/string.asm"
%include "./libs/tty.asm"
%include "./libs/serial.asm"
%include "./libs/img.asm"
%include "./libs/keybd.asm"
%include "./libs/gui.asm"
%include "./libs/player.asm"
%include "./libs/combat.asm"
%include "./libs/rnd.asm"
%include "./libs/magic.asm"
%include "./libs/monsters/monster.asm"

%include "./libs/items/items.asm"
%include "./libs/menus/menu.asm"

%include "./img/frame.img"
%include "./img/map.asm"

;	CX:DX - ms to wait
bios_wait:
	pusha
	mov al, 0
	mov ah, 86h
	int 15h
	popa
	ret

bios_print:
	pusha
    lodsb
    or al, al  ;zero=end of str
    jz .done    ;get out
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp bios_print

    .done:
	popa
    ret

bios_clear:			;Clear screen
	pusha
    mov dx,0
    pusha
    mov bh,0
    mov ah,2
    int 10h
    popa

    mov ah,6
    mov al,0
    mov bh, 02
    mov cx,0
    mov dh,24
    mov dl,79
    int 10h
    popa
	ret

kernel_panic:
	pusha
	mov byte [char_attr], 0x14
	mov si, panic_msg
	call sprint

	call new_line
	popa

	call print_regs

	call new_line
	mov ax, ss
	mov es, ax
	mov si, sp
	mov ax, 32
	call dump_mem

	cli
	hlt

start_free_mem:
