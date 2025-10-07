#!/bin/bash
# Build script for debug example

set -e

echo "Building MicroBlaze-V Debug Example..."

# Check if toolchain is available
if ! command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
    echo "Error: riscv64-unknown-elf-gcc not found"
    echo "Please install the RISC-V toolchain"
    exit 1
fi

# Toolchain
CC=riscv64-unknown-elf-gcc
OBJDUMP=riscv64-unknown-elf-objdump

# Flags
CFLAGS="-march=rv32imafc -mabi=ilp32f -nostdlib -I../include -g -O0"
LDFLAGS="-T ../linker/microblaze_v.ld"

# Create build directory
mkdir -p build

echo "Compiling debug example..."

# Compile assembly startup
$CC $CFLAGS -c ../src/start.s -o build/start.o

# Compile peripherals
$CC $CFLAGS -c ../src/peripherals.c -o build/peripherals.o

# Compile debug example
$CC $CFLAGS -c debug_example.c -o build/debug_example.o

# Link everything
$CC $CFLAGS $LDFLAGS -o build/debug_example build/start.o build/peripherals.o build/debug_example.o

echo "Debug example built successfully!"
echo "Binary: examples/build/debug_example"

# Generate disassembly for reference
echo "Generating disassembly..."
$OBJDUMP -d build/debug_example > build/debug_example.dis
echo "Disassembly: examples/build/debug_example.dis"

echo ""
echo "To run with debugging:"
echo "1. Terminal 1: ../qemu-microblaze-v/build/qemu-system-riscv32 -M amd-microblaze-v-generic -display none -serial stdio -monitor none -device loader,addr=0x00000000,file=build/debug_example,cpu-num=0 -s -S"
echo "2. Terminal 2: riscv64-unknown-elf-gdb -x ../debug_microblaze_v.gdb build/debug_example"
echo ""
echo "Or use the Makefile targets:"
echo "make run-debug-example"
echo "make debug-example"
