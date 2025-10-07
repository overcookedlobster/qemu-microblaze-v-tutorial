# RISC-V GDB Build Guide for MicroBlaze-V Development

This guide provides comprehensive instructions for building `riscv64-unknown-elf-gdb` from source to achieve optimal debugging experience with the MicroBlaze-V development environment.

## Ì†ºÌæØ Overview

While `gdb-multiarch` provides excellent compatibility as a fallback, building the dedicated RISC-V GDB debugger offers:

- **Optimal Performance**: Native RISC-V target support
- **Enhanced Features**: RISC-V specific debugging capabilities
- **Professional Setup**: Industry-standard toolchain completion
- **Future Compatibility**: Latest RISC-V debugging features

## Ì†ΩÌ∫Ä Quick Setup (Recommended)

The project includes an automated setup script that handles GDB detection and fallback:

```bash
# Configure optimal GDB (run once)
make setup-gdb

# Use in debugging (automatic detection)
make debug
```

## Ì†ΩÌ≥ã Prerequisites

### System Requirements
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y \
    build-essential \
    texinfo \
    libreadline-dev \
    libncurses5-dev \
    libncursesw5-dev \
    zlib1g-dev \
    libexpat1-dev \
    python3-dev \
    git \
    wget

# CentOS/RHEL/Fedora
sudo dnf install -y \
    gcc gcc-c++ make \
    texinfo \
    readline-devel \
    ncurses-devel \
    zlib-devel \
    expat-devel \
    python3-devel \
    git \
    wget
```

### Disk Space
- **Source Code**: ~800MB
- **Build Directory**: ~1.5GB
- **Installation**: ~200MB
- **Total Required**: ~2.5GB

## Ì†ΩÌ¥ß Building from Source

### Method 1: Official GNU GDB Repository (Recommended)

```bash
# Navigate to project root
cd /path/to/microblaze-v-complete

# Create tools directory
mkdir -p tools
cd tools

# Clone official GDB repository
git clone --depth 1 --branch master \
    https://sourceware.org/git/binutils-gdb.git riscv-gdb

cd riscv-gdb

# Create and enter build directory
mkdir build && cd build

# Configure for RISC-V target
../configure \
    --target=riscv64-unknown-elf \
    --prefix=$(pwd)/../../riscv-gdb-install \
    --enable-multilib \
    --enable-interwork \
    --enable-languages=c,c++ \
    --disable-werror \
    --with-system-readline \
    --with-expat \
    --with-python=python3

# Build (adjust -j based on CPU cores)
make -j$(nproc)

# Install to local directory
make install

# Verify installation
../../riscv-gdb-install/bin/riscv64-unknown-elf-gdb --version
```

### Method 2: GNU FTP Release (Alternative)

```bash
# Navigate to tools directory
cd tools

# Download latest stable release
wget https://ftp.gnu.org/gnu/gdb/gdb-15.1.tar.xz
tar -xf gdb-15.1.tar.xz
cd gdb-15.1

# Create build directory
mkdir build && cd build

# Configure and build (same as Method 1)
../configure \
    --target=riscv64-unknown-elf \
    --prefix=$(pwd)/../../riscv-gdb-install \
    --enable-multilib \
    --enable-interwork \
    --enable-languages=c,c++ \
    --disable-werror \
    --with-system-readline \
    --with-expat \
    --with-python=python3

make -j$(nproc)
make install
```

## ‚öôÔ∏è Integration with Project

### Automatic Setup (Recommended)

```bash
# Run the setup script (detects and configures optimal GDB)
make setup-gdb

# The script will:
# 1. Detect locally built riscv64-unknown-elf-gdb
# 2. Test functionality
# 3. Configure project to use it
# 4. Fall back to gdb-multiarch if needed
```

### Manual Integration

```bash
# Add to PATH for current session
export PATH="/path/to/microblaze-v-complete/tools/riscv-gdb-install/bin:$PATH"

# Add to shell profile for permanent setup
echo 'export PATH="/path/to/microblaze-v-complete/tools/riscv-gdb-install/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
riscv64-unknown-elf-gdb --version
```

## Ì†æÌ∑™ Testing the Installation

### Basic Functionality Test

```bash
# Test RISC-V architecture support
riscv64-unknown-elf-gdb -batch \
    -ex "set architecture riscv:rv32" \
    -ex "show architecture"

