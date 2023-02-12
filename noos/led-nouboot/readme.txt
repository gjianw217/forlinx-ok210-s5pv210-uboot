1 编译程序
make

2 编译加头程序
arm-linux-gcc -o addheader addheader.c

3 为程序加头
./addheader led.bin s5pv210.bin

3 烧写到SD卡
sh write2sd