;;Item struct
;;Will need to include...
;;	Item char code
;;	Font tile
;;	Item event handler
;;	Item name

_monster_cat:
db 91
db 00000000b
db 10000001b
db 01000010b
db 00100100b
db 01100110b
db 01100110b
db 00000000b
db 10000001b
db 01000010b
db 00100100b
db 11111111b
db 00100100b
db 01000010b
db 10011001b
db 00100100b
db 00000000b

dw 1	;;LVL
dw 1	;;HP
dw 0	;;AC
dw 0	;;PW

dw _monster_cat_handler
dw _monster_cat_mover

db 'THE CHONK', 0

%include "./img/cat.img"


_monster_cat_handler:
	ret

_monster_cat_mover:
	ret
