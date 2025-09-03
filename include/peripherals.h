#ifndef PERIPHERALS_H
#define PERIPHERALS_H

#include <stdint.h>

// Microblaze-V peripheral addresses
#define UARTLITE_BASE    0x40600000
#define UART16550_BASE   0x44A11000
#define TIMER_BASE       0x41C00000
#define GPIO_BASE        0x40000000

// UARTlite registers
#define UARTLITE_RX_FIFO  (UARTLITE_BASE + 0x00)
#define UARTLITE_TX_FIFO  (UARTLITE_BASE + 0x04)
#define UARTLITE_STAT_REG (UARTLITE_BASE + 0x08)
#define UARTLITE_CTRL_REG (UARTLITE_BASE + 0x0C)

// UARTlite status register bits
#define UARTLITE_SR_RX_FIFO_VALID_DATA  0x01
#define UARTLITE_SR_RX_FIFO_FULL        0x02
#define UARTLITE_SR_TX_FIFO_EMPTY       0x04
#define UARTLITE_SR_TX_FIFO_FULL        0x08

// Timer registers
#define TIMER_TCSR0      (TIMER_BASE + 0x00)
#define TIMER_TLR0       (TIMER_BASE + 0x04)
#define TIMER_TCR0       (TIMER_BASE + 0x08)

// Timer control bits
#define TIMER_CSR_ENABLE_TMR    0x00000080
#define TIMER_CSR_ENABLE_INT    0x00000040
#define TIMER_CSR_LOAD_TMR      0x00000020
#define TIMER_CSR_AUTO_RELOAD   0x00000010
#define TIMER_CSR_DOWN_COUNT    0x00000002

// Function prototypes
void uartlite_putc(char c);
void uartlite_puts(const char *str);
char uartlite_getc(void);
void timer_init(uint32_t reload_value);
uint32_t timer_read(void);
void delay_ms(uint32_t ms);

#endif
