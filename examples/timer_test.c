#include <stdint.h>

#define UARTLITE_BASE    0x40600000
#define UARTLITE_TX_FIFO  (UARTLITE_BASE + 0x04)
#define TIMER_BASE       0x41C00000
#define TIMER_TCSR0      (TIMER_BASE + 0x00)
#define TIMER_TLR0       (TIMER_BASE + 0x04)

void uartlite_putc(char c) {
    volatile uint32_t *tx_fifo = (volatile uint32_t *)UARTLITE_TX_FIFO;
    *tx_fifo = c;
}

void uartlite_puts(const char *str) {
    while (*str) {
        uartlite_putc(*str++);
    }
}

void timer_delay(uint32_t cycles) {
    volatile uint32_t *tcsr = (volatile uint32_t *)TIMER_TCSR0;
    volatile uint32_t *tlr = (volatile uint32_t *)TIMER_TLR0;
    
    *tlr = cycles;
    *tcsr = 0x00000092;  // Enable, auto-reload, down count
    
    while (!(*tcsr & 0x100));  // Wait for timeout
}

void main(void) {
    uartlite_puts("Microblaze-V Timer Test\n");
    
    for (int i = 0; i < 10; i++) {
        uartlite_puts("Timer tick ");
        uartlite_putc('0' + i);
        uartlite_puts("\n");
        
        timer_delay(50000000);  // ~0.5 second @ 100MHz
    }
    
    uartlite_puts("Timer test complete!\n");
    
    while (1);
}
