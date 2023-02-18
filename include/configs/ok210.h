/*
 * (C) Copyright 2009 Samsung Electronics
 * Minkyu Kang <mk7.kang@samsung.com>
 * HeungJun Kim <riverful.kim@samsung.com>
 * Inki Dae <inki.dae@samsung.com>
 *
 * Configuation settings for the Forlinx OK210 board.
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#ifndef __CONFIG_H
#define __CONFIG_H

#define CONFIG_SYS_CACHELINE_SIZE	64

/*
 * High Level Configuration Options
 * (easy to change)
 */
#define CONFIG_SAMSUNG		1	/* in a SAMSUNG core */
#define CONFIG_S5P		1	/* which is in a S5P Family */
#define CONFIG_S5PC100		1	/* which is in a S5PC100 */
#define CONFIG_OK210	1	/* working with OK210 */

#include <asm/arch/cpu.h>		/* get chip and board defs */

#define CONFIG_ARCH_CPU_INIT

#define CONFIG_DISPLAY_CPUINFO
#define CONFIG_DISPLAY_BOARDINFO

/* input clock of PLL: OK210 has 12MHz input clock */
#define CONFIG_SYS_CLK_FREQ		12000000

/* DRAM Base */
#define CONFIG_SYS_SDRAM_BASE		0x30000000

/* Text Base */
#define CONFIG_SYS_TEXT_BASE		CONFIG_SYS_SDRAM_BASE

#define CONFIG_SYS_LOAD_ADDR		CONFIG_SYS_SDRAM_BASE
#define CONFIG_SYS_INIT_SP_ADDR	(CONFIG_SYS_SDRAM_BASE + (256 << 20)+(256 << 20))
#define CONFIG_SPL_STACK	0xD0037FFF

#define CONFIG_SETUP_MEMORY_TAGS
#define CONFIG_CMDLINE_TAG
#define CONFIG_INITRD_TAG
#define CONFIG_CMDLINE_EDITING

/*
 * Size of malloc() pool
 * 1MB = 0x100000, 0x100000 = 1024 * 1024
 */
#define CONFIG_SYS_MALLOC_LEN		(CONFIG_ENV_SIZE + (1 << 20))

/*
 * select serial console configuration
 */
#define CONFIG_SERIAL2			1	/* use SERIAL 0 on OK210 */

/* PWM */
#define CONFIG_PWM			1

/* allow to overwrite serial and ethaddr */
#define CONFIG_ENV_OVERWRITE
#define CONFIG_BAUDRATE			115200

/***********************************************************
 * Command definition
 ***********************************************************/

#define CONFIG_CMD_REGINFO
#define CONFIG_CMD_NAND
#ifdef CONFIG_CMD_NAND
#define CONFIG_SYS_MAX_NAND_DEVICE 	1
#define CONFIG_SYS_NAND_BASE		0xB0E00000
#define CONFIG_NAND_S5PV210
#define CONFIG_S5PV210_NAND_HWECC
#define	CONFIG_SYS_NAND_ECCSIZE		512
#define CONFIG_SYS_NAND_ECCBYTES	13
#define CONFIG_CMD_MTDPARTS
#define CONFIG_MTD_DEVICE
#define CONFIG_MTD_PARTITIONS

#endif /*ONFIG_CMD_NAND*/

#define MTDIDS_DEFAULT		"nand0=s5p-nand"
#define MTDPARTS_DEFAULT	"mtdparts=s5p-nand:1m(bootloader)"\
				",512k(params)"\
				",512k(dtb)"\
				",4m(kernel)"\
				",10m(ramdisk)"\
				",15m(cramfs)"\
				",40m(jffs2)"\
				",40m(yaffs2)"\
				",40m(ubifs)"\
				",-(data)"

#define NORMAL_MTDPARTS_DEFAULT MTDPARTS_DEFAULT


#define CONFIG_ENV_OVERWRITE
#define CONFIG_ZERO_BOOTDELAY_CHECK
#define CONFIG_BOOTDELAY	3

/*
 * Miscellaneous configurable options
 */
#define CONFIG_SYS_LONGHELP		/* undef to save memory */
#define CONFIG_SYS_CBSIZE	256	/* Console I/O Buffer Size */
#define CONFIG_SYS_PBSIZE	384	/* Print Buffer Size */
#define CONFIG_SYS_MAXARGS	16	/* max number of command args */
/* Boot Argument Buffer Size */
#define CONFIG_SYS_BARGSIZE		CONFIG_SYS_CBSIZE
/* memtest works on */
#define CONFIG_SYS_MEMTEST_START	CONFIG_SYS_SDRAM_BASE
#define CONFIG_SYS_MEMTEST_END		(CONFIG_SYS_SDRAM_BASE + 0x5e00000)


/* OK210 has 1 banks of DRAM, we use only one in U-Boot */
#define CONFIG_NR_DRAM_BANKS	2
#define PHYS_SDRAM_1			CONFIG_SYS_SDRAM_BASE		/* SDRAM Bank #1 */
#define PHYS_SDRAM_1_SIZE		(256 << 20)					/* 0x1000000, 256 MB Bank #1 */
#define PHYS_SDRAM_2			(CONFIG_SYS_SDRAM_BASE+PHYS_SDRAM_1_SIZE)	/* SDRAM Bank #2 */
#define PHYS_SDRAM_2_SIZE		(256 << 20)					/* 0x1000000, 256 MB Bank #1 */

#define CONFIG_SYS_MONITOR_BASE	0x00000000

/*-----------------------------------------------------------------------
 * FLASH and environment organization
 */
#define CONFIG_SYS_NO_FLASH		1

#define CONFIG_SYS_MONITOR_LEN		(256 << 10)	/* 256 KiB */
#define CONFIG_IDENT_STRING		" for OK210"


/*-----------------------------------------------------------------------
 * Boot configuration
 */
#define CONFIG_ENV_IS_IN_NAND	1
#define CONFIG_ENV_SIZE			(512 << 10)	/* 512KiB, 0x80000 */
#define CONFIG_ENV_ADDR			(1 << 20)	/* 1MB, 0x100000 */
#define CONFIG_ENV_OFFSET		(1 << 20)	/* 1MB, 0x100000 */


#define CONFIG_DOS_PARTITION		1



/*
 * Ethernet Contoller driver
 */
#ifdef CONFIG_CMD_NET

#define CONFIG_ENV_SROM_BANK   1       /* Select SROM Bank-1 for Ethernet*/
#define CONFIG_DRIVER_DM9000
#define CONFIG_DM9000_NO_SROM
#define CONFIG_DM9000_BASE		0x88000000
#define DM9000_IO				(CONFIG_DM9000_BASE)
#define DM9000_DATA				(CONFIG_DM9000_BASE + 0x4)
#define CONFIG_CMD_PING
#define CONFIG_IPADDR			192.168.1.121
#define CONFIG_SERVERIP			192.168.1.108
#define CONFIG_ETHADDR			1A:2A:3A:4A:5A:6A
#endif /* CONFIG_CMD_NET */

#endif	/* __CONFIG_H */
