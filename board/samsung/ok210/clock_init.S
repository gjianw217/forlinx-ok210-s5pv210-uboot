/*
 * Copyright (C) 2009 Samsung Electronics
 * Kyungmin Park <kyungmin.park@samsung.com>
 * Minkyu Kang <mk7.kang@samsung.com>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <asm/arch/s5pv210.h>
#define	  APLL_CON0	   0xE0100100  @FOUT_APLL = 1000 MHZ
#define   APLL_VAL     ((1<<31)|(125<<16)|(3<<8)|(1<<0))    
         
#define		MPLL_CON     0xE0100108  @FOUT_MPLL = 667 MHZ
#define   MPLL_VAL     ((1<<31)|(667<<16)|(12<<8)|(1<<0)) 

#define		EPLL_CON0    0xE0100110  @FOUT_EPLL = 96 MHZ
#define   EPLL_VAL     ((1<<31)|(48<<16)|(3<<8)|(2<<0)) 

#define		VPLL_CON 	   0xE0100120  @FOUT_VPLL = 54 MHZ
#define   VPLL_VAL     ((1<<31)|(108<<16)|(6<<8)|(3<<0)) 

@ MOUT_MSYS = SCLKAPLL = FOUT_APLL = 1000MHz
@ MOUT_DSYS = SCLKMPLL = FOUT_MPLL = 667MHz
@ MOUT_PSYS = SCLKMPLL = FOUT_MPLL = 667MHz
@ ONENAND = HCLK_PSYS

#define   CLK_SRC0     0xE0100200
#define   SRC0_VAL     ((1<<0)|(1<<4)|(1<<8)|(1<<12))

@ APLL_RATIO = 0, freq(ARMCLK) = MOUT_MSYS / (APLL_RATIO + 1) = 1000MHz */
@ A2M_RATIO = 4, freq(A2M) = SCLKAPLL / (A2M_RATIO + 1) = 200MHz */
@ HCLK_MSYS_RATIO = 4, freq(HCLK_MSYS) = ARMCLK / (HCLK_MSYS_RATIO + 1) = 200MHz */
@ PCLK_MSYS_RATIO = 1, freq(PCLK_MSYS) = HCLK_MSYS / (PCLK_MSYS_RATIO + 1) = 100MHz */
@ HCLK_DSYS_RATIO = 3, freq(HCLK_DSYS) = MOUT_DSYS / (HCLK_DSYS_RATIO + 1) = 166MHz */
@ PCLK_DSYS_RATIO = 1, freq(PCLK_DSYS) = HCLK_DSYS / (PCLK_DSYS_RATIO + 1) = 83MHz */
@ HCLK_PSYS_RATIO = 4, freq(HCLK_PSYS) = MOUT_PSYS / (HCLK_PSYS_RATIO + 1) = 133MHz */
@ PCLK_PSYS_RATIO = 1, freq(PCLK_PSYS) = HCLK_PSYS / (PCLK_PSYS_RATIO + 1) = 66MHz */

#define   CLK_DIV0 0xE0100300
#define	  DIV0_VAL 	((0<<0)|(4<<4)|(4<<8)|(1<<12)|(3<<16)|(1<<20)|(4<<24)|(1<<28))	

/*
 * system_clock_init: Initialize core clock and bus clock.
 * void system_clock_init(void)
 */
	.global system_clock_init
	
system_clock_init:
 
    ldr    r0, =ELFIN_CLOCK_POWER_BASE    @0xe0100000
        ldr    v1, =0x2D0
        ldr    v2, =0x12C0
        ldr    v3, =0x2328
        ldr    v4, =0x960
 
        str    v1, [r0, #0x00]                /*APLL_LOCK_OFFSET*/
        str    v2, [r0, #0x04]                /*MPLL_LOCK_OFFSET*/
        str    v3, [r0, #0x08]                /*EPLL_LOCK_OFFSET*/
        str    v4, [r0, #0x0c]                /*VPLL_LOCK_OFFSET*/
 
/**************************************************************************
  APLL_CON0_OFFSET 0x100   @24  1000  APLL  3  125  1  2000.0  FOUTAPLL = 1000.0MHz
  MPLL_CON0_OFFSET 0x108   @24  667  MPLL  12  667  1  667.0  FOUTAPLL = 667.0MHz
  EPLL_CON0_OFFSET 0x110   @24   54  VPLL  6  108  3  54.0  FOUTAPLL = 54.0MHz 
***************************************************************************/
    ldr    r1, =(1<<31 |125<<16 |3<<8 |1<<0)  @APLL_VAL=(1<<31 | 445<<16 | 0x4<<8 | 1<<0)
    str    r1, [r0, #APLL_CON0_OFFSET]      
 
    ldr    r1, =(1<<31 |667<<16 |12<<8 |1<<0)  @MPLL_VAL=(1<<31 |667<<16 |12<<8 |1<<0)
    str    r1, [r0, #MPLL_CON_OFFSET]     
 
    ldr    r1, =(1<<31 |48<<16 |3<<8 |2<<0)  @EPLL_VAL=(1<<31 |48<<16 |3<<8 |2<<0)
    str    r1, [r0, #EPLL_CON_OFFSET]     
 
    ldr    r1, =(1<<31 |108<<16 |6<<8 |3<<0)  @VPLL_VAL=(1<<31 |108<<16 |6<<8 |3<<0)
    str    r1, [r0, #VPLL_CON_OFFSET]     
 
 
    //CLK_SRC0_OFFSET            0x200
    ldr    r1, [r0, #CLK_SRC0_OFFSET]
    ldr    r2, =(0<<28|1<<12 |1<<8 |1<<4 |1<<0)
    orr    r1, r1, r2
    str    r1, [r0, #CLK_SRC0_OFFSET]
 
    /*将r0的值偏移300,此时地址为CLK_DIV0 = 0xE010_0300,保存到r1
     * 将CLK_DIV0中有关分频的位全部清零0~30
     */
    ldr r1, [r0, #0x300]            /*CLK_DIV0_OFFSET*/
    ldr    r2, =0x7fff                /*CLK_DIV0_MASK*/
    bic    r1, r1, r2
 
    /*分频给系统时钟*/
    ldr    r2, =(0<<0)|(2<<4)|(4<<8)|(1<<12)|(3<<16)|(1<<20)|(4<<24)|(1<<28)      
    orr    r1, r1, r2
    str    r1, [r0, #0x300]  //CLK_DIV0_OFFSET
 

    mov    r1, #0x10000
1:    subs    r1, r1, #1
    bne    1b
    mov    pc, lr