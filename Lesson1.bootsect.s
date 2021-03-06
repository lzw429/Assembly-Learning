    .code16 #十六位汇编
    .global _start #程序开始
    .text

    .equ BOOTSEG, 0x07c0 #equ定义常量；被BIOS识别为启动扇区，装载到内存0x07c0处
    #此时处于实汇编，内存寻址为 (段地址segment << 4  + 偏移量offset) 可寻址的线性空间为 20位

    ljmp $BOOTSEG,$_start #修改cs寄存器为BOOTSEG，并跳转到_start处执行代码

_start:
    #int 10，ah = 03     功能：获取光标位置和形状
    mov $BOOTSEG, %ax    #ax = BOOTSEG 通过 ax 设置 es
    mov %ax, %es         #设置ES寄存器，为输出字符串作准备
    mov $0x03, %ah       #功能号 03
                         #在输出信息前读取光标位置，返回的DH为行，DL为列
    xor %bh, %bh         #bh为显示页码，设为0
    int $0x10

    mov     $20,%cx      #设定输出长度 cx = 20
    mov     $0x0007, %bx #设置属性，bx是显示页面；bh是page 0, bl是attribute 7 (normal)，即亮白色
    #lea    msg1, %bp    #lea是取地址指令，bp是指针寄存器
    mov     $msg1, %bp   
    mov     $0x1301, %ax #写字符，移动光标 ax
    int     $0x10        #使用这个中断0x10时，输出所得的，因而要设置好 ES 和 BP

loop_forever:            #一直循环
    jmp loop_forever

sectors:
    .word 0

msg1:
    .byte 13,10          # ascii码13是回车，ascii码10是换行
    .ascii "The program is working."
    .byte 13,10,13,10

    .=0x1fe              #对齐语法，等价于.org 510，表示从前面已生成的机器码开始，后续补0直到510个字节。
						 #即补上第一扇区的最后两字节。

#在此填充魔术值，BIOS会识别硬盘中第一个扇区，以0xaa55为结束标志的为启动扇区，于是BIOS会装载。

boot_flag:
    .word 0xAA55
