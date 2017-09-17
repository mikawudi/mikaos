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
;-----------------------------------------保护模式下print一下,证明几个段选择子没问题!---------
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
;-----------------------------------------开始初始化页目录---------------------------
;----------和书里一样吧,把页目录放到0x100000
mov ecx, 4096;
mov esi, 0;
clear_page_dic:
mov byte [0x100000 + esi], 0
inc esi;
loop clear_page_dic;
mov eax, 0x101000;
or eax, PG_US_U | PG_RW_W | PG_P
mov [0x100000], eax; 第一条页目录项纪录
mov [0x100000 + 0xc00], eax; 第768页目录项纪录
sub eax, 0x1000;把最后一个也目录项指回页目录项本身(高十位和中十位全为F则指到页目录项本身物理地址)
mov [0x100000 + 0x3ff], eax;

;------------------------------------------创建页表项(只有第一个页表的前256项,即最低的1M)----------------------------
mov eax, 0x101000;
mov ebx, PG_US_U|PG_RW_W|PG_P;
mov ecx, 256;
mov esi, 0;
create_PTE:
mov [eax + esi*4], ebx;
add ebx, 4096;
inc esi;
loop create_PTE;

;-------------------------------------------第769项目到1022项
mov eax, 0x102000;
mov ebx, 0x100000;
mov esi, 769; 
mov ecx, 254;
or eax,  PG_US_U | PG_RW_W | PG_P
entry_PDT:
mov [ebx + esi*4], eax;
add eax, 0x1000;
inc esi;
loop entry_PDT
;-------------------------------------------将段描述符的基址改为当前地址+0xc0000000------------------
add dword [gdt_ptr + 2], 0xc0000000
add esp, 0xc0000000
;-------------------------------------------启动分页---------------------
mov eax, 0x100000;
mov cr3, eax;

mov eax, cr0;
or eax, 0x80000000
mov cr0, eax;
lgdt [gdt_ptr]

mov byte [gs:32], 'V'
jmp $


message db "bootload start!"
endmsg db 0;