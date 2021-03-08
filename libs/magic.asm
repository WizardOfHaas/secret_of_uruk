	db 'magic.asm'

;;Table of magical spells
;;	Formated as...
;;	incantation(5b)|0|handler(2b)
;;
;;	incantation name in lower case so it uses the glyph font set
;;
;;	magic handlers must return:
;;		BX - HP Cost
;;		AX - HP Damage
;;	Any other effects are dealt with in the handler itself
magic_spell_count: db 1
magic_table:
	db "enkku", 0
	dw _magic_quake

;Cast a spell from the magic table
;	AL - spell number
;	AH - who is casting? (M)onster/(P)layer
cast_magic:
	mov bl, 8
	mul bl

	mov bh, ah
	mov ah, 0

	mov si, magic_table
	add si, ax

	call gui_print_combat_msg

	mov ah, bh
	call word [si + 6]
	ret

;Lookup a spell by name
; Traverses spell table, looks for a hit
;	SI - name to find
;
;	AX - spell number, can use to cast
magic_lookup:
	movzx cx, byte [magic_spell_count]
	xor ax, ax
	mov di, magic_table

.loop:
	call strcmp
	jc .ok

	add di, 8

	inc ax
	cmp ax, cx
	jl .loop

	clc
	jmp .done

.ok:
	stc
.done:
	ret

;Handle payment...
;	BX - how much hp
;	AH - (M)onster/(P)layer
magic_pay_cost:
	pusha
	cmp ah, 'P'
	je .player

.monster:
	mov si, word [current_monster]
	mov ax, bx
	call monster_take_damage
	jmp .done
.player:
	mov ax, bx
	call player_take_damage
.done:
	popa
	ret

;;Simple spell, costs 5 HP, does 1 die to everyone
_magic_quake:
	mov si, .msg
	call gui_print_combat_msg

	mov bx, 5
	call magic_pay_cost
	
	call rnd
	shr ax, 14

	call player_take_damage
	mov si, word [current_monster]

	call monster_take_damage

	ret

	.msg db "THE GROUND CRACKLES", 0
