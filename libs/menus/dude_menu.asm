menu_dude_main:
    db 3
    dw _menu_option_dude_hello
    dw _menu_option_dude_trade
    dw _menu_option_dude_quit

_menu_option_dude_hello:
    dw _menu_option_dude_hello_handler
    db 'HELLO!', 0
_menu_option_dude_hello_handler:
    mov si, .msg
    call gui_print_combat_msg
    ret

    .msg db 'hark and howdy', 0

_menu_option_dude_trade:
    dw _menu_option_dude_trade_hander
    db 'TRADE?', 0
_menu_option_dude_trade_hander:
    mov si, .msg1
    call gui_print_combat_msg
    mov si, .msg2
    call menu_yes_no
    jnc .done

    ;;Check for glyphs, do the trade
    call player_has_any_glyph
    cmp si, 0
    je .no_glyph

    mov byte [si], '-'
    call gui_glyphs_to_hud

    add word [_player_hp], 10
    jmp .done

.no_glyph:
    mov si, .no_glyph_msg
    call gui_print_combat_msg

.done:
    ret

    .msg1 db 'i trade knowledge for life', 0
    .msg2 db 'give 1 glyph for 10 health?', 0
    .no_glyph_msg db 'you are unable to pay me', 0

_menu_option_dude_quit:
    dw _menu_option_dude_quit_handler
    db 'BYE', 0
_menu_option_dude_quit_handler:
    mov byte [combat_status], 0
    ret