# QEMU Setup for Microblaze-V Development

This guide provides comprehensive instructions for setting up QEMU to run Microblaze-V programs, including both custom builds and system alternatives.

## Table of Contents
1. [QEMU Support Status](#qemu-support-status)
2. [System QEMU (Recommended)](#system-qemu-recommended)
3. [Custom QEMU Build](#custom-qemu-build)
4. [Running Programs](#running-programs)
5. [Troubleshooting](#troubleshooting)

## QEMU Support Status

### Current Status (2024)
- **QEMU Version Required**: 10.1.50+ for Microblaze-V support
- **Machine**: `amd-microblaze-v-generic`
- **Availability**: ⚠️ **May not be available in all builds**
- **Status**: Experimental/Development

### Checking Support
```bash
# Check if Microblaze-V is supported
qemu-system-riscv32 -machine help | grep microblaze

# Expected output (if supported):
# amd-microblaze-v-generic AMD Microblaze-V generic platform

# If no output: Microblaze-V not available in your QEMU build
```

## System QEMU (Recommended)

The easiest approach is to use the system-installed QEMU with standard RISC-V machines for development.

### Installation
```bash
# Ubuntu/Debian
sudo apt-get install qemu-system-riscv32 qemu-system-riscv64

# Fedora/CentOS
sudo dnf install qemu-system-riscv

# macOS
brew install qemu
```

### Verification
```bash
# Check QEMU version
qemu-system-riscv32 --version

# Check available RISC-V machines
qemu-system-riscv32 -machine help
```

### Available RISC-V Machines
```bash
# Standard RISC-V machines that work for development:
sifive_e             RISC-V Board compatible with SiFive E SDK
sifive_u             RISC-V Board compatible with SiFive U SDK
spike                RISC-V Spike board (default)
virt                 RISC-V VirtIO board (recommended for development)
```

## Custom QEMU Build

If you need the latest QEMU features or want to try Microblaze-V specific support, you can build QEMU from source.

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt-get install -y git libglib2.0-dev libfdt-dev libpixman-1-dev \
    zlib1g-dev libnfs-dev libiscsi-dev ninja-build build-essential \
    pkg-config python3-pip python3-venv meson

# Fedora/CentOS
sudo dnf install -y git glib2-devel libfdt-devel pixman-devel \
    zlib-devel libnfs-devel libiscsi-devel ninja-build gcc gcc-c++ \
    pkgconfig python3-pip python3-virtualenv meson

# macOS
brew install glib libfdt pixman ninja meson pkg-config
```

### Build Process
```bash
# Navigate to the submodule directory
cd qemu-microblaze-v

# Initialize submodules (this may take a while)
git submodule update --init --recursive

# Create build directory
mkdir -p build
cd build

# Configure with RISC-V targets (includes potential Microblaze-V support)
../configure --target-list=riscv32-softmmu,riscv64-softmmu --enable-debug

# Build (takes 10-30 minutes depending on system)
make -j$(nproc)

# Verify build
./qemu-system-riscv32 --version

# Check for Microblaze-V support
./qemu-system-riscv32 -machine help | grep microblaze
```

### Build Troubleshooting

#### Meson Build Failures
If you encounter meson build system errors:
```bash
# Clean and retry with minimal configuration
cd qemu-microblaze-v
rm -rf build
mkdir build
cd build

# Try minimal configuration
../configure --target-list=riscv32-softmmu --disable-docs --disable-gtk \
    --disable-sdl --disable-vnc --disable-spice

make -j$(nproc)
```

#### Missing Dependencies
```bash
# Install additional dependencies that might be missing
sudo apt-get install -y libncurses5-dev libncursesw5-dev libtinfo-dev \
    libgnutls28-dev libgcrypt20-dev

# For older systems, you might need:
sudo apt-get install -y python3-setuptools python3-wheel
```

#### Disk Space Issues
```bash
# QEMU build requires ~5GB of disk space
df -h .

# Clean up if needed
make clean
git clean -fdx  # WARNING: This removes all untracked files
```

## Running Programs

### Method 1: System QEMU with RISC-V Virt Machine (Recommended)
```bash
# Run with virt machine (most compatible)
qemu-system-riscv32 -M virt -cpu rv32 -m 128M -nographic -bios none \
    -device loader,addr=0x80000000,file=build/microblaze_v_demo,cpu-num=0

# Alternative with different load address
qemu-system-riscv32 -M virt -cpu rv32 -m 128M -nographic -bios none \
    -device loader,addr=0x00000000,file=build/microblaze_v_demo,cpu-num=0
```

### Method 2: Custom QEMU with Microblaze-V (If Available)
```bash
# Check if Microblaze-V machine is available
./qemu-microblaze-v/build/qemu-system-riscv32 -machine help | grep microblaze

# If available, run with Microblaze-V machine
./qemu-microblaze-v/build/qemu-system-riscv32 -M amd-microblaze-v-generic \
    -display none -serial stdio -monitor none \
    -device loader,addr=0x00000000,file=build/microblaze_v_demo,cpu-num=0
```

### Method 3: Spike Simulator
```bash
# Alternative: Use Spike RISC-V simulator
qemu-system-riscv32 -M spike -cpu rv32 -m 128M -nographic -bios none \
    -device loader,addr=0x80000000,file=build/microblaze_v_demo,cpu-num=0
```

### Makefile Integration

The project Makefile automatically detects available QEMU:
```makefile
# QEMU paths - try custom build first, fallback to system
QEMU_CUSTOM = qemu-microblaze-v/build/qemu-system-riscv32
QEMU_SYSTEM = qemu-system-riscv32
QEMU = $(shell if [ -f $(QEMU_CUSTOM) ]; then echo $(QEMU_CUSTOM); else echo $(QEMU_SYSTEM); fi)
```

Run with:
```bash
# Use detected QEMU
make run

# Force system QEMU
make run QEMU=qemu-system-riscv32

# Force custom QEMU
make run QEMU=./qemu-microblaze-v/build/qemu-system-riscv32
```

## Troubleshooting

### Issue 1: QEMU Microblaze-V Not Available
```bash
# Problem
qemu-system-riscv32: unsupported machine type 'amd-microblaze-v-generic'

# Solutions
1. Use standard RISC-V for development:
   qemu-system-riscv32 -machine virt -cpu rv32 -kernel program

2. Build QEMU from latest source (may still not include Microblaze-V)

3. Use Xilinx Vivado with actual Microblaze-V IP for hardware testing
```

### Issue 2: QEMU Hangs or Times Out
```bash
# Problem: QEMU starts but program doesn't run

# Solutions
1. Check load address:
   -device loader,addr=0x80000000,file=program  # Try different addresses

2. Verify program format:
   file build/microblaze_v_demo  # Should be ELF 32-bit RISC-V

3. Add debug output:
   qemu-system-riscv32 -d cpu,exec -M virt -cpu rv32 -nographic -bios none \
       -device loader,addr=0x80000000,file=program
```

### Issue 3: Missing BIOS Files
```bash
# Problem
qemu-system-riscv32: Unable to find the RISC-V BIOS "opensbi-riscv32-generic-fw_dynamic.bin"

# Solution: Disable BIOS
qemu-system-riscv32 -M virt -bios none -nographic \
    -device loader,addr=0x80000000,file=program
```

### Issue 4: Build Failures
```bash
# Problem: Custom QEMU build fails

# Solutions
1. Check dependencies:
   sudo apt-get install build-essential meson ninja-build

2. Use system QEMU instead:
   sudo apt-get install qemu-system-riscv32

3. Try Docker build:
   docker run -it --rm -v $(pwd):/work ubuntu:22.04
   # Install dependencies and build inside container
```

### Issue 5: Program Doesn't Output
```bash
# Problem: Program runs but no output visible

# Solutions
1. Check UART configuration in your program
2. Verify serial output:
   qemu-system-riscv32 -M virt -serial stdio -nographic ...

3. Add debug prints to your program
4. Check if program is actually running:
   qemu-system-riscv32 -d cpu -M virt ...
```

## Development Workflow

### Recommended Approach
1. **Start with System QEMU**: Use standard RISC-V development
2. **Target Microblaze-V Peripherals**: Write code for Microblaze-V addresses
3. **Test on Hardware**: Deploy to actual Microblaze-V in Xilinx FPGA
4. **Optimize**: Fine-tune for specific requirements

### Example Development Cycle
```bash
# 1. Develop and test with system QEMU
make clean && make all
make run  # Uses system QEMU with virt machine

# 2. Test with custom QEMU (if Microblaze-V available)
make run QEMU=./qemu-microblaze-v/build/qemu-system-riscv32

# 3. Deploy to hardware
# (Use Xilinx Vivado to program FPGA)
```

## Alternative Simulators

If QEMU doesn't work for your use case:

### Spike RISC-V Simulator
```bash
# Install Spike
git clone https://github.com/riscv/riscv-isa-sim.git
cd riscv-isa-sim
mkdir build && cd build
../configure --prefix=/opt/riscv
make && sudo make install

# Run program
spike --isa=rv32imafc program.elf
```

### Renode Framework
```bash
# Install Renode (supports various architectures)
wget https://github.com/renode/renode/releases/download/v1.14.0/renode_1.14.0_amd64.deb
sudo dpkg -i renode_1.14.0_amd64.deb

# Create platform script for Microblaze-V
# (Requires platform definition)
```

## Resources

### Official Documentation
- [QEMU RISC-V Documentation](https://qemu.readthedocs.io/en/latest/system/target-riscv.html)
- [AMD Microblaze-V User Guide](https://docs.amd.com/r/en-US/ug1629-microblaze-v-user-guide)
- [RISC-V ISA Specification](https://riscv.org/specifications/)

### Build Resources
- [QEMU Source Repository](https://gitlab.com/qemu-project/qemu)
- [QEMU Build Documentation](https://qemu.readthedocs.io/en/latest/devel/build-system.html)
- [Meson Build System](https://mesonbuild.com/)

### Alternative Tools
- [Spike RISC-V Simulator](https://github.com/riscv/riscv-isa-sim)
- [Renode Simulation Framework](https://renode.io/)
- [Xilinx Vivado Design Suite](https://www.xilinx.com/products/design-tools/vivado.html)

---

**Note**: Microblaze-V support in QEMU is experimental. For production development, consider using Xilinx Vivado with actual Microblaze-V IP cores, or develop with standard RISC-V and port to hardware later.

