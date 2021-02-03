menu_combat_main:
	db 2
	dw _option_run
	dw _option_attack

_option_run:
	dw _option_run_handler
	db 'Run Away', 0
_option_run_handler:
	ret

_option_attack:
	dw _option_attack_handler
	db 'Attack', 0
_option_attack_handler:
	mov si, .msg
	call gui_print_combat_msg
	call combat_attack
	ret

	.msg db 'Here come the fists!', 0
