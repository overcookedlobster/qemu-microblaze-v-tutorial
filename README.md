# AMD Microblaze-V QEMU Complete Tutorial & Examples

This directory contains a complete, working tutorial and examples for AMD Microblaze-V development using QEMU.

## 🎯 What's Included

- **Complete Tutorial**: `MICROBLAZE_V_COMPLETE_TUTORIAL.md` - Comprehensive guide
- **Working Code**: Fully functional project structure with examples
- **Build System**: Makefile and build scripts for easy compilation
- **Examples**: Simple programs demonstrating key features

## 📁 Directory Structure

```
microblaze-v-complete/
├── README.md                           # This file
├── MICROBLAZE_V_COMPLETE_TUTORIAL.md   # Complete tutorial
├── Makefile                            # Main build system
├── src/                                # Source code
│   ├── start.s                         # Assembly startup (CRITICAL!)
│   ├── main.c                          # Main application
│   └── peripherals.c                   # Peripheral drivers
├── include/                            # Header files
│   └── peripherals.h                   # Peripheral definitions
├── linker/                             # Linker scripts
│   └── microblaze_v.ld                 # Memory layout
├── build/                              # Build output (created by make)
└── examples/                           # Example programs
    ├── hello_world.c                   # Simple hello world
    ├── timer_test.c                    # Timer demonstration
    └── build_examples.sh               # Build script for examples
```

## 🚀 Quick Start

### 1. Prerequisites
Make sure you have QEMU with Microblaze-V support built (see tutorial for details).

### 2. Build the Main Demo
```bash
cd microblaze-v-complete
make
```

### 3. Run the Demo
```bash
make run
```

You should see output like:
```
Microblaze-V System Starting...
QEMU Platform Test
==================

Testing UARTlite...
Hello from Microblaze-V!
Testing timer delays...
Tick 0
Tick 1
...
```

### 4. Build and Run Examples
```bash
cd examples
./build_examples.sh

# Run hello world
../qemu-microblaze-v/build/qemu-system-riscv32 -M amd-microblaze-v-generic -display none -serial stdio -monitor none -device loader,addr=0x00000000,file=hello_world,cpu-num=0

# Run timer test
../qemu-microblaze-v/build/qemu-system-riscv32 -M amd-microblaze-v-generic -display none -serial stdio -monitor none -device loader,addr=0x00000000,file=timer_test,cpu-num=0
```

## 🔧 Key Technical Points

### Critical Success Factor: Entry Point
The **most important** aspect for success is ensuring `_start` is at address `0x00000000`. This is achieved by:

1. **Assembly startup file** (`src/start.s`) that puts `_start` first
2. **Proper linking** with the provided linker script
3. **Correct compilation** order (start.s must be first object)

### QEMU Command Format
```bash
qemu-system-riscv32 -M amd-microblaze-v-generic \
    -display none -serial stdio -monitor none \
    -device loader,addr=0x00000000,file=program,cpu-num=0
```

### Compilation Flags
```bash
riscv64-unknown-elf-gcc -march=rv32imafc -mabi=ilp32f -nostdlib
```

## 🐛 Troubleshooting

### No Output from Program
**Cause**: Entry point not at address 0x00000000
**Solution**: Use the provided `start.s` file and link it first

### "Machine not found" Error
**Cause**: QEMU doesn't have Microblaze-V support
**Solution**: Build QEMU from source (see tutorial)

### Compilation Errors
**Cause**: Wrong toolchain or flags
**Solution**: Use `riscv64-unknown-elf-gcc` with correct flags

## 📚 Learning Path

1. **Start with the tutorial**: Read `MICROBLAZE_V_COMPLETE_TUTORIAL.md`
2. **Build the main demo**: Use `make` and `make run`
3. **Try examples**: Build and run simple examples
4. **Modify code**: Experiment with the peripheral drivers
5. **Create your own**: Use the project structure as a template

## ✅ Verified Working

This tutorial and code has been tested and verified working with:
- **QEMU**: 10.1.50+ with Microblaze-V support
- **Toolchain**: riscv64-unknown-elf-gcc
- **Platform**: `amd-microblaze-v-generic`
- **Peripherals**: UARTlite, Timer, GPIO (basic functionality)

## 🎉 Success Indicators

When everything is working correctly, you should see:
- ✅ Immediate text output from UARTlite
- ✅ Continuous program execution
- ✅ Proper peripheral communication
- ✅ Real-time heartbeat or status messages

If you see blank output or no response, check the entry point issue first!

---

**Happy Microblaze-V Development!** 🚀
