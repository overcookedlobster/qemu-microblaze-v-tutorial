#include "peripherals.h"

void main(void) {
    // Initialize system
    uartlite_puts("Microblaze-V System Starting...\n");
    uartlite_puts("QEMU Platform Test\n");
    uartlite_puts("==================\n\n");
    
    // Test UARTlite
    uartlite_puts("Testing UARTlite...\n");
    uartlite_puts("Hello from Microblaze-V!\n");
    
    // Test timer
    uartlite_puts("Testing timer delays...\n");
    for (int i = 0; i < 5; i++) {
        uartlite_puts("Tick ");
        uartlite_putc('0' + i);
        uartlite_puts("\n");
        
        // Simple delay (not using timer for simplicity)
        for (volatile int j = 0; j < 5000000; j++);
    }
    
    uartlite_puts("\nMicroblaze-V Demo Complete!\n");
    uartlite_puts("Running heartbeat...\n\n");
    
    // Main application loop
    int heartbeat = 0;
    while (1) {
        uartlite_puts("Heartbeat: ");
        uartlite_putc('0' + (heartbeat % 10));
        uartlite_puts("\n");
        
        // Delay
        for (volatile int i = 0; i < 10000000; i++);
        heartbeat++;
    }
}
