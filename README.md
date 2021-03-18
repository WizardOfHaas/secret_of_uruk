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

Welcome to my very dangerous, convoluted, and complicated video game. Secret of Uruk is a rogue-like game with some weird twists and turns, planned to be set in the ancient state of Uruk.

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

# The tricks at play
Secret of Uruk pulls some tricks to keep execution fast and generate unexpected graphics. Here is a sample:

## Aggresive Font Swapping
Fun fact: the IBM PC supports multiple fonts, you just have to load them up. This game makes use of that by packing image resources as font tiles, thus allowing for fancy font-mode graphics. Right now this is in use for custom tiles aswell as full images in combat. We have 256 tiles to play with on screen at any one time, so we can do some fun stuff.

# Data Structures - What the Engine Renders
Currently procedural generation isn't fully implemented(that comes later). Instead the game engine renders out a set of pre-defined maps, tiles, items, monsters, and images. This is how they are all packed together.

## Images
Graphical researouces are one of the more fun hacks in Secret of Uruk, in my opinion. Each image structure consists of a pack of font tiles and a map specifying how to arrange those tiles. Currently images can use up to 128 unique tiles. The font pack is loaded into the upper block of ASCII so that we can keep normal printable characters avialable for use. All dimensions are specified in terms of characters. The final part of the payload, the image map, refrences font tiles in the pack by ID. So a 0 in the image map corresponds to the first tile defined in the font pack.

An full image struct is packed as:

+--------------------------+
| Number of tiles (1 byte) |
+--------------------------+
| Font tile 0 (16 bytes)   |
|  represented as a bitmap |
+--------------------------+
    ....
+--------------------------+
| Font tile N              |
+--------------------------+
| Number of tiles in image |
|  (1 byte)                |
+--------------------------+
| Width of image (1 byte)  |
+--------------------------+
| Image tile 0 (1 byte)    |
+--------------------------+
    ....
+--------------------------+
| Image tile N             |
+--------------------------+

# Dev docs to follow...