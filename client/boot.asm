; boot.asm
%define _ENTRY 0x100

	BITS 16
	ORG 0x7C00
    ;ORG 0x100

	jmp short bootloader_start	; Jump past disk description section
	nop				; Pad out before disk description

	OEMLabel		db "SERIBOOT"	; Disk label
	BytesPerSector		dw 512		; Bytes per sector
	SectorsPerCluster	db 1		; Sectors per cluster
	ReservedForBoot		dw 1		; Reserved sectors for boot record
	NumberOfFats		db 2		; Number of copies of the FAT
	RootDirEntries		dw 224		; Number of entries in root dir
					; (224 * 32 = 7168 = 14 sectors to read)
	LogicalSectors		dw 2880		; Number of logical sectors
	MediumByte		db 0F0h		; Medium descriptor byte
	SectorsPerFat		dw 9		; Sectors per FAT
	SectorsPerTrack		dw 18		; Sectors per track (36/cylinder)
	Sides			dw 2		; Number of sides/heads
	HiddenSectors		dd 0		; Number of hidden sectors
	LargeSectors		dd 0		; Number of LBA sectors
	DriveNo			dw 0		; Drive No: 0
	Signature		db 41		; Drive signature: 41 for floppy
	VolumeID		dd 00000000h	; Volume ID: any number
	VolumeLabel		db "SERIBOOT     "; Volume Label: any 11 chars
	FileSystem		db "FAT12   "	; File system type: don't change!

bootloader_start:
	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	sti

	mov si, intro
	call print

	mov ah, 0           ;Initialize opcode
	mov al, 11100011b   ;Parameter data. 9600 8N1
	mov dx, 0			;COM1: port.
	int 0x14

	mov si, nl
	call print

	;Now we wait for the signal
loop:
	call fetch_byte
	cmp al, ">"
	jne loop

	;Get payload size
	call fetch_byte
	mov byte [payload_size], al
	call fetch_byte
	mov byte [payload_size + 1], al

	mov ax, [payload_size]
	call itoa
	call print
	mov si, done_msg
	call print
	mov si, nl
	call print

	mov di, _ENTRY
	mov cx, 0

load:
	call fetch_byte

	test ah, 0x80
	jnz load

	pusha

	;mov ax, cx
	;call show_byte

	call htoa
	call print
	mov si, tab
	call print

	popa

	mov byte [di], al
	
	;cmp word [di - 1], '<<'
	;je jump

	inc di

	;Check if we were signaled to stop
	inc cx
	cmp cx, [payload_size]
	jl load

jump:
	mov si, nl
	call print

	mov ax, di
	xchg al, ah
	call htoa
	call print
	xchg al, ah
	call htoa
	call print

	mov si, mem_msg
	call print

	jmp _ENTRY

hang:
	hlt
	jmp hang

%include "./string.asm"

intro db 'Waiting for data on COM1', 13, 10, 0
done_msg db ' Bytes To Read', 13, 10, 0
mem_msg db ' End of payload', 13, 10, 0
label db 'Status: ', 13, 10, 0
nl db 13, 10, 0
tab db '  ', 0

payload_size dw 0, 0

fetch_byte:
	mov dx, 0
    mov ah, 2
    int 0x14

	test ah, 0x80
    jnz .done

	pusha
    mov dx, 0 ;Echo out for safety...and it breaks if I remove this...
    mov ah, 1
    int 0x14
	popa
.done:
	ret

show_byte:
	push ax
	;Get current position
	mov ah, 3
	mov bh, 0
	int 0x10
	pop ax
	
	push dx
	push ax

	;Move cursor to corner
	mov ah, 2
	mov bh, 0
	mov dh, 3
	mov dl, 70
	int 0x10

	pop ax
	;htoa and print
	call itoa
	call print

	;Move cursor back to starting position
	pop dx
	mov ah, 2
	mov bh, 0
	int 0x10

	ret	

print:
	lodsb
	or al, al  ;zero=end of str
	jz .done    ;get out
	mov ah, 0x0E
	mov bh, 0
	int 0x10
	jmp print
	.done:
	ret
 
    times 510-($-$$) db 0 ; 2 bytes less now
    db 0x55
    db 0xAA

buffer:
