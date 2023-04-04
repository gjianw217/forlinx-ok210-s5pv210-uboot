/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Memory Setup stuff - taken from blob memsetup.S
 *
 * Copyright (C) 2009 Samsung Electronics
 * Kyungmin Park <kyungmin.park@samsung.com>
 */

#include <config.h>
#include <asm/arch/cpu.h>
#include <asm/arch/clock.h>
#include <asm/arch/power.h>

/*
 * Register usages:
 *
 * r5 has zero always
 * r7 has S5PC100 GPIO base, 0xE0300000
 * r8 has real GPIO base, 0xE0300000, 0xE0200000 at S5PC100, S5PC110 repectively
 * r9 has Mobile DDR size, 1 means 1GiB, 2 means 2GiB and so on
 */

	.globl lowlevel_init
lowlevel_init:
	mov	r11, lr

	/* r5 has always zero */
	mov	r5, #0

	ldr	r7, =S5PC100_GPIO_BASE
	ldr	r8, =S5PC100_GPIO_BASE
	/* Read CPU ID */
	ldr	r2, =S5PC110_PRO_ID
	ldr	r0, [r2]
	mov	r1, #0x00010000
	and	r0, r0, r1
	cmp	r0, r5
	beq	100f
	ldr	r8, =S5PC110_GPIO_BASE
100:
	/* Turn on KEY_LED_ON [GPJ4(1)] XMSMWEN */
	cmp	r7, r8
	beq	skip_check_didle			@ Support C110 only

	ldr	r0, =S5PC110_RST_STAT
	ldr	r1, [r0]
	and	r1, r1, #0x000D0000
	cmp	r1, #(0x1 << 19)			@ DEEPIDLE_WAKEUP
	beq	didle_wakeup
	cmp	r7, r8

skip_check_didle:
	addeq	r0, r8, #0xC40				@ S5PC100_GPIO_J4
	addne	r0, r8, #0xC40				@ S5PC110_GPIO_J4
	ldr	r1, [r0, #0x0]				@ GPIO_CON_OFFSET
	bic	r1, r1, #(0xf << 4)			@ 1 * 4-bit
	orr	r1, r1, #(0x1 << 4)
	str	r1, [r0, #0x0]				@ GPIO_CON_OFFSET

	ldr	r1, [r0, #0x4]				@ GPIO_DAT_OFFSET
	bic	r1, r1, #(1 << 1)
	str	r1, [r0, #0x4]				@ GPIO_DAT_OFFSET

	/* Don't setup at s5pc100 */
	beq	100f

	/*
	 * Initialize Async Register Setting for EVT1
	 * Because we are setting EVT1 as the default value of EVT0,
	 * setting EVT0 as well does not make things worse.
	 * Thus, for the simplicity, we set for EVT0, too
	 *
	 * The "Async Registers" are:
	 *	0xE0F0_0000
	 *	0xE1F0_0000
	 *	0xF180_0000
	 *	0xF190_0000
	 *	0xF1A0_0000
	 *	0xF1B0_0000
	 *	0xF1C0_0000
	 *	0xF1D0_0000
	 *	0xF1E0_0000
	 *	0xF1F0_0000
	 *	0xFAF0_0000
	 */
	ldr     r0, =0xe0f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xe1f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1800000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1900000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1a00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1b00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1c00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1d00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1e00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xfaf00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	/*
	 * Diable ABB block to reduce sleep current at low temperature
	 * Note that it's hidden register setup don't modify it
	 */
	ldr	r0, =0xE010C300
	ldr	r1, =0x00800000
	str	r1, [r0]

100:
	/* IO retension release */
	ldreq	r0, =S5PC100_OTHERS			@ 0xE0108200
	ldrne	r0, =S5PC110_OTHERS			@ 0xE010E000
	ldr	r1, [r0]
	ldreq	r2, =(1 << 31)				@ IO_RET_REL
	ldrne	r2, =((1 << 31) | (1 << 30) | (1 << 29) | (1 << 28))
	orr	r1, r1, r2
	/* Do not release retention here for S5PC110 */
	streq	r1, [r0]

	/* Disable Watchdog */
	ldreq	r0, =S5PC100_WATCHDOG_BASE		@ 0xEA200000
	ldrne	r0, =S5PC110_WATCHDOG_BASE		@ 0xE2700000
	str	r5, [r0]

	/* setting SRAM */
	ldreq	r0, =S5PC100_SROMC_BASE
	ldrne	r0, =S5PC110_SROMC_BASE
	ldr	r1, =0x9
	str	r1, [r0]

	/* S5PC100 has 3 groups of interrupt sources */
	ldreq	r0, =S5PC100_VIC0_BASE			@ 0xE4000000
	ldrne	r0, =S5PC110_VIC0_BASE			@ 0xF2000000
	add	r1, r0, #0x00100000
	add	r2, r0, #0x00200000

	/* Disable all interrupts (VIC0, VIC1 and VIC2) */
	mvn	r3, #0x0
	str	r3, [r0, #0x14]				@ INTENCLEAR
	str	r3, [r1, #0x14]				@ INTENCLEAR
	str	r3, [r2, #0x14]				@ INTENCLEAR

	/* Set all interrupts as IRQ */
	str	r5, [r0, #0xc]				@ INTSELECT
	str	r5, [r1, #0xc]				@ INTSELECT
	str	r5, [r2, #0xc]				@ INTSELECT

	/* Pending Interrupt Clear */
	str	r5, [r0, #0xf00]			@ INTADDRESS
	str	r5, [r1, #0xf00]			@ INTADDRESS
	str	r5, [r2, #0xf00]			@ INTADDRESS

	bl system_clock_init

	/* for UART */
	bl	uart_asm_init

	bl  ddr_init

	// 测试在DDR的256M+4B进行读写
	// TODO 为什么删除了不能启动
	ldr r0, =0x30000004
	ldr r1, =0x12345678
	str r1, [r0]
	ldr r0, [r0]
	bl test_print

	bl	internal_ram_init

	// 加载完整的u-boot程序到ddr中
	bl  copy_code_to_dram

	cmp	r7, r8
	/* Clear wakeup status register */
	ldreq	r0, =S5PC100_WAKEUP_STAT
	ldrne	r0, =S5PC110_WAKEUP_STAT
	ldr	r1, [r0]
	str	r1, [r0]

	/* IO retension release */
	ldreq	r0, =S5PC100_OTHERS			@ 0xE0108200
	ldrne	r0, =S5PC110_OTHERS			@ 0xE010E000
	ldr	r1, [r0]
	ldreq	r2, =(1 << 31)				@ IO_RET_REL
	ldrne	r2, =((1 << 31) | (1 << 30) | (1 << 29) | (1 << 28))
	orr	r1, r1, r2
	str	r1, [r0]

	b	1f

didle_wakeup:
	/* Wait when APLL is locked */
	ldr	r0, =0xE0100100			@ S5PC110_APLL_CON
lockloop:
	ldr	r1, [r0]
	and	r1, r1, #(1 << 29)
	cmp	r1, #(1 << 29)
	bne	lockloop

	ldr	r0, =S5PC110_INFORM0
	ldr	r1, [r0]
	mov	pc, r1
	nop
	nop
	nop
	nop
	nop

1:
	mov	lr, r11
	mov	pc, lr

/*
 * system_clock_init: Initialize core clock and bus clock.
 * void system_clock_init(void)
 */
system_clock_init:

	// clock base
	ldr r0, =0xe0100000

	// 3 设置分频
	ldr r1, =0x14131440
	str r1, [r0, #0x300]

	// 4 设置PLL
	// APLL=1GHz
	ldr r1, =0x807d0301
	str r1, [r0, #0x100]
	// MPLL=667MHz
	ldr r1, =0x829b0c01
	str r1, [r0, #0x108]
	// EPLL=80MHz
	ldr r1, =0
	str r1, [r0, #0x114]
	ldr r1, =0x88500303
	str r1, [r0, #0x110]
	// VPLL=54MHz
	ldr r1, =0x88600603
	str r1, [r0, #0x120]

	/* wait at least 200us to stablize all clock */
	mov	r2, #0x10000
1:	subs	r2, r2, #1
	bne	1b

	mov	pc, lr

internal_ram_init:
	ldreq	r0, =0xE3800000
	ldrne	r0, =0xF1500000
	ldr	r1, =0x0
	str	r1, [r0]

	mov	pc, lr

/*
 * uart_asm_init: Initialize UART's pins
 */
uart_asm_init:
	/* set GPIO to enable UART0-UART4 */
	mov	r0, r8
	ldr	r1, =0x22222222
	str	r1, [r0, #0x0]			@ S5PC100_GPIO_A0_OFFSET
	ldr	r1, =0x00002222
	str	r1, [r0, #0x20]			@ S5PC100_GPIO_A1_OFFSET

	/* Check S5PC100 */
	cmp	r7, r8
	bne	110f

	/* UART_SEL GPK0[5] at S5PC100 */
	add	r0, r8, #0x2A0			@ S5PC100_GPIO_K0_OFFSET
	ldr	r1, [r0, #0x0]			@ S5PC1XX_GPIO_CON_OFFSET
	bic	r1, r1, #(0xf << 20)		@ 20 = 5 * 4-bit
	orr	r1, r1, #(0x1 << 20)		@ Output
	str	r1, [r0, #0x0]			@ S5PC1XX_GPIO_CON_OFFSET

	ldr	r1, [r0, #0x8]			@ S5PC1XX_GPIO_PULL_OFFSET
	bic	r1, r1, #(0x3 << 10)		@ 10 = 5 * 2-bit
	orr	r1, r1, #(0x2 << 10)		@ Pull-up enabled
	str	r1, [r0, #0x8]			@ S5PC1XX_GPIO_PULL_OFFSET

	ldr	r1, [r0, #0x4]			@ S5PC1XX_GPIO_DAT_OFFSET
	orr	r1, r1, #(1 << 5)		@ 5 = 5 * 1-bit
	str	r1, [r0, #0x4]			@ S5PC1XX_GPIO_DAT_OFFSET

	b	200f
110:
	/*
	 * Note that the following address
	 * 0xE020'0360 is reserved address at S5PC100
	 */
	/* UART_SEL MP0_5[7] at S5PC110 */
	add	r0, r8, #0x360			@ S5PC110_GPIO_MP0_5_OFFSET
	ldr	r1, [r0, #0x0]			@ S5PC1XX_GPIO_CON_OFFSET
	bic	r1, r1, #(0xf << 28)		@ 28 = 7 * 4-bit
	orr	r1, r1, #(0x1 << 28)		@ Output
	str	r1, [r0, #0x0]			@ S5PC1XX_GPIO_CON_OFFSET

	ldr	r1, [r0, #0x8]			@ S5PC1XX_GPIO_PULL_OFFSET
	bic	r1, r1, #(0x3 << 14)		@ 14 = 7 * 2-bit
	orr	r1, r1, #(0x2 << 14)		@ Pull-up enabled
	str	r1, [r0, #0x8]			@ S5PC1XX_GPIO_PULL_OFFSET

	ldr	r1, [r0, #0x4]			@ S5PC1XX_GPIO_DAT_OFFSET
	orr	r1, r1, #(1 << 7)		@ 7 = 7 * 1-bit
	str	r1, [r0, #0x4]			@ S5PC1XX_GPIO_DAT_OFFSET

	/*配置串口2*/
	ldr r0, =S5PC110_UART_BASE
	/*ULCON 8n1*/
	ldr r1, =0x3
	str r1, [r0, #0x800]
	/*UCON*/
	ldr r1, =0x5
	str r1, [r0, #0x804]
	/*UFCON*/
	ldr r1, =0x217
	str r1, [r0, #0x808]
	/*UMCON*/
	ldr r1, =0x0
	str r1, [r0, #0x80C]
	/*UBRDIV*/
	ldr r1, =34
	str r1, [r0, #0x828]
	/*UDIVSLOT*/
	ldr r1, =0xDFDD
	str r1, [r0, #0x82C]

200:
	mov	pc, lr


.global test_print
test_print:
    ldr r1, =0xE2900820 @uart2

    ldr r2, =0x30
    str r2, [r1]        @0

    ldr r2, =0x78
    str r2, [r1]        @x

    ldr r3, =28

test_print_mem_loop:
    // 取4bit
    lsr r2, r0, r3       @ r0右移r3位结果保存到r2
    and r2, r2, #0xF     @ r2 = r2 & 0xF

    // 数字变ascii
    cmp r2, #10
    addmi r2, r2, #0x30  @ if <0, +0x30 (0-9)
    addpl r2, r2, #0x37  @ if >=0, +0x37 (a-f)

    // 输出一个字符
    str r2, [r1]

    // 循环下四位
    sub r3, r3, #4
    cmp r3, #0
    bpl test_print_mem_loop

    // 结束输出换行
    ldr r2, =0x0D
    str r2, [r1]        @\r

    ldr r2, =0x0A
    str r2, [r1]        @\n

    // 程序返回
    mov pc, lr

#define ELFIN_GPIO_BASE   S5PC110_GPIO_BASE
 
#define MP1_0DRV_SR_OFFSET 		0x3CC
#define MP1_1DRV_SR_OFFSET 		0x3EC
#define MP1_2DRV_SR_OFFSET 		0x40C
#define MP1_3DRV_SR_OFFSET 		0x42C
#define MP1_4DRV_SR_OFFSET 		0x44C
#define MP1_5DRV_SR_OFFSET 		0x46C
#define MP1_6DRV_SR_OFFSET 		0x48C
#define MP1_7DRV_SR_OFFSET 		0x4AC
#define MP1_8DRV_SR_OFFSET 		0x4CC
 
#define MP2_0DRV_SR_OFFSET 		0x4EC
#define MP2_1DRV_SR_OFFSET 		0x50C
#define MP2_2DRV_SR_OFFSET 		0x52C
#define MP2_3DRV_SR_OFFSET 		0x54C
#define MP2_4DRV_SR_OFFSET 		0x56C
#define MP2_5DRV_SR_OFFSET 		0x58C
#define MP2_6DRV_SR_OFFSET 		0x5AC
#define MP2_7DRV_SR_OFFSET 		0x5CC
#define MP2_8DRV_SR_OFFSET 		0x5EC
 
/*
 * SDRAM Controller
 */
#define APB_DMC_0_BASE			0xF0000000
#define APB_DMC_1_BASE			0xF1400000
#define ASYNC_MSYS_DMC0_BASE	0xF1E00000
 
#define DMC_CONCONTROL 			0x00
#define DMC_MEMCONTROL 			0x04
#define DMC_MEMCONFIG0 			0x08
#define DMC_MEMCONFIG1 			0x0C
#define DMC_DIRECTCMD 			0x10
#define DMC_PRECHCONFIG 		0x14
#define DMC_PHYCONTROL0 		0x18
#define DMC_PHYCONTROL1 		0x1C
#define DMC_RESERVED 			0x20
#define DMC_PWRDNCONFIG 		0x28
#define DMC_TIMINGAREF 			0x30
#define DMC_TIMINGROW 			0x34
#define DMC_TIMINGDATA 			0x38
#define DMC_TIMINGPOWER 		0x3C
#define DMC_PHYSTATUS 			0x40
#define DMC_CHIP0STATUS 		0x48
#define DMC_CHIP1STATUS 		0x4C
#define DMC_AREFSTATUS 			0x50
#define DMC_MRSTATUS 			0x54
#define DMC_PHYTEST0 			0x58
#define DMC_PHYTEST1 			0x5C
#define DMC_QOSCONTROL0 		0x60
#define DMC_QOSCONFIG0 			0x64
#define DMC_QOSCONTROL1 		0x68
#define DMC_QOSCONFIG1 			0x6C
#define DMC_QOSCONTROL2 		0x70
#define DMC_QOSCONFIG2 			0x74
#define DMC_QOSCONTROL3 		0x78
#define DMC_QOSCONFIG3 			0x7C
#define DMC_QOSCONTROL4 		0x80
#define DMC_QOSCONFIG4 			0x84
#define DMC_QOSCONTROL5 		0x88
#define DMC_QOSCONFIG5 			0x8C
#define DMC_QOSCONTROL6 		0x90
#define DMC_QOSCONFIG6 			0x94
#define DMC_QOSCONTROL7 		0x98
#define DMC_QOSCONFIG7 			0x9C
#define DMC_QOSCONTROL8 		0xA0
#define DMC_QOSCONFIG8 			0xA4
#define DMC_QOSCONTROL9 		0xA8
#define DMC_QOSCONFIG9 			0xAC
#define DMC_QOSCONTROL10 		0xB0
#define DMC_QOSCONFIG10 		0xB4
#define DMC_QOSCONTROL11 		0xB8
#define DMC_QOSCONFIG11 		0xBC
#define DMC_QOSCONTROL12 		0xC0
#define DMC_QOSCONFIG12 		0xC4
#define DMC_QOSCONTROL13 		0xC8
#define DMC_QOSCONFIG13 		0xCC
#define DMC_QOSCONTROL14 		0xD0
#define DMC_QOSCONFIG14 		0xD4
#define DMC_QOSCONTROL15 		0xD8
#define DMC_QOSCONFIG15 		0xDC
 
#define DMC0_MEMCONTROL		0x00202400 	// MemControl	BL=4, 1Chip, DDR2 Type, dynamic self refresh, force precharge, dynamic power down off
 
#define DMC0_MEMCONFIG_0	0x30F01323	// MemConfig0	256MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
#define DMC0_MEMCONFIG_1	0x30F00312	// MemConfig1		默认值
 
#define DMC0_TIMINGA_REF	0x00000618	// TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
#define DMC0_TIMING_ROW		0x28233287	// TimingRow	for @200MHz
#define DMC0_TIMING_DATA	0x23240304	// TimingData	CL=3
#define	DMC0_TIMING_PWR		0x09C80232	// TimingPower
 
#define	DMC1_MEMCONTROL		0x00202400	// MemControl	BL=4, 1chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
 
#define DMC1_MEMCONFIG_0	0x40F01323	// MemConfig0	256MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
#define DMC1_MEMCONFIG_1	0x60E00312	// MemConfig1		默认值
 
#define DMC1_TIMINGA_REF	0x00000618	// TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4
#define DMC1_TIMING_ROW		0x28233289	// TimingRow	for @200MHz
#define DMC1_TIMING_DATA	0x23240304	// TimingData	CL=3
#define	DMC1_TIMING_PWR		0x08280232	// TimingPower
 
.globl ddr_init
ddr_init:	
	ldr	r0, =0xf1e00000
	ldr	r1, =0x0
	str	r1, [r0, #0x0]
 
	/* DMC0 Drive Strength (Setting 2X) */
	
	ldr	r0, =ELFIN_GPIO_BASE
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_0DRV_SR_OFFSET]		// 寄存器中对应0b10，就是2X
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_1DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_2DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_3DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_4DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_5DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_6DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_7DRV_SR_OFFSET]
 
	ldr	r1, =0x00002AAA
	str	r1, [r0, #MP1_8DRV_SR_OFFSET]
 
	
	/* DMC1 Drive Strength (Setting 2X) */
	
	ldr	r0, =ELFIN_GPIO_BASE
	
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_0DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_1DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_2DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_3DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_4DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_5DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_6DRV_SR_OFFSET]
 
	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_7DRV_SR_OFFSET]
 
	ldr	r1, =0x00002AAA
	str	r1, [r0, #MP2_8DRV_SR_OFFSET]
	
	/* DMC0 initialization at single Type*/
	ldr	r0, =APB_DMC_0_BASE
 
	ldr	r1, =0x00101000				@PhyControl0 DLL parameter setting, manual 0x00101000
	str	r1, [r0, #DMC_PHYCONTROL0]
 
	ldr	r1, =0x00000086				@PhyControl1 DLL parameter setting, LPDDR/LPDDR2 Case
	str	r1, [r0, #DMC_PHYCONTROL1]
 
	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #DMC_PHYCONTROL0]
 
	ldr	r1, =0x00101003				@PhyControl0 DLL start
	str	r1, [r0, #DMC_PHYCONTROL0]
 
find_lock_val:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val
	
	and	r1, #0x3fc0 
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2 ,r2, #0x1000	
		
	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]
	
#if 0	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif
	/* setting DDR2 */
	ldr	r1, =0x0FFF2010				@ConControl auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]
 
	ldr	r1, =DMC0_MEMCONTROL			@MemControl BL=4, 1 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]
	
	ldr	r1, =DMC0_MEMCONFIG_0			@MemConfig0 256MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #DMC_MEMCONFIG0]
 
	ldr	r1, =DMC0_MEMCONFIG_1			@MemConfig1
	str	r1, [r0, #DMC_MEMCONFIG1]
 
	ldr	r1, =0xFF000000				@PrechConfig
	str	r1, [r0, #DMC_PRECHCONFIG]
	
	ldr	r1, =DMC0_TIMINGA_REF			@TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
	str	r1, [r0, #DMC_TIMINGAREF]
	
	ldr	r1, =DMC0_TIMING_ROW			@TimingRow	for @200MHz
	str	r1, [r0, #DMC_TIMINGROW]
 
	ldr	r1, =DMC0_TIMING_DATA			@TimingData	CL=3
	str	r1, [r0, #DMC_TIMINGDATA]
	
	ldr	r1, =DMC0_TIMING_PWR			@TimingPower
	str	r1, [r0, #DMC_TIMINGPOWER]
 
	ldr	r1, =0x07000000				@DirectCmd	chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00020000				@DirectCmd	chip0 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00030000				@DirectCmd	chip0 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00000542				@DirectCmd	chip0 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00000442				@DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00010780				@DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x07100000				@DirectCmd	chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x00120000				@DirectCmd	chip1 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x00130000				@DirectCmd	chip1 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x00100542				@DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x00100442				@DirectCmd	chip1 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]
	
	ldr	r1, =0x00110780				@DirectCmd	chip1 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]
		
	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]
		
	ldr	r1, =0x0FF02030				@ConControl	auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]
		
	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]
		
	ldr	r1, =0x00202400				@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]
	
// 上面是DRAM0初始化步骤
/*******************************************************************************************/	
// 下面是DRAM1初始化步骤，两者没有联系，是并列的。
 
	/* DMC1 initialization */
	ldr	r0, =APB_DMC_1_BASE
	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]
 
	
	ldr	r1, =0x00000086				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL1]
	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #DMC_PHYCONTROL0]
	ldr	r1, =0x00101003				@PhyControl0 DLL start
	str	r1, [r0, #DMC_PHYCONTROL0]
	
	
	
find_lock_val1:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val1
	
	and	r1, #0x3fc0 
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000
		
	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]
	
#if 0	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif
 
	/* settinf fot DDR2 */
	ldr	r0, =APB_DMC_1_BASE
 
	ldr	r1, =0x0FFF2010				@auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]
 
	ldr	r1, =DMC1_MEMCONTROL			@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]
 
	ldr	r1, =DMC1_MEMCONFIG_0			@MemConfig0	512MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #DMC_MEMCONFIG0]
 
	ldr	r1, =DMC1_MEMCONFIG_1			@MemConfig1
	str	r1, [r0, #DMC_MEMCONFIG1]
 
	ldr	r1, =0xFF000000
	str	r1, [r0, #DMC_PRECHCONFIG]
 
	ldr	r1, =DMC1_TIMINGA_REF			@TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4
	str	r1, [r0, #DMC_TIMINGAREF]
 
	ldr	r1, =DMC1_TIMING_ROW			@TimingRow	for @200MHz
	str	r1, [r0, #DMC_TIMINGROW]
 
	ldr	r1, =DMC1_TIMING_DATA			@TimingData	CL=3
	str	r1, [r0, #DMC_TIMINGDATA]
 
	ldr	r1, =DMC1_TIMING_PWR			@TimingPower
	str	r1, [r0, #DMC_TIMINGPOWER]
 
 
	ldr	r1, =0x07000000				@DirectCmd	chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00020000				@DirectCmd	chip0 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00030000				@DirectCmd	chip0 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00000542				@DirectCmd	chip0 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00000442				@DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00010780				@DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x07100000				@DirectCmd	chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00120000				@DirectCmd	chip1 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00130000				@DirectCmd	chip1 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00110440				@DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00100542				@DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00100442				@DirectCmd	chip1 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00110780				@DirectCmd	chip1 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]
 
	ldr	r1, =0x0FF02030				@ConControl	auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]
 
	ldr	r1, =0xFFFF00FF				@PwrdnConfig	
	str	r1, [r0, #DMC_PWRDNCONFIG]
 
	ldr	r1, =DMC1_MEMCONTROL			@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]
	// 函数返回
	mov pc, lr
