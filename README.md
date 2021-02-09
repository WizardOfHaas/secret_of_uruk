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
Right now the test env for Secret of Urdu is a little specific to my setup. I have a machine I've been using as a homespun x86 dev box. Eventually this will be transitioned to a virtualized enviroment. Until then... well... I'm assuming any testing will be done using my setup.

## Serial Boot Client
The `/client/` directory holds a bootloader for my dev system. This is a really simple program, just bootsector that loads up the computer and waits for data over serial at 9600 baud. The low rate is just so this will work natively on older PC hardware. The install script is dangerous, it assumes you have a floppy drive on `/dev/sdb`. Change that as needed or you will be sorry. To get this part going you will...

	- `nasm boot.asm`
	- `sudo bash install.sh`

Then the other chunk of code in this directory is `send.py`, that just blits data in the right format over serial.

## Game Engine
Just...

	- `nasm main.asm`
	- `python client/send.py main`

That assumes you have a dev system booted up into the serial bootloader and connected via null modem.
