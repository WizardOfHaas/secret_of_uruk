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
	mov si, .msg
	call gui_print_combat_msg
	ret

	.msg db 'REEEEEE', 0

_option_combat_magic:
	dw _option_combat_magic_handler
	db 'CAST', 0
_option_combat_magic_handler:
	ret
