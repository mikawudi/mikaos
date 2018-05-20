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

mov bx, ax; 现在bx中放的是光标位置了
mov ecx, [esp + 36]; 一个char,就cl有用

cmp cl, 0x0d; CR 回车
jz .cr
cmp cl, 0x0a; LF 换行
jz .lf

.put_default_char:
shl bx, 1 ;左移一位表示X2,因为显卡中每个字符是2字节表示法
mov byte [gs:bx], cl
inc bx
mov byte [gs:bx], 0x07
shr bx, 1
inc bx
jmp .set_new_gb

.cr:
.lf:
xor dx, dx
mov ax, bx
mov si, 80
div si
sub bx, dx
add bx, 80


.set_new_gb:
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