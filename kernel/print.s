%include "../boot.inc"
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

[bits 32]
section .text

global put_char
put_char:

pushad
mov ax, SELECTOR_VIDEO
mov gs, ax

;获取光标
mov dx, 0x03d4
mov al, 0x0e
out dx, al
mov dx, 0x03d5
in al, dx
mov ah, al

mov dx, 0x03d4
mov al, 0x0f
out dx, al
mov dx, 0x03d5
in al, dx

mov bx, ax
mov ecx, [esp + 36]

shl bx, 1 ;左移一位表示X2,因为显卡中每个字符是2字节表示法
mov byte [gs:bx], cl
inc bx
mov byte [gs:bx], 0x07
shr bx, 1
inc bx

mov dx, 0x03d4
mov al, 0x0e
out dx, al
mov dx, 0x03d5
mov al, bh
out dx, al

mov dx, 0x03d4
mov al, 0x0f
out dx, al
mov dx, 0x03d5
mov al, bl
out dx, al

popad
ret