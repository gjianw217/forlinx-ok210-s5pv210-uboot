
/*
 * 文件名：    led.s    
 * 描述：    流水灯
 */


#define GPH2CON   	0xE0200C40
#define GPH2DAT    	0xE0200C44
#define LEDCON 		GPH2CON
#define LEDDAT 		GPH2DAT

#define LED0     	0   /*LED pin index in the gpio controler */   
#define LED1     	1      
#define LED2     	2      
#define LED3     	3  

#define DELAY    	0X1000000


	.globl led_on
	.globl led_off
	.globl led0_on
	.globl led3_on
	.globl led_flash

led_on:
	ldr r0, =LEDCON			/* led control register */
	ldr r1, =0x00001111		/* set gpio output*/
	str r1, [r0]			

	ldr r0, =LEDDAT			/* led data register */
	ldr r1, =0x00000000		
	str r1, [r0]			/* set gpio low level to trun on the led */
	mov	pc, r9				/* return  */
	
led_off:
	ldr r0, =LEDCON		 
	ldr r1, =0x00001111		
	str r1, [r0]			 

	ldr r0, =LEDDAT		 
	ldr r1, =0x0000000F		/*set gpio high level to trun off the led*/
	str r1, [r0]			 
	mov	pc, r9			 
	
led0_on:
	ldr r0, =LEDCON		 
	ldr r1, =0x00000001		
	str r1, [r0]			 

	ldr r0, =LEDDAT		 
	ldr r1, =0x0000000E		 /*set gpio high level to trun off the led*/
	str r1, [r0]			 
	mov	pc, r9			 
	
led3_on:
	ldr r0, =LEDCON		 
	ldr r1, =0x00001000		
	str r1, [r0]			 
	ldr r0, =LEDDAT		 
	ldr r1, =0x00000007		
	str r1, [r0]			 
	mov	pc, r9			 
	
	
led_flash:
    /*Set GPIO OUTPUT mode*/  

	ldr r0, =0x00001111    
    ldr r1, =LEDCON     
    str r0, [r1]   
loopled:
    /*Turn off LED0, LED1, LED2, LED3*/
    ldr     r2, =LEDDAT
    ldr     r3, [r2]
    orr     r3, r3, #0x000F     /*Set high level to turn off the led */
    str     r3, [r2]  
    ldr     r0, =DELAY          /*Sleep for a while*/
    bl      delay

    /*Turn on LED0*/
    ldr     r3, [r2]
    bic     r3, r3, #(1<<LED0)  /*Clear bit 0, set low level to turn on the led */
    str     r3, [r2]  
    ldr     r0, =DELAY          /*Sleep for a while*/
    bl      delay

    /*Turn on LED1*/
    ldr     r3, [r2]
    bic     r3, r3, #(1<<LED1)   
    str     r3, [r2]  
    ldr     r0, =DELAY           
    bl      delay

    /*Turn on LED2*/
    ldr     r3, [r2]
    bic     r3, r3, #(1<<LED2)   
    str     r3, [r2]  
    ldr     r0, =DELAY          
    bl      delay

    /*Turn on LED3*/
    ldr     r3, [r2]
    bic     r3, r3, #(1<<LED3)  
    str     r3, [r2]  
    ldr     r0, =DELAY           
    bl      delay


    b       loopled             /*Loop running LED*/

delay:
    sub     r0, r0, #1
    cmp     r0, #0x0
    bne     delay
    mov     pc, lr
	
	
	
	
	
	
	