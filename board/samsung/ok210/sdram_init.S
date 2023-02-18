#include <asm/arch/s5pv210.h>

#define CONFIG_CLK_1000_200_166_133

#define AFC_ON		0x00000000
#define AFC_OFF		0x10000010

#define APLL_LOCKTIME_VAL	0xe10  
#define MPLL_LOCKTIME_VAL	0xe10  


#define APLL_MDIV       0x7d
#define APLL_PDIV       0x3
#define APLL_SDIV       0x1

#define MPLL_MDIV	0x29b
#define MPLL_PDIV	0xc
#define MPLL_SDIV	0x1

#define EPLL_MDIV	0x60
#define EPLL_PDIV	0x6
#define EPLL_SDIV	0x2

#define VPLL_MDIV	0x6c
#define VPLL_PDIV	0x6
#define VPLL_SDIV	0x3

/* CLK_DIV0 */
#define APLL_RATIO	0
#define A2M_RATIO	4
#define HCLK_MSYS_RATIO	8
#define PCLK_MSYS_RATIO	12
#define HCLK_DSYS_RATIO	16
#define PCLK_DSYS_RATIO 20
#define HCLK_PSYS_RATIO	24
#define PCLK_PSYS_RATIO 28

#define CLK_DIV0_MASK	0x7fffffff
/*******lxg added**************/
#define CLK_DIV1_MASK	0xffffffff
#define CLK_DIV2_MASK	0x0fff
#define CLK_DIV3_MASK	0x7fffffff
#define CLK_DIV4_MASK	0xffffffff
#define CLK_DIV6_MASK	0xffffffff
/*******end**************/

#define set_pll(mdiv, pdiv, sdiv)	(1<<31 | mdiv<<16 | pdiv<<8 | sdiv)
#define APLL_VAL	set_pll(APLL_MDIV,APLL_PDIV,APLL_SDIV)
#define MPLL_VAL	set_pll(MPLL_MDIV,MPLL_PDIV,MPLL_SDIV)
#define EPLL_VAL	set_pll(EPLL_MDIV,EPLL_PDIV,EPLL_SDIV)
#define VPLL_VAL	set_pll(VPLL_MDIV,VPLL_PDIV,VPLL_SDIV)


#define CLK_DIV0_VAL    ((0<<APLL_RATIO)|(4<<A2M_RATIO)|(4<<HCLK_MSYS_RATIO)|(1<<PCLK_MSYS_RATIO)\
			|(3<<HCLK_DSYS_RATIO)|(1<<PCLK_DSYS_RATIO)|(4<<HCLK_PSYS_RATIO)|(1<<PCLK_PSYS_RATIO))


#define CLK_DIV1_VAL	((1<<16)|(1<<12)|(1<<8)|(1<<4))
#define CLK_DIV2_VAL	(1<<0)
#define CLK_DIV4_VAL	0x99990000
#define CLK_DIV6_VAL	0x71000


#define DMC0_MEMCONTROL		0x00212400	// MemControl	BL=4, 1Chip, DDR2 Type, dynamic self refresh, force precharge, dynamic power down off
#define DMC0_MEMCONFIG_0	0x30F01313	// MemConfig0	256MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
#define DMC0_MEMCONFIG_1	0x40F01313	// MemConfig1
#define DMC0_TIMINGA_REF        0x00000618      // TimingAref   7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
#define DMC0_TIMING_ROW         0x28233287      // TimingRow    for @200MHz
#define DMC0_TIMING_DATA        0x23240304      // TimingData   CL=3
#define DMC0_TIMING_PWR         0x09C80232      // TimingPower

#define	DMC1_MEMCONTROL		0x00202400	// MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
#define DMC1_MEMCONFIG_0	0x40F01313	// MemConfig0	512MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
#define DMC1_MEMCONFIG_1	0x00F01313	// MemConfig1
#define DMC1_TIMINGA_REF        0x00000618      // TimingAref   7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
#define DMC1_TIMING_ROW         0x28233289      // TimingRow    for @200MHz
#define DMC1_TIMING_DATA        0x23240304      // TimingData   CL=3
#define DMC1_TIMING_PWR         0x08280232      // TimingPower
.globl sdram_init

sdram_init:

	/* DMC0 Drive Strength (Setting 2X) */
	
	ldr	r0, =ELFIN_GPIO_BASE

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_0DRV_SR_OFFSET]

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
	
	
	mov	pc, lr
