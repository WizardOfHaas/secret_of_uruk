;;Item struct
;;Will need to include...
;;	Item char code
;;	Font tile
;;	Item event handler
;;	Item name

_item_hp:
db 11
db 11111111b
db 10000001b
db 10000001b
db 00000000b
db 00011000b
db 00011000b
db 00011000b
db 01111110b
db 01111110b
db 00011000b
db 00011000b
db 00011000b
db 00000000b
db 10000001b
db 10000001b
db 11111111b

dw _item_hp_handler

db 'Health Pack', 0

_item_hp_handler:
	add word [_player_hp], 10
	ret
