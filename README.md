  ██████ ▓█████  ▄████▄   ██▀███  ▓█████▄▄▄█████▓     
▒██    ▒ ▓█   ▀ ▒██▀ ▀█  ▓██ ▒ ██▒▓█   ▀▓  ██▒ ▓▒     
░ ▓██▄   ▒███   ▒▓█    ▄ ▓██ ░▄█ ▒▒███  ▒ ▓██░ ▒░     
  ▒   ██▒▒▓█  ▄ ▒▓▓▄ ▄██▒▒██▀▀█▄  ▒▓█  ▄░ ▓██▓ ░      
▒██████▒▒░▒████▒▒ ▓███▀ ░░██▓ ▒██▒░▒████▒ ▒██▒ ░      
▒ ▒▓▒ ▒ ░░░ ▒░ ░░ ░▒ ▒  ░░ ▒▓ ░▒▓░░░ ▒░ ░ ▒ ░░        
░ ░▒  ░ ░ ░ ░  ░  ░  ▒     ░▒ ░ ▒░ ░ ░  ░   ░         
░  ░  ░     ░   ░          ░░   ░    ░    ░           
      ░     ░  ░░ ░         ░        ░  ░             
                ░                                     
 ▒█████    █████▒    █    ██  ██▀███   █    ██  ██ ▄█▀
▒██▒  ██▒▓██   ▒     ██  ▓██▒▓██ ▒ ██▒ ██  ▓██▒ ██▄█▒ 
▒██░  ██▒▒████ ░    ▓██  ▒██░▓██ ░▄█ ▒▓██  ▒██░▓███▄░ 
▒██   ██░░▓█▒  ░    ▓▓█  ░██░▒██▀▀█▄  ▓▓█  ░██░▓██ █▄ 
░ ████▓▒░░▒█░       ▒▒█████▓ ░██▓ ▒██▒▒▒█████▓ ▒██▒ █▄
░ ▒░▒░▒░  ▒ ░       ░▒▓▒ ▒ ▒ ░ ▒▓ ░▒▓░░▒▓▒ ▒ ▒ ▒ ▒▒ ▓▒
  ░ ▒ ▒░  ░         ░░▒░ ░ ░   ░▒ ░ ▒░░░▒░ ░ ░ ░ ░▒ ▒░
░ ░ ░ ▒   ░ ░        ░░░ ░ ░   ░░   ░  ░░░ ░ ░ ░ ░░ ░ 
    ░ ░                ░        ░        ░     ░  ░   
...this codebase is an absolute wrek...

Welcome to my very dangerous, convoluted, and complicated video game. Secret of Uruk is a rogue-like game with some weird twists and turns.

# Building/testing
Currently, Secret of Uruk supports three fun and wild dev envirometns: a physical serial-bridged hardware dev setup, qemu-i386, and dosdox. One of these is easier to use than the others... can you take a guess?

## Serial Bridge Env
The `/client/` directory holds a bootloader for my dev system. This is a really simple program, just bootsector that loads up the computer and waits for data over serial at 9600 baud. The low rate is just so this will work natively on older PC hardware. The install script is dangerous, it assumes you have a floppy drive on `/dev/sdb`. Change that as needed or you will be sorry. To get this part going you will...

	- `nasm boot.asm`
	- `sudo bash install.sh`

Then the other chunk of code in this directory is `send.py`, that just blits data in the right format over serial.

Then to build and run the game just...

	- `make serial-test`

That assumes you have a dev system booted up into the serial bootloader and connected via null modem.

## QEMU/DOSBox
The virtual enviroments are the main supported ones because, ya know, they are just easier to deal with. The DOSBox target just makes a COM file and executes it in DOSBox, while the QEMU target will generate a disk image that self-boots into Secret of Uruk. The DOSBox target is nice for simplicity, but sometimes it's nice to test without DOS overhead. The actual makefile I'm using here is really barebones, it's basically just a script, but it works. In the future I'm planning to add in support for auto-generating image resources but that nice wrapping will come once the actual code is working better.

For QEMU(you will need a loopback device setup, usually that's already done in linux):

    - `make qemu-test`

For DOSBox:

    - `make dos-test`

# Dev docs to follow...