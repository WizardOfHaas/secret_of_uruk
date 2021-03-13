	db 'snd.asm'

;;Look here when I get back to sound
;;	https://github.com/leonardo-ono/Assembly8086PlayPcmDigitizedSoundOnPCSpeakerTest/blob/master/pwm.asm
;;	https://bumbershootsoft.wordpress.com/2016/12/10/beyond-beep-boop-mastering-the-pc-speaker/
;;      -->> https://github.com/michaelcmartin/bumbershoot/blob/master/dos/sound/1bitdac.asm

;   AX - tone # -> int(1193181 / freq)
;   BX - duration in "ticks"
snd_tone:
    pusha
    push bx
    call    speaker_on       ; Play the tone
    pop bx

    call    wait_ticks

    call    speaker_off      ; followed by 35 ms of silence
    popa
    ret

;;; waitTicks - Waits for BX ticks of the 18.2 Hz system timer.
;;; Trashes AX, BX, and DX.
wait_ticks:
    xor     ax, ax          ; Get tick count
    int     0x1a
    add     bx, dx          ; Add BX to it to get target
.lp:    
    xor     ax, ax          ; ... then spin until it matches
    int     0x1a
    cmp     dx, bx
    jne     .lp
    ret

speaker_off:
    in      al, 0x61
    and     al, 0xfc
    out     0x61, al
    ret

speaker_on:
    and     ax, 0xfffe
    push    ax
    cli
    mov     al, 0xb6
    out     0x43, al
    pop     ax
    out     0x42, al
    mov     al, ah
    out     0x42, al
    in      al, 0x61
    mov     al, ah
    or      al, 3
    out     0x61, al
    sti
    ret

;White noise generator
;	CX - number samples to generate and play
snd_noise:
	mov bx, 1
.loop:
	call rnd
	call snd_tone

	dec cx
	cmp cx, 0
	jg .loop
	ret

;   SI - sample to play
snd_play_fx:
    pusha
    mov bx, 64
    xor cx, cx
    mov dx, 100

.loop:
    mov ax, word [si]
    call snd_tone
    add si, 2

    dec bx
    cmp bx, 0
    jg .loop

    popa
    ret

snd_fx:
    .smash times 64 dw 0, 100