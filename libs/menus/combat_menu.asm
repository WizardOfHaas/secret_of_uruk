menu_combat_main:
	db 4
	dw _option_combat_run
	dw _option_combat_attack
	dw _option_combat_talk
	dw _option_combat_magic

_option_combat_run:
	dw _option_combat_run_handler
	db 'RUN AWAY', 0
_option_combat_run_handler:
    call combat_run	;;Try to run
	jc .done		;;Did our adversary let us escape?

	mov byte [combat_status], 0

	;;Move the player, for safety and sanity
	mov ax, word [player_last_pos]
	mov word [player_pos], ax
.done:
	ret

_option_combat_attack:
	dw _option_combat_attack_handler
	db 'ATTACK', 0
_option_combat_attack_handler:
	mov si, .msg
	call gui_print_combat_msg
	call combat_attack
	ret

	.msg db 'SMASH!!', 0

_option_combat_talk:
	dw _option_combat_talk_handler
	db 'TALK', 0
_option_combat_talk_handler:
    mov al, 'T'
    mov si, word [current_monster]
    call word [si + 25]
	ret

_option_combat_magic:
	dw _option_combat_magic_handler
	db 'CAST', 0
_option_combat_magic_handler:
	mov si, .prompt
	mov di, .buffer
	call gui_combat_prompt

	mov si, di
	call magic_lookup
	jnc .fail

    mov ah, 'P'
	call cast_magic

	call itoa
	call gui_print_combat_msg
	jmp .done

.fail:
	mov si, .error
	call gui_print_combat_msg

.done:
	ret

	.prompt db 'SPEAK THE RUNES:', 0
	.error db 'NOTHING HAPPENS', 0
	.buffer times 20 db 0
