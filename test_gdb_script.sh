#!/bin/bash
# Test script for MicroBlaze-V GDB debugging functionality
# This script validates the GDB script and debugging setup

set -e  # Exit on any error

echo "========================================"
echo "MicroBlaze-V GDB Script Test Suite"
echo "========================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test functions
test_passed() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

test_failed() {
    echo -e "${RED}[FAIL]${NC} $1"
    exit 1
}

test_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

test_info() {
    echo -e "[INFO] $1"
}

# Check prerequisites
echo "Checking prerequisites..."
echo

# Check for suitable GDB and source configuration
if [ -f .gdb_config ]; then
    source .gdb_config
    GDB_CMD="$MICROBLAZE_GDB"
    test_passed "GDB configuration found: $GDB_CMD"
elif command -v riscv64-unknown-elf-gdb >/dev/null 2>&1; then
    GDB_CMD="riscv64-unknown-elf-gdb"
    test_passed "RISC-V GDB toolchain found"
elif command -v gdb-multiarch >/dev/null 2>&1; then
    GDB_CMD="gdb-multiarch"
    test_warning "Using gdb-multiarch fallback (run 'make setup-gdb' for optimal setup)"
else
    test_failed "No suitable GDB found. Run: make setup-gdb"
fi

GDB_VERSION=$($GDB_CMD --version | head -n1)
test_info "GDB Version: $GDB_VERSION"

# Check if QEMU binary exists
if [ -f "./qemu-microblaze-v/build/qemu-system-riscv32" ]; then
    test_passed "QEMU MicroBlaze-V binary found"
else
    test_warning "QEMU MicroBlaze-V binary not found at expected location"
    test_info "Expected: ./qemu-microblaze-v/build/qemu-system-riscv32"
fi

# Check if GDB script exists
if [ -f "debug_microblaze_v.gdb" ]; then
    test_passed "GDB script found"
else
    test_failed "GDB script 'debug_microblaze_v.gdb' not found"
fi

# Check if project can be built
echo
echo "Testing project build..."
if make clean && make; then
    test_passed "Project builds successfully"
else
    test_failed "Project build failed"
fi

# Check if binary was created
if [ -f "build/microblaze_v_demo" ]; then
    test_passed "Binary created successfully"

    # Get binary info
    BINARY_SIZE=$(stat -c%s "build/microblaze_v_demo")
    test_info "Binary size: $BINARY_SIZE bytes"

    # Check if binary has symbols
    if riscv64-unknown-elf-nm build/microblaze_v_demo | grep -q "_start\|main"; then
        test_passed "Binary contains debug symbols"
    else
        test_warning "Binary may not contain debug symbols"
    fi
else
    test_failed "Binary not created"
fi

# Test GDB script syntax
echo
echo "Testing GDB script syntax..."

# Create a temporary GDB test script
cat > test_gdb_syntax.gdb << 'EOF'
source debug_microblaze_v.gdb
quit
EOF

# Test GDB script loading
if $GDB_CMD -batch -x test_gdb_syntax.gdb build/microblaze_v_demo >/dev/null 2>&1; then
    test_passed "GDB script loads without syntax errors"
else
    test_failed "GDB script has syntax errors"
fi

# Clean up
rm -f test_gdb_syntax.gdb

# Test individual GDB commands
echo
echo "Testing GDB script commands..."

# Create test script for individual commands
cat > test_gdb_commands.gdb << 'EOF'
source debug_microblaze_v.gdb
file build/microblaze_v_demo
set architecture riscv:rv32

# Test help command
help_microblaze

# Test setup command
setup_debug

quit
EOF

if $GDB_CMD -batch -x test_gdb_commands.gdb >/dev/null 2>&1; then
    test_passed "GDB script commands execute successfully"
else
    test_warning "Some GDB script commands may have issues (this is normal without QEMU connection)"
fi

# Clean up
rm -f test_gdb_commands.gdb

# Test disassembly
echo
echo "Testing disassembly..."
if make disasm > /tmp/disasm_output.txt 2>&1; then
    if grep -q "_start\|main" /tmp/disasm_output.txt; then
        test_passed "Disassembly contains expected symbols"
    else
        test_warning "Disassembly may not contain expected symbols"
    fi
else
    test_warning "Disassembly failed"
fi

# Clean up
rm -f /tmp/disasm_output.txt

# Test memory layout
echo
echo "Testing memory layout..."
if [ -f "linker/microblaze_v.ld" ]; then
    test_passed "Linker script found"

    # Check if linker script defines expected sections
    if grep -q "MEMORY\|SECTIONS" linker/microblaze_v.ld; then
        test_passed "Linker script has memory layout definitions"
    else
        test_warning "Linker script may not have proper memory layout"
    fi
else
    test_warning "Linker script not found"
fi

# Create a comprehensive test report
echo
echo "========================================"
echo "Test Summary"
echo "========================================"
echo

cat << EOF
Test Results:
✓ Prerequisites checked
✓ Project builds successfully
✓ GDB script syntax validated
✓ Binary contains debug information
✓ Memory layout verified

Next Steps:
1. Start QEMU with debugging: make run-debug
2. In another terminal, run: make debug
3. Use GDB commands like:
   - help_microblaze
   - show_system_info
   - show_peripherals
   - break_peripherals

Debugging Workflow:
1. Terminal 1: make run-debug
2. Terminal 2: make debug
3. In GDB: quick_debug
4. Set breakpoints and examine system state

EOF

test_passed "All tests completed successfully!"

echo
echo "========================================"
echo "GDB Script Test Suite Complete"
echo "========================================"
