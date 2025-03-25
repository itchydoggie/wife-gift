all:
	avra main.asm && avrdude -c USBasp -p t2313 -U flash:w:main.hex:i