# Should output: "riscv:rv32"
```

### Full Project Test

```bash
# Build project
make clean && make

# Test GDB script integration
echo 'help_microblaze' | riscv64-unknown-elf-gdb \
    -batch -x debug_microblaze_v.gdb build/microblaze_v_demo

# Run validation suite
./test_gdb_script.sh
```

### Debug Session Test

```bash
# Terminal 1: Start QEMU with GDB server
make run-debug

# Terminal 2: Connect GDB (should use riscv64-unknown-elf-gdb)
make debug

# In GDB:
(gdb) help_microblaze
(gdb) quick_debug
(gdb) show_system_info
```

## Ì†ΩÌ¥ç Troubleshooting

### Build Issues

**Problem**: Configure fails with missing dependencies
```bash
# Solution: Install missing packages
sudo apt install -y texinfo libreadline-dev libexpat1-dev python3-dev
```

**Problem**: Build fails with "makeinfo not found"
```bash
# Solution: Install texinfo
sudo apt install -y texinfo
```

**Problem**: Python integration issues
```bash
# Solution: Ensure Python development headers
sudo apt install -y python3-dev python3-distutils
```

### Runtime Issues

**Problem**: GDB doesn't recognize RISC-V architecture
```bash
# Check if built correctly
riscv64-unknown-elf-gdb -batch -ex "show architecture"

# Should list riscv architectures
```

**Problem**: Project still uses gdb-multiarch
```bash
# Re-run setup
make setup-gdb

# Check configuration
cat .gdb_config

# Should contain: export MICROBLAZE_GDB=riscv64-unknown-elf-gdb
```

## Ì†ΩÌ≥ä Performance Comparison

| Feature | riscv64-unknown-elf-gdb | gdb-multiarch |
|---------|-------------------------|---------------|
| RISC-V Support | ‚úÖ Native | ‚úÖ Compatible |
| Performance | ‚úÖ Optimal | ‚ö†Ô∏è Good |
| RISC-V Features | ‚úÖ Complete | ‚ö†Ô∏è Limited |
| Setup Complexity | ‚ö†Ô∏è Build Required | ‚úÖ Package Install |
| Maintenance | ‚ö†Ô∏è Manual Updates | ‚úÖ System Updates |

## Ì†ºÌæØ Recommendations

### For Development
- **Use gdb-multiarch**: Quick setup, fully functional
- **Upgrade to riscv64-unknown-elf-gdb**: When you need optimal performance

### For Production
- **Build riscv64-unknown-elf-gdb**: Professional toolchain completion
- **Document setup**: For team consistency

### For Learning
- **Start with gdb-multiarch**: Focus on MicroBlaze-V concepts
- **Build from source**: Understand toolchain internals

## Ì†ΩÌ¥Ñ Maintenance

### Updating GDB

```bash
# Update from git (Method 1)
cd tools/riscv-gdb
git pull origin master
cd build
make clean
make -j$(nproc)
make install

# Or download new release (Method 2)
cd tools
wget https://ftp.gnu.org/gnu/gdb/gdb-X.Y.tar.xz
# Follow build steps
```

### Cleanup

```bash
# Remove build artifacts (keep installation)
rm -rf tools/riscv-gdb/build

# Complete removal
rm -rf tools/riscv-gdb tools/riscv-gdb-install
```

## Ì†ΩÌ≥ö Additional Resources

- **GNU GDB Documentation**: https://www.gnu.org/software/gdb/documentation/
- **RISC-V Debug Specification**: https://github.com/riscv/riscv-debug-spec
- **MicroBlaze-V Documentation**: AMD MicroBlaze-V Processor Reference Guide
- **Project Debug Guide**: [GDB_DEBUGGING_GUIDE.md](GDB_DEBUGGING_GUIDE.md)

## Ì†ºÌæâ Success Indicators

After successful setup, you should see:

```bash
$ make setup-gdb
‚úÖ Using riscv64-unknown-elf-gdb (optimal)
GDB Version: GNU gdb (GDB) 15.1

$ make debug
Starting GDB debugging session...
GNU gdb (GDB) 15.1
(gdb) help_microblaze
# Shows all 15 custom MicroBlaze-V commands
```

Your MicroBlaze-V development environment is now complete with professional-grade debugging capabilities!

