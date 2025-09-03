# AMD Microblaze-V QEMU Complete Tutorial

## Table of Contents
1. [What is Microblaze-V?](#what-is-microblaze-v)
2. [Architecture Overview](#architecture-overview)
3. [Building QEMU with Microblaze-V Support](#building-qemu-with-microblaze-v-support)
4. [Development Environment Setup](#development-environment-setup)
5. [Programming Examples](#programming-examples)
6. [Hardware Interfaces](#hardware-interfaces)
7. [Common Issues and Solutions](#common-issues-and-solutions)
8. [Advanced Topics](#advanced-topics)
9. [Resources](#resources)

## What is Microblaze-V?

**AMD Microblaze-V** is a 32-bit soft processor core based on the open RISC-V instruction set architecture (ISA). It's designed as a drop-in replacement for the classic Microblaze processor in AMD FPGA designs.

### Key Features:
- **RISC-V ISA**: Based on RV32IMAFC with extensions
- **Microblaze Compatible**: Same interfaces and peripherals as classic Microblaze
- **Soft Core**: Implemented in FPGA fabric (Zynq, Kintex, Virtex series)
- **Drop-in Replacement**: Maintains compatibility with existing Microblaze designs

### Why Microblaze-V?
1. **Open Standard**: RISC-V is an open ISA vs. proprietary Microblaze
2. **Ecosystem**: Access to growing RISC-V software ecosystem
3. **Future-Proof**: Based on industry-standard RISC-V
4. **Compatibility**: Maintains Microblaze peripheral interfaces

## Architecture Overview

### ISA Specifications
- **Base**: RV32I (32-bit integer instructions)
- **Extensions**:
  - **M**: Integer multiplication and division
  - **A**: Atomic instructions
  - **F**: Single-precision floating-point
  - **C**: Compressed instructions
  - **Zicsr**: Control and Status Register instructions
  - **Zifencei**: Instruction-fetch fence

### Memory Map (QEMU Implementation)
```
0x00000000 - 0x0001FFFF : LMB BRAM (128 KB)
0x40000000 - 0x4FFFFFFF : Peripheral space
0x80000000 - 0xFFFFFFFF : DDR memory
```

### Supported Peripherals
- **UART**: Xilinx UARTlite and 16550 compatible
- **Timer**: Xilinx XPS Timer
- **Ethernet**: Xilinx Ethernetlite and AXI Ethernet
- **DMA**: AXI DMA controller
- **GPIO**: General Purpose I/O
- **I2C**: Inter-Integrated Circuit
- **SPI/QSPI**: Serial Peripheral Interface

## Building QEMU with Microblaze-V Support

### Prerequisites
```bash
sudo apt update
sudo apt install -y git libglib2.0-dev libfdt-dev libpixman-1-dev \
    zlib1g-dev libnfs-dev libiscsi-dev ninja-build build-essential \
    pkg-config python3-pip python3-venv meson
```

### Build Process
```bash
# Clone QEMU source
git clone --depth 1 https://gitlab.com/qemu-project/qemu.git qemu-microblaze-v
cd qemu-microblaze-v

# Configure with RISC-V targets (includes Microblaze-V)
./configure --target-list=riscv32-softmmu,riscv64-softmmu --enable-debug

# Build (takes 10-20 minutes)
ninja -C build

# Verify Microblaze-V support
./build/qemu-system-riscv32 -machine help | grep microblaze
# Expected output: amd-microblaze-v-generic AMD Microblaze-V generic platform
```

## Development Environment Setup

### Toolchain Setup
Microblaze-V uses standard RISC-V tools:

```bash
# Install RISC-V toolchain
sudo apt install gcc-riscv64-unknown-elf

# Or build from source
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32imafc --with-abi=ilp32f
make
```

### Project Structure
Create this directory structure for your projects:
```
microblaze-v-project/
├── src/
│   ├── start.s          # Assembly startup file
│   ├── main.c           # Main C program
│   └── peripherals.c    # Peripheral drivers
├── include/
│   └── peripherals.h    # Header files
├── linker/
│   └── microblaze_v.ld  # Linker script
└── Makefile             # Build configuration
```

## Programming Examples

### 1. Assembly Startup File

**File: `src/start.s`**
```assembly
.section .text
.global _start

_start:
    # Set up stack pointer
    la sp, _stack_top
    
    # Jump to main C function
    call main
    
    # If main returns, infinite loop
1:  j 1b

.section .bss
.align 4
stack:
    .space 4096
_stack_top:
```

### 2. Linker Script

**File: `linker/microblaze_v.ld`**
```ld
MEMORY {
    BRAM : ORIGIN = 0x00000000, LENGTH = 128K
    DDR  : ORIGIN = 0x80000000, LENGTH = 2G
}

SECTIONS {
    .text : {
        *(.text)
        *(.text.*)
    } > BRAM
    
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    } > BRAM
    
    .data : {
        *(.data)
        *(.data.*)
    } > BRAM
    
    .bss : {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    } > BRAM
    
    /* Stack grows down from end of BRAM */
    _stack_top = ORIGIN(BRAM) + LENGTH(BRAM);
}
```

### 3. UARTlite Driver

**File: `include/peripherals.h`**
```c
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
```

**File: `src/peripherals.c`**
```c
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
```

### 4. Main Application

**File: `src/main.c`**
```c
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
```

### 5. Build System

**File: `Makefile`**
```makefile
# Microblaze-V Makefile

# Toolchain
CC = riscv64-unknown-elf-gcc
OBJDUMP = riscv64-unknown-elf-objdump
OBJCOPY = riscv64-unknown-elf-objcopy

# Flags
CFLAGS = -march=rv32imafc -mabi=ilp32f -nostdlib -Iinclude
LDFLAGS = -T linker/microblaze_v.ld

# Directories
SRCDIR = src
INCDIR = include
BUILDDIR = build

# Source files
ASM_SOURCES = $(SRCDIR)/start.s
C_SOURCES = $(SRCDIR)/main.c $(SRCDIR)/peripherals.c

# Object files
ASM_OBJECTS = $(ASM_SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
C_OBJECTS = $(C_SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)
OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS)

# Target
TARGET = $(BUILDDIR)/microblaze_v_demo

# QEMU path (adjust as needed)
QEMU = ../qemu-microblaze-v/build/qemu-system-riscv32

.PHONY: all clean run disasm

all: $(TARGET)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(TARGET): $(BUILDDIR) $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/%.o: $(SRCDIR)/%.s
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILDDIR)

run: $(TARGET)
	$(QEMU) -M amd-microblaze-v-generic \
		-display none -serial stdio -monitor none \
		-device loader,addr=0x00000000,file=$(TARGET),cpu-num=0

disasm: $(TARGET)
	$(OBJDUMP) -d $(TARGET)

help:
	@echo "Available targets:"
	@echo "  all     - Build the project"
	@echo "  clean   - Clean build files"
	@echo "  run     - Run in QEMU"
	@echo "  disasm  - Show disassembly"
	@echo "  help    - Show this help"
```

## Hardware Interfaces

### UARTlite Interface Details

The UARTlite is the primary debug/console interface in Microblaze-V:

```c
// UARTlite register structure
typedef struct {
    volatile uint32_t rx_fifo;    // 0x00 - Receive FIFO
    volatile uint32_t tx_fifo;    // 0x04 - Transmit FIFO  
    volatile uint32_t status;     // 0x08 - Status register
    volatile uint32_t control;    // 0x0C - Control register
} uartlite_t;

// Usage example
uartlite_t *uart = (uartlite_t *)UARTLITE_BASE;

// Check if data available
if (uart->status & UARTLITE_SR_RX_FIFO_VALID_DATA) {
    char c = uart->rx_fifo;
}

// Send data
if (!(uart->status & UARTLITE_SR_TX_FIFO_FULL)) {
    uart->tx_fifo = 'A';
}
```

### Timer Interface Details

```c
// XPS Timer structure
typedef struct {
    volatile uint32_t tcsr0;      // 0x00 - Timer Control/Status Register 0
    volatile uint32_t tlr0;       // 0x04 - Timer Load Register 0
    volatile uint32_t tcr0;       // 0x08 - Timer Counter Register 0
    volatile uint32_t tcsr1;      // 0x10 - Timer Control/Status Register 1
    volatile uint32_t tlr1;       // 0x14 - Timer Load Register 1
    volatile uint32_t tcr1;       // 0x18 - Timer Counter Register 1
} xps_timer_t;

// Usage example
xps_timer_t *timer = (xps_timer_t *)TIMER_BASE;

// Configure timer for 1 second @ 100MHz
timer->tlr0 = 100000000;  // 100M cycles = 1 second
timer->tcsr0 = TIMER_CSR_ENABLE_TMR | TIMER_CSR_AUTO_RELOAD | TIMER_CSR_DOWN_COUNT;

// Wait for timeout
while (!(timer->tcsr0 & 0x100));  // Wait for T0INT bit
```

## Common Issues and Solutions

### Issue 1: No Output from UARTlite

**Problem**: Program compiles but produces no output.

**Cause**: Entry point not at address 0x00000000.

**Solution**: Use proper assembly startup file:
```assembly
.section .text
.global _start

_start:
    la sp, _stack_top
    call main
1:  j 1b
```

### Issue 2: Program Doesn't Start

**Problem**: QEMU runs but program doesn't execute.

**Debugging Steps**:
```bash
# Check if _start is at address 0
riscv64-unknown-elf-objdump -d your_program | head -10

# Use QEMU tracing to see execution
qemu-system-riscv32 -M amd-microblaze-v-generic -d exec -D trace.log ...

# Check trace.log for execution addresses
```

### Issue 3: Compilation Errors

**Problem**: Wrong architecture flags.

**Solution**: Use correct RISC-V flags:
```bash
riscv64-unknown-elf-gcc -march=rv32imafc -mabi=ilp32f -nostdlib
```

### Issue 4: Serial Console Issues

**Problem**: Cannot see output or input.

**Solution**: Use correct QEMU serial configuration:
```bash
qemu-system-riscv32 -M amd-microblaze-v-generic \
    -display none -serial stdio -monitor none \
    -device loader,addr=0x00000000,file=program,cpu-num=0
```

## Advanced Topics

### Interrupt Handling

```c
// Interrupt vector table (simplified)
void interrupt_handler(void) __attribute__((interrupt));

void interrupt_handler(void) {
    // Handle timer interrupt
    volatile uint32_t *tcsr = (volatile uint32_t *)TIMER_TCSR0;
    if (*tcsr & 0x100) {
        // Timer interrupt occurred
        uartlite_puts("Timer interrupt!\n");
        *tcsr &= ~0x100;  // Clear interrupt
    }
}
```

### Memory Management

```c
// Access different memory regions
void memory_test(void) {
    // BRAM access (fast, limited size)
    volatile uint32_t *bram = (volatile uint32_t *)0x00010000;
    *bram = 0xDEADBEEF;
    
    // DDR access (slower, large size)
    volatile uint32_t *ddr = (volatile uint32_t *)0x80000000;
    *ddr = 0xCAFEBABE;
    
    uartlite_puts("Memory test complete\n");
}
```

### Performance Optimization

```c
// Use compiler attributes for optimization
__attribute__((always_inline))
static inline void fast_delay(int cycles) {
    for (volatile int i = 0; i < cycles; i++) {
        asm("nop");
    }
}

// Use RISC-V specific instructions
void atomic_increment(volatile uint32_t *ptr) {
    asm volatile (
        "amoadd.w zero, %1, (%0)"
        :
        : "r" (ptr), "r" (1)
        : "memory"
    );
}
```

## Running Your Programs

### Basic Execution
```bash
# Compile
make

# Run in QEMU
make run

# Or manually:
qemu-system-riscv32 -M amd-microblaze-v-generic \
    -display none -serial stdio -monitor none \
    -device loader,addr=0x00000000,file=build/microblaze_v_demo,cpu-num=0
```

### Debugging
```bash
# Run with GDB support
qemu-system-riscv32 -M amd-microblaze-v-generic \
    -display none -serial stdio -monitor none \
    -device loader,addr=0x00000000,file=program,cpu-num=0 \
    -s -S

# In another terminal
riscv64-unknown-elf-gdb program
(gdb) target remote :1234
(gdb) continue
```

### Performance Analysis
```bash
# Run with performance counters
qemu-system-riscv32 -M amd-microblaze-v-generic \
    -display none -serial stdio -monitor none \
    -device loader,addr=0x00000000,file=program,cpu-num=0 \
    -d cpu,exec -D performance.log
```

## Migration from Classic Microblaze

### Code Changes Required

#### 1. Instruction Set Differences
```c
// Classic Microblaze
asm("bri label");           // Branch immediate
asm("addik r1, r1, -4");    // Add immediate keep carry

// Microblaze-V (RISC-V)
asm("j label");             // Jump
asm("addi sp, sp, -4");     // Add immediate (sp = x2)
```

#### 2. Register Names
```c
// Classic Microblaze registers: r0-r31
// Microblaze-V uses RISC-V ABI names:
// x0 (zero), x1 (ra), x2 (sp), x3 (gp), x4 (tp)
// x5-x7 (t0-t2), x8-x9 (s0-s1), x10-x17 (a0-a7)
// x18-x27 (s2-s11), x28-x31 (t3-t6)
```

#### 3. Build System Changes
```makefile
# Classic Microblaze
CC = mb-gcc
CFLAGS = -mcpu=v11.0 -mxl-soft-mul

# Microblaze-V
CC = riscv64-unknown-elf-gcc
CFLAGS = -march=rv32imafc -mabi=ilp32f
```

### Peripheral Compatibility
- **UARTlite**: ✅ Fully compatible
- **Timer**: ✅ Fully compatible  
- **GPIO**: ✅ Fully compatible
- **Ethernet**: ✅ Fully compatible
- **Custom IP**: ⚠️ May require updates

## Resources

### Official Documentation
- [AMD Microblaze-V User Guide](https://docs.amd.com/r/en-US/ug1629-microblaze-v-user-guide)
- [RISC-V ISA Specification](https://riscv.org/specifications/)
- [QEMU Documentation](https://qemu.readthedocs.io/en/latest/)

### Development Tools
- [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain)
- [Xilinx Vivado Design Suite](https://www.xilinx.com/products/design-tools/vivado.html)
- [Xilinx Vitis Unified Software Platform](https://www.xilinx.com/products/design-tools/vitis.html)

### Community Resources
- [RISC-V International](https://riscv.org/)
- [AMD Developer Zone](https://developer.amd.com/)
- [Xilinx Community Forums](https://support.xilinx.com/s/topic/0TO2E000000YKYAWA4/embedded-development)

---

**Note**: This tutorial is based on QEMU 10.1.50+ with Microblaze-V support. The `amd-microblaze-v-generic` machine provides a complete development environment for Microblaze-V software development and testing.