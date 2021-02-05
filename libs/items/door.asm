_item_door:
db 12
db 01100000b
db 01100000b
db 01100000b
db 01100000b
db 00110000b
db 00110000b
db 00110000b
db 00110000b
db 00110000b
db 00011000b
db 00011000b
db 00011000b
db 00011000b
db 00011000b
db 00011000b
db 00011000b

dw _item_door_handler

db 'THE DOOR PUSHES OPEN', 0

_item_door_handler:
	ret
