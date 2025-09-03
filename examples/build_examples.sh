#!/bin/bash

# Build script for Microblaze-V examples

CC=riscv64-unknown-elf-gcc
CFLAGS="-march=rv32imafc -mabi=ilp32f -nostdlib"
LDFLAGS="-T ../linker/microblaze_v.ld"

echo "Building Microblaze-V examples..."

# Build hello world
echo "Building hello_world..."
$CC $CFLAGS $LDFLAGS -o hello_world ../src/start.s hello_world.c
if [ $? -eq 0 ]; then
    echo "✓ hello_world built successfully"
else
    echo "✗ hello_world build failed"
fi

# Build timer test
echo "Building timer_test..."
$CC $CFLAGS $LDFLAGS -o timer_test ../src/start.s timer_test.c
if [ $? -eq 0 ]; then
    echo "✓ timer_test built successfully"
else
    echo "✗ timer_test build failed"
fi

echo ""
echo "To run examples:"
echo "  ../qemu-microblaze-v/build/qemu-system-riscv32 -M amd-microblaze-v-generic -display none -serial stdio -monitor none -device loader,addr=0x00000000,file=hello_world,cpu-num=0"
echo "  ../qemu-microblaze-v/build/qemu-system-riscv32 -M amd-microblaze-v-generic -display none -serial stdio -monitor none -device loader,addr=0x00000000,file=timer_test,cpu-num=0"
