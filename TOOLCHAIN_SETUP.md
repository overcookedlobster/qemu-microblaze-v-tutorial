# RISC-V GNU Toolchain Setup

This project includes the RISC-V GNU toolchain as a git submodule for cross-compilation to RISC-V targets.

## Prerequisites

Before building the toolchain, ensure you have the following dependencies installed:

### Ubuntu/Debian
```bash
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev
```

### CentOS/RHEL/Fedora
```bash
sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

### macOS
```bash
brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock
```

## Installation Steps

### 1. Clone the Repository with Submodules
```bash
git clone --recursive https://github.com/your-username/microblaze-v-complete.git
cd microblaze-v-complete
```

If you already cloned without `--recursive`, initialize the submodule:
```bash
git submodule update --init --recursive
```

### 2. Build the Toolchain
```bash
# Navigate to the toolchain directory
cd toolchain/riscv-gnu-toolchain

# Configure for 32-bit RISC-V with multilib support
./configure --prefix=$(pwd)/../install --with-arch=rv32gc --with-abi=ilp32d --enable-multilib

# Build the toolchain (this will take 30-60 minutes)
make -j$(nproc)
```

### 3. Verify Installation
After the build completes, verify the toolchain is working:
```bash
# Check if the compiler is available
../install/bin/riscv64-unknown-elf-gcc --version

# Should output something like:
# riscv64-unknown-elf-gcc (gc891d8dc23e) 13.2.0
```

### 4. Build the Project
Now you can build the Microblaze-V project:
```bash
# Return to project root
cd ../..

# Build the project
make all
```

## Toolchain Structure

After installation, the toolchain will be located at:
```
toolchain/
├── riscv-gnu-toolchain/     # Submodule with source code
└── install/                 # Built toolchain binaries
    └── bin/
        ├── riscv64-unknown-elf-gcc
        ├── riscv64-unknown-elf-objdump
        ├── riscv64-unknown-elf-objcopy
        └── ... (other tools)
```

## Makefile Integration

The project Makefile is configured to use the local toolchain:
```makefile
TOOLCHAIN_PREFIX = toolchain/install/bin/riscv64-unknown-elf-
CC = $(TOOLCHAIN_PREFIX)gcc
OBJDUMP = $(TOOLCHAIN_PREFIX)objdump
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
```

## Troubleshooting

### Build Fails with Missing Dependencies
- Ensure all prerequisites are installed for your OS
- On some systems, you may need to install additional packages like `libssl-dev`

### Permission Errors
- Make sure you have write permissions in the project directory
- Avoid using `sudo` when building the toolchain

### Out of Disk Space
- The toolchain build requires ~5GB of disk space
- Clean up unnecessary files or use a different build location

### Slow Build Times
- Use `make -j$(nproc)` to utilize all CPU cores
- Consider using a faster storage device (SSD)

## Alternative: Using System Toolchain

If you prefer to use a system-installed toolchain instead:

1. Install via package manager:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install gcc-riscv64-unknown-elf

   # Fedora
   sudo dnf install riscv64-gnu-toolchain
   ```

2. Update the Makefile to use system paths:
   ```makefile
   TOOLCHAIN_PREFIX = riscv64-unknown-elf-
   ```

## Updating the Toolchain

To update the toolchain to a newer version:
```bash
cd toolchain/riscv-gnu-toolchain
git pull origin master
cd ..
rm -rf install
cd riscv-gnu-toolchain
make clean
./configure --prefix=$(pwd)/../install --with-arch=rv32gc --with-abi=ilp32d --enable-multilib
make -j$(nproc)
```

