	db 'rnd.asm'

_rnd_seed: dw 0

rnd_init:
	mov ah, 00h   ; interrupt to get system timer in CX:DX 
	int 1Ah
	mov word [_rnd_seed], dx
	ret

;Get a random number between 0x0000 - 0xFFFF
;	AX - your new random word
rnd:
    mov ax, 25173          ; LCG Multiplier
    mul word [_rnd_seed]     ; DX:AX = LCG multiplier * seed
    add ax, 13849          ; Add LCG increment value
    ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
    mov [_rnd_seed], ax          ; Update seed = return value	
	ret

;;Map biome tables
;Desert
;Scrub
;Marsh
;Ruins

;The biggie: somehow make random maps....
;   1) Select set of tiles/items/monsters from biome table
;   2) Randomize grid in some reasonable pattern, must be:
;       - Traversable
;       - Interesting
;   3) Do we have a prebuilt section in this grid? If so, load it.
rnd_generate_map:
    ret