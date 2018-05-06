section mbrmain vstart=0x7c00
;----------------------各种段寄存器的初始化-------------------------
mov ax, cs;
mov ds, ax;
mov es, ax;
mov ss, ax;
mov fs, ax;
mov sp, 0x7c00;
;-----------------------卷屏----------------------------------------
mov ax, 0x0600;
mov bx, 0x0700;
mov cx, 0x0000;
mov dx, 0x184f;

int 0x10;
;-----------------------print---------------------------------------
mov ax, message;
mov bp, ax;
mov ax, 0x1301;
mov dx, 0x0000;
mov cx, endmessahe - message;
mov bx, 0x0002;

int 0x10;
;-----------------------reda disk load bootload----------------------
mov ah, 0x02; 功能号
mov al, 0x04; 读取扇区数
mov ch, 0x00; 磁道号低8位
mov cl, 0x04; 0-5 起始扇区号,6-7磁道号高2位
mov dh, 0x00; 磁头号
mov dl, 0x80;
mov bx, 0x9000; ES:BX 读取到内存的起始地址

int 0x13;

;-------------------------------------------读取内核,从磁盘第 10扇区0磁道0柱面 开始,读取10个扇区,将内核读取到缓冲器
mov ah, 0x02; 功能号
mov al, 0x0a; 读取扇区数
mov ch, 0x00; 磁道号低8位
mov cl, 0x0a; 0-5 起始扇区号,6-7磁道号高2位
mov dh, 0x00; 磁头号
mov dl, 0x80;
mov bx, 0xb000; ES:BX 读取到内存的起始地址

int 0x13;

jmp 0x9000

message db "start mbr ld kernal!"
endmessahe times 510 - ($-$$) db 0;
db 0x55, 0xaa;