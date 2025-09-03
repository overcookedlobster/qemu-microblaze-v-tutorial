#include <stdint.h>

#define UARTLITE_BASE    0x40600000
#define UARTLITE_TX_FIFO  (UARTLITE_BASE + 0x04)

void uartlite_putc(char c) {
    volatile uint32_t *tx_fifo = (volatile uint32_t *)UARTLITE_TX_FIFO;
    *tx_fifo = c;
}

void uartlite_puts(const char *str) {
    while (*str) {
        uartlite_putc(*str++);
    }
}

void main(void) {
    uartlite_puts("Hello, Microblaze-V World!\n");
    
    // Infinite loop
    while (1) {
        for (volatile int i = 0; i < 10000000; i++);
        uartlite_putc('.');
    }
}
