CROSS_COMPILE?=arm-linux-gnueabi-
led.bin: start.o led.o
	${CROSS_COMPILE}ld -Ttext 0xD0020010 -o led.elf $^
	${CROSS_COMPILE}objcopy -O binary led.elf $@
	${CROSS_COMPILE}objdump -D led.elf > led.dis
	
led.o : led.S
	${CROSS_COMPILE}gcc -c $< -o $@
start.o : start.S
	${CROSS_COMPILE}gcc -c $< -o $@
	
clean:
	rm *.o *.elf *.bin *.dis


