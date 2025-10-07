/*
 * MicroBlaze-V Debug Example
 * This example demonstrates various debugging scenarios
 * that can be tested with the GDB script
 */

#include "../include/peripherals.h"

// Global variables for debugging
static int debug_counter = 0;
static char debug_buffer[64];

// Function with potential issues for debugging
void problematic_function(int value) {
    // This function has intentional issues for debugging practice

    if (value < 0) {
        uartlite_puts("Error: Negative value!\n");
        return;
    }

    // Potential buffer overflow (for debugging)
    for (int i = 0; i <= value && i < 64; i++) {
        debug_buffer[i] = 'A' + (i % 26);
    }

    debug_counter += value;

    uartlite_puts("Debug buffer: ");
    for (int i = 0; i < value && i < 64; i++) {
        uartlite_putc(debug_buffer[i]);
    }
    uartlite_puts("\n");
}

// Function that uses timer
void timer_debug_test(void) {
    uartlite_puts("Testing timer functionality...\n");

    // Initialize timer with a known value
    timer_init(1000000);  // 1 second at 100MHz

    uartlite_puts("Timer initialized\n");

    // Read timer value multiple times
    for (int i = 0; i < 5; i++) {
        uint32_t timer_val = timer_read();
        uartlite_puts("Timer value: ");

        // Simple hex output (for debugging)
        char hex_str[9];
        for (int j = 7; j >= 0; j--) {
            int nibble = (timer_val >> (j * 4)) & 0xF;
            hex_str[7-j] = (nibble < 10) ? ('0' + nibble) : ('A' + nibble - 10);
        }
        hex_str[8] = '\0';

        uartlite_puts(hex_str);
        uartlite_puts("\n");

        // Small delay
        for (volatile int k = 0; k < 1000000; k++);
    }
}

// Function with nested calls for stack debugging
void nested_function_level3(int depth) {
    uartlite_puts("Level 3: depth = ");
    uartlite_putc('0' + depth);
    uartlite_puts("\n");

    // This is where we might want to examine the call stack
    debug_counter += depth * 3;
}

void nested_function_level2(int depth) {
    uartlite_puts("Level 2: depth = ");
    uartlite_putc('0' + depth);
    uartlite_puts("\n");

    debug_counter += depth * 2;
    nested_function_level3(depth + 1);
}

void nested_function_level1(int depth) {
    uartlite_puts("Level 1: depth = ");
    uartlite_putc('0' + depth);
    uartlite_puts("\n");

    debug_counter += depth;
    nested_function_level2(depth + 1);
}

// Main function for debug example
void main(void) {
    uartlite_puts("MicroBlaze-V Debug Example Starting...\n");
    uartlite_puts("=====================================\n\n");

    // Test 1: Basic UART debugging
    uartlite_puts("Test 1: Basic UART Communication\n");
    uartlite_puts("This tests basic UART functionality\n\n");

    // Test 2: Function with potential issues
    uartlite_puts("Test 2: Problematic Function\n");
    problematic_function(5);
    problematic_function(-1);  // This should trigger error handling
    problematic_function(10);
    uartlite_puts("\n");

    // Test 3: Timer debugging
    uartlite_puts("Test 3: Timer Debugging\n");
    timer_debug_test();
    uartlite_puts("\n");

    // Test 4: Nested function calls (stack debugging)
    uartlite_puts("Test 4: Nested Function Calls\n");
    nested_function_level1(1);
    uartlite_puts("\n");

    // Test 5: Loop with counter (for breakpoint testing)
    uartlite_puts("Test 5: Loop with Counter\n");
    for (int i = 0; i < 10; i++) {
        uartlite_puts("Loop iteration: ");
        uartlite_putc('0' + i);
        uartlite_puts(", debug_counter = ");

        // Simple decimal output
        if (debug_counter >= 100) {
            uartlite_putc('0' + (debug_counter / 100));
            debug_counter %= 100;
        }
        if (debug_counter >= 10) {
            uartlite_putc('0' + (debug_counter / 10));
            debug_counter %= 10;
        }
        uartlite_putc('0' + debug_counter);
        uartlite_puts("\n");

        // Delay for observation
        for (volatile int j = 0; j < 2000000; j++);
    }

    uartlite_puts("\nDebug Example Complete!\n");
    uartlite_puts("Final debug_counter value: ");
    uartlite_putc('0' + (debug_counter % 10));
    uartlite_puts("\n\n");

    // Infinite loop for continuous debugging
    uartlite_puts("Entering infinite loop for debugging...\n");
    int loop_count = 0;
    while (1) {
        uartlite_puts("Debug loop: ");
        uartlite_putc('0' + (loop_count % 10));
        uartlite_puts("\n");

        loop_count++;

        // Long delay
        for (volatile int i = 0; i < 10000000; i++);
    }
}
