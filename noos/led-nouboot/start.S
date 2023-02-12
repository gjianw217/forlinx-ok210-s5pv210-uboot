/* start.S */

.global _start				/* 声明一个全局的标号 */
_start:

halt:
		b led_flash
		b halt				/* 死循环 */


