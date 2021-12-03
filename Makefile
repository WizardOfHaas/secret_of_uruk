main : test.com
	nasm main.asm -o startup.bin -Wall

install : test.com
	mkdir -p ./mnt
	sudo mount boot.img ./mnt
	sudo cp startup.bin ./mnt
	sudo umount ./mnt

qemu-test : boot.img
	make
	make install
	qemu-system-i386 -fda boot.img -monitor stdio

dos-test :
	nasm main.asm -o test.com
	dosbox test.com

serial-test :
	nasm main.asm -o test.com
	python client/send.py test.com