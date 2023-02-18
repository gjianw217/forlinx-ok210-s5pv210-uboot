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
#include <asm/arch/clock.h>	

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
#define BL2_SECTOR_NUM		(512*2)
#define BL2_SIZE			(BL2_SECTOR_NUM*SD_SECTOR_SIZE)	/*256*2KB*/

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
	
	struct s5pv210_clock *const clock = (struct s5pv210_clock *)samsung_get_base_clock();
	
	/* 1.设置PLL锁定值 */
	writel(0xFFFF, &clock->apll_lock);
	writel(0xFFFF, &clock->mpll_lock);
	writel(0xFFFF, &clock->epll_lock);
	writel(0xFFFF, &clock->vpll_lock);
	
	/* 2.设置PLL的PMS值(使用芯片手册推荐的值)，并使能PLL */
	/*	 	P	  	    M   		  S		     EN	*/
	writel((3  << 8) | (125 << 16) | (1 << 0) | (1 << 31), &clock->apll_con0);	/* FOUT_APLL = 1000MHz */
	writel((12 << 8) | (667 << 16) | (1 << 0) | (1 << 31), &clock->mpll_con); 	/* FOUT_MPLL = 667MHz */
	writel((3  << 8) | (48  << 16) | (2 << 0) | (1 << 31), &clock->epll_con0);	/* FOUT_EPLL = 96MHz */
	writel((6  << 8) | (108 << 16) | (3 << 0) | (1 << 31), &clock->vpll_con);	/* FOUT_VPLL = 54MHz */
	
	/* 3.等待PLL锁定 */
	while (!(readl(&clock->apll_con0) & (1 << 29)));
	while (!(readl(&clock->mpll_con) & (1 << 29)));
	while (!(readl(&clock->apll_con0) & (1 << 29)));
	while (!(readl(&clock->epll_con0) & (1 << 29)));
	while (!(readl(&clock->vpll_con) & (1 << 29)));

	/* 
	** 4.设置系统时钟源，选择PLL为时钟输出 */
	/* MOUT_MSYS = SCLKAPLL = FOUT_APLL = 1000MHz
	** MOUT_DSYS = SCLKMPLL = FOUT_MPLL = 667MHz
	** MOUT_PSYS = SCLKMPLL = FOUT_MPLL = 667MHz
	** ONENAND = HCLK_PSYS
	*/
	writel((1 << 0) | (1 << 4) | (1 << 8) | (1 << 12), &clock->src0);
	
	/* 4.设置其他模块的时钟源 */

	/* 6.设置系统时钟分频值 */
	val = 	(0 << 0)  |	/* APLL_RATIO = 0, freq(ARMCLK) = MOUT_MSYS / (APLL_RATIO + 1) = 1000MHz */
			(4 << 4)  |	/* A2M_RATIO = 4, freq(A2M) = SCLKAPLL / (A2M_RATIO + 1) = 200MHz */
			(4 << 8)  |	/* HCLK_MSYS_RATIO = 4, freq(HCLK_MSYS) = ARMCLK / (HCLK_MSYS_RATIO + 1) = 200MHz */
			(1 << 12) |	/* PCLK_MSYS_RATIO = 1, freq(PCLK_MSYS) = HCLK_MSYS / (PCLK_MSYS_RATIO + 1) = 100MHz */
			(3 << 16) | /* HCLK_DSYS_RATIO = 3, freq(HCLK_DSYS) = MOUT_DSYS / (HCLK_DSYS_RATIO + 1) = 166MHz */
			(1 << 20) | /* PCLK_DSYS_RATIO = 1, freq(PCLK_DSYS) = HCLK_DSYS / (PCLK_DSYS_RATIO + 1) = 83MHz */
			(4 << 24) |	/* HCLK_PSYS_RATIO = 4, freq(HCLK_PSYS) = MOUT_PSYS / (HCLK_PSYS_RATIO + 1) = 133MHz */
			(1 << 28);	/* PCLK_PSYS_RATIO = 1, freq(PCLK_PSYS) = HCLK_PSYS / (PCLK_PSYS_RATIO + 1) = 66MHz */
	writel(val, &clock->div0);
	
	/* 7.设置其他模块的时钟分频值 */
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
