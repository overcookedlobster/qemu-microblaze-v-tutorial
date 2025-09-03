#include "peripherals.h"

void uartlite_putc(char c) {
    volatile uint32_t *tx_fifo = (volatile uint32_t *)UARTLITE_TX_FIFO;
    volatile uint32_t *status = (volatile uint32_t *)UARTLITE_STAT_REG;
    
    // Wait for TX FIFO not full (bit 3 = 0)
    while (*status & UARTLITE_SR_TX_FIFO_FULL);
    
    *tx_fifo = c;
}

void uartlite_puts(const char *str) {
    while (*str) {
        uartlite_putc(*str++);
    }
}

char uartlite_getc(void) {
    volatile uint32_t *rx_fifo = (volatile uint32_t *)UARTLITE_RX_FIFO;
    volatile uint32_t *status = (volatile uint32_t *)UARTLITE_STAT_REG;
    
    // Wait for RX FIFO valid data (bit 0 = 1)
    while (!(*status & UARTLITE_SR_RX_FIFO_VALID_DATA));
    
    return (char)*rx_fifo;
}

void timer_init(uint32_t reload_value) {
    volatile uint32_t *tcsr = (volatile uint32_t *)TIMER_TCSR0;
    volatile uint32_t *tlr = (volatile uint32_t *)TIMER_TLR0;
    
    *tlr = reload_value;           // Set reload value
    *tcsr = TIMER_CSR_ENABLE_TMR | TIMER_CSR_AUTO_RELOAD | TIMER_CSR_DOWN_COUNT;
}

uint32_t timer_read(void) {
    volatile uint32_t *tcr = (volatile uint32_t *)TIMER_TCR0;
    return *tcr;
}

void delay_ms(uint32_t ms) {
    // Assuming 100MHz clock, adjust as needed
    uint32_t cycles = ms * 100000;
    timer_init(cycles);
    
    volatile uint32_t *tcsr = (volatile uint32_t *)TIMER_TCSR0;
    while (!(*tcsr & 0x00000100));  // Wait for timeout
}
