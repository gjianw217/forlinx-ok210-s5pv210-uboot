/*
 *  Copyright (C) 2008-2009 Samsung Electronics
 *  Minkyu Kang <mk7.kang@samsung.com>
 *  Kyungmin Park <kyungmin.park@samsung.com>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <common.h>
#include <asm/gpio.h>
#include <asm/io.h>
#include <asm/arch/sromc.h>
#include <netdev.h>

DECLARE_GLOBAL_DATA_PTR;

#define GPH2CON   	0xE0200C40
#define GPH2DAT    	0xE0200C44

#define LED_CON GPH2CON
#define LED_DAT GPH2DAT

void s5pv210_early_debug(int debug_code)
{
	if(debug_code > 0xf)
		debug_code = 0;
	writel(0x1111, LED_CON);
	writel(~(~0&debug_code), LED_DAT);
}

#ifdef CONFIG_SPL_BUILD
 
#define CopySDMMCtoMem(ch, sb, bs, dst, i) \
	(((u8(*)(int, u32, unsigned short, u32*, u8))\
	(*((u32 *)0xD0037F98)))(ch, sb, bs, dst, i))
	
#define SD_SECTOR_SIZE 		512

#define BL1_START_SECTOR	1
#define BL1_SECTOR_NUM		32
#define BL1_SIZE			(BL1_SECTOR_NUM*SD_SECTOR_SIZE)	/*16KB*/

#define BL2_START_SECTOR	(BL1_START_SECTOR+BL1_SECTOR_NUM)
#define BL2_SECTOR_NUM		(512*1)
#define BL2_SIZE			(BL2_SECTOR_NUM*SD_SECTOR_SIZE)	/*256*1KB*/

void copy_bl2_to_ram(void)
{
/*
** ch:  通道
** sb:  起始块
** bs:  块大小
** dst: 目的地
** i: 	是否初始化
*/
	u32 OM = *(volatile u32 *)(0xE0000004);	// OM Register
	OM &= 0x1F;					// 取低5位
	
	if (OM == 0xC)		// SD/MMC
	{
		u32 S5PV210_SDMMC_BASE = *(volatile u32 *)(0xD0037488);	// S5PV210_SDMMC_BASE
		u8 ch = 0;
		/* 参考S5PV210手册7.9.1 SD/MMC REGISTER MAP */
		if (S5PV210_SDMMC_BASE == 0xEB000000)		// 通道0
			ch = 0;
		else if (S5PV210_SDMMC_BASE == 0xEB200000)	// 通道2
			ch = 2;
		CopySDMMCtoMem(ch, BL2_START_SECTOR, BL2_SECTOR_NUM, (u32 *)CONFIG_SYS_TEXT_BASE, 0);
	}
}

void board_init_f(ulong bootflag)
{
	int val;
	__attribute__((noreturn)) void (*uboot)(void);
	
#define DDR_TEST_ADDR 0x40000000 /*0x30000000 -- 0x50000000*/
#define DDR_TEST_CODE 0xaa
	s5pv210_early_debug(0x0);
	writel(DDR_TEST_CODE, DDR_TEST_ADDR);
	val = readl(DDR_TEST_ADDR);
	if(val == DDR_TEST_CODE)
		s5pv210_early_debug(0x1);
	else
	{
		s5pv210_early_debug(0x8);
	}
	
	copy_bl2_to_ram();
	uboot = (void *)CONFIG_SYS_TEXT_BASE;
	(*uboot)();
}

void clock_init(void)
{
	u32 val = 0;
	
}

 
#endif

/*
 * Miscellaneous platform dependent initialisations
 */
static void smc9115_pre_init(void)
{
	u32 smc_bw_conf, smc_bc_conf;

	/* gpio configuration GPK0CON */
	gpio_cfg_pin(S5PC100_GPIO_K00 + CONFIG_ENV_SROM_BANK, S5P_GPIO_FUNC(2));

	/* Ethernet needs bus width of 16 bits */
	smc_bw_conf = SMC_DATA16_WIDTH(CONFIG_ENV_SROM_BANK);
	smc_bc_conf = SMC_BC_TACS(0x0) | SMC_BC_TCOS(0x4) | SMC_BC_TACC(0xe)
			| SMC_BC_TCOH(0x1) | SMC_BC_TAH(0x4)
			| SMC_BC_TACP(0x6) | SMC_BC_PMC(0x0);

	/* Select and configure the SROMC bank */
	s5p_config_sromc(CONFIG_ENV_SROM_BANK, smc_bw_conf, smc_bc_conf);
}

int board_init(void)
{
	smc9115_pre_init();

	gd->bd->bi_arch_number = MACH_TYPE_SMDKC100;
	gd->bd->bi_boot_params = PHYS_SDRAM_1 + 0x100;

	return 0;
}

int dram_init(void)
{
	gd->ram_size = get_ram_size((long *)PHYS_SDRAM_1, PHYS_SDRAM_1_SIZE);

	return 0;
}

void dram_init_banksize(void)
{
	gd->bd->bi_dram[0].start = PHYS_SDRAM_1;
	gd->bd->bi_dram[0].size = PHYS_SDRAM_1_SIZE;
}

#ifdef CONFIG_DISPLAY_BOARDINFO
int checkboard(void)
{
	printf("Board:\tSMDKC100\n");
	return 0;
}
#endif

int board_eth_init(bd_t *bis)
{
	int rc = 0;
#ifdef CONFIG_SMC911X
	rc = smc911x_initialize(0, CONFIG_SMC911X_BASE);
#endif
	return rc;
}
