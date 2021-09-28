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
    

.done:
    ret

    .msg1 db 'i trade knowledge for life', 0
    .msg2 db '1 glyph for 10 health?', 0

_menu_option_dude_quit:
    dw _menu_option_dude_quit_handler
    db 'BYE', 0
_menu_option_dude_quit_handler:
    mov byte [combat_status], 0
    ret