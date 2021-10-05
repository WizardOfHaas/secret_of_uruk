;;Need something for defining context in larger map
;;map's N/S/E/W neighbors
;;  if they are a file or a generated map
;;...or some other data structure for defining the world map

;;Other option: overworld map as grid
;;  Each location -> 1 word cell ID
;;  Random areas filled in via placeholder chars on cell maps
;;  Will need to track width of overworld map(assume square), player location
world_map_size: db 8
world_map:
db 1, 0, 0, 0, 0 ,0, 0, 0
db 3, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0

loaded_maps:
dw rand_map
dw test_map
dw test_dungeon
dw test_town
dw tunnel_1

test_map_font:
db 2
db 219
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b
db 11111111b

db 220
db 00000000b
db 01111110b
db 01000010b
db 01000010b
db 01000010b
db 01000010b
db 01000010b
db 01000010b
db 01000010b
db 01000010b
db 01000010b
db 01011010b
db 01011010b
db 01000010b
db 01111110b
db 00000000b

test_town: ;;Map ID 3
%include "./libs/maps/test_town.asm"
.monster_count: db 0
.link_count: db 0

tunnel_1: ;;Map ID 4
%include "./libs/maps/tunnel_1.asm"
.monster_count: db 2
.monsters:
    db 35, 14
    dw 15, _monster_cat
    
    db 60, 13
    dw 50, _monster_bird_man

.link_count: db 3
;;  source_x|y|target_x|y|target_map_id
.links: db 12, 14, 63, 16, 2
        db 52, 14, 56, 14, 4
        db 56, 14, 52, 14, 4

test_map: ;;Map ID 2
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,012,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,219,219
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,012,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219
db 046,219,219,219,219,012,219,219,219,012,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,219,219,219
db 046,219,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,219,219,219
db 046,219,046,046,101,046,046,219,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219
db 046,219,220,046,046,097,099,219,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219
db 046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,015,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,014,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 0

;;Monsters for this map
.monsters_count: db 3
;;  x|y|hp|pointer -> 6 bytes wide
.monsters:
db 16, 16
dw 15, _monster_cat

db 40, 15
dw 15, _monster_cat

db 45, 16
dw 15, _monster_dude

;;Internal linkages to other maps
.links_count: db 1
;;  source_x|y|target_x|y|target_map_id -> 5 bytes (oof)
.links: db 3, 16, 3, 16, 2

rand_map:
db  46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db 219,219,219,219,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db 219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,"?","?","?", 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,219,219,219,219, 46, 46, 46, 46, 46
db 219,219, 46,219,219,219, 46, 46, 46, 46, 46, 46, 46, 46,"?","?","?", 46, 46, 46, 46, 46, 11, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,219, 46, 46,219, 46, 46, 46, 46, 46
db  46, 46, 46,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,219, 46, 46,219, 46, 46, 46, 46, 46
db 219,219, 46,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,219, 46, 46, 12, 46, 46, 46, 46, 46
db 219,219, 46,219,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,219, 46, 46,219, 46, 46, 46, 46, 46
db 219,219, 46, 46, 46,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,219, 46, 46,219, 46, 46, 46, 46, 46
db 219,219,219,219, 46,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46,219,219,219,219, 46, 46, 46, 46, 46
db 219, 94, 94,219, 46,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db 219, 94, 94,219, 46, 46,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db 219, 94, 94,219, 46, 46, 46,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db 219, 94,219, 46, 46, 46, 46, 46,"?", 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db 219,219, 46, 46,219,219,219,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db  98, 99, 46, 46,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db  11, 97, 46,219,219, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46, 46
db 0
.monsters_count: db 0
.links_count: db 0

test_dungeon:
db 109,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,046,046,046,046,046,046,046,046,046,046,046
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,097,046,046,046,046,046,046,046,046,046,046,122,046,046,046,046,046,046,046,219,219,046,046,046,046,046,046,046,046,046,046,046
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,046,046,046,046,046,046,046,046,046,046,046
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,046,046,046,046,046,046,046,046,046,046,046
db 046,219,046,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,098,118,046,046,046,046,046,046,104,046,046,046,219,219,046,046,046,046,046,046,046,046,046,046,046,046
db 046,219,220,046,046,046,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,219,046,046,046,046,046,046,046,046,046,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,220,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046
db 046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046,046
db 0
.monsters_count: db 0
.links_count: db 2
.links: db 3, 16, 3, 16, 1
        db 63,16,12, 14, 4
