%include "boot.inc"
section bootloaderstart vstart=0x9000
mov sp, 0x9000;

mov ax, message;
mov bp, ax;
mov ax, 0x1301;
mov dx, 0x0100;
mov cx, (endmsg - message)
mov bx, 0x0002;
int 0x10;
jmp start_loadgdt;
;下面设置的为平坦模式下的GDT,分别为代码段和数据段,视频段非平坦模式
;----------------------------------------设置GDT-----------------------------------
GDT_BASE: dd 0x00000000
            dd 0x00000000
CODE_DESC: dd 0x0000ffff
            dd DESC_CODE_HIGH4
DATA_STACK_DESC: dd 0x0000ffff
                    dd DESC_DATA_HIGH4
VIDEO_DESC: dd 0x80000007;
            dd DESC_VIDEO_HIGH4
            
GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE-1
times 60 dq 0; 预留的60个quadword

SELECTOR_CODE equ (0x0001<<3) + TI_GDT+RPL0
SELECTOR_DATA equ (0x0002<<3) + TI_GDT+RPL0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT+RPL0

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

start_loadgdt:
;----------------------------------------打开A20Gate-----------------------------------
in al, 0x92;
or al, 0000_0010B;
out 0x92, al;
;----------------------------------------加载GDT-----------------------------------
lgdt [gdt_ptr]
;----------------------------------------保护模式开关------------------------------
mov eax, cr0;
or eax, 0x00000001;
mov cr0, eax;

jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
mov ax, SELECTOR_DATA
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x9000
mov ax, SELECTOR_VIDEO
mov gs, ax
mov byte [gs:30], 'P'
jmp $


message db "bootload start!"
endmsg db 0;