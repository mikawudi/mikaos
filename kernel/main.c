#include "print.h"
#define IDT_DEST_COUNT 0x21
#define SELECTOR_CODE (0x0001<<3)
#define IDT_DESC_ATTR_DPL0 ((0x01 << 7) + (0x00 << 5) + 0x0e)
struct gate_desc{
    uint16_t func_offset_low_word;
    uint16_t selector;
    uint8_t dcount;
    uint8_t attribute;
    uint16_t func_offset_high_word;
};
void printstr(uint8_t* str);
static struct gate_desc idt[IDT_DEST_COUNT];
extern void* func_table[IDT_DEST_COUNT];
static void make_idt_desc(struct gate_desc* p_gdesc, uint8_t attr, void* func);
static void idt_desc_init(void);
void idt_init();
static void pic_init();
static void outb(uint16_t port, uint8_t data);
int main(void) {
    printstr("into kernel!\nhellow mika!");
    printstr("start idt_init!\n");
    idt_init();
    printstr("idt_inited!");
    asm volatile("sti");
    while(1);
}
void printstr(uint8_t* str) {
    while((*str) != 0x00)
    {
        put_char(*str);
        str++;
    }
}

static void outb(uint16_t port, uint8_t data){
    asm volatile ("outb %b0, %w1" : : "a" (data), "Nd" (port));
}


static void make_idt_desc(struct gate_desc* p_gdesc, uint8_t attr, void* func) {
    p_gdesc->func_offset_low_word = (uint32_t)func & 0x0000ffff;
    p_gdesc->selector = SELECTOR_CODE;
    p_gdesc->dcount = 0;
    p_gdesc->attribute = attr;
    p_gdesc->func_offset_high_word = ((uint32_t)func & 0xffff0000) >> 16;
}

static void idt_desc_init(void){
    int i;
    for(i = 0; i < IDT_DEST_COUNT; i++){
        make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, &func_table[i]);
    }
    printstr("idt_desc_init_done!\n");
}

static void pic_init(){
    outb(0x20, 0x11);
    outb(0x21, 0x20);
    
    outb(0x21, 0x04);
    outb(0x21, 0x01);
    
    outb(0xa0, 0x11);
    outb(0xa1, 0x28);
    
    outb(0xa1, 0x02);
    outb(0xa1, 0x01);
    
    
    
    outb(0x21, 0xfe);
    outb(0xa1, 0xff);
}

void idt_init(){
    idt_desc_init();
    pic_init();
    
    uint64_t idt_operand = ((sizeof(idt) - 1) | ((uint64_t)((uint32_t)idt << 16)));
    asm volatile("lidt %0" : : "m" (idt_operand));
    
}