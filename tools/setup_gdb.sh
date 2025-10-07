#!/bin/bash
# MicroBlaze-V GDB Setup Script
# This script configures the optimal GDB debugger for MicroBlaze-V development

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GDB_INSTALL_PATH="$PROJECT_ROOT/tools/riscv-gdb-install"

echo "========================================="
echo "MicroBlaze-V GDB Setup"
echo "========================================="

# Function to test GDB functionality
test_gdb_functionality() {
    local gdb_cmd="$1"
    local gdb_name="$2"

    echo "Testing $gdb_name functionality..."

    # Test RISC-V architecture support
    if $gdb_cmd -batch -ex "set architecture riscv:rv32" -ex "show architecture" 2>/dev/null | grep -q "riscv:rv32"; then
        echo "  ‚úÖ RISC-V RV32 architecture support: OK"
        return 0
    else
        echo "  ‚ùå RISC-V RV32 architecture support: FAILED"
        return 1
    fi
}

# Check for riscv64-unknown-elf-gdb (preferred)
if [ -f "$GDB_INSTALL_PATH/bin/riscv64-unknown-elf-gdb" ]; then
    echo "Ì†ºÌæØ Found locally built RISC-V GDB"
    export PATH="$GDB_INSTALL_PATH/bin:$PATH"

    if test_gdb_functionality "riscv64-unknown-elf-gdb" "riscv64-unknown-elf-gdb"; then
        echo "‚úÖ Using riscv64-unknown-elf-gdb (optimal)"
        echo "GDB Version: $(riscv64-unknown-elf-gdb --version | head -1)"
        export MICROBLAZE_GDB="riscv64-unknown-elf-gdb"
        echo "export MICROBLAZE_GDB=riscv64-unknown-elf-gdb" > "$PROJECT_ROOT/.gdb_config"
        exit 0
    fi
fi

# Check for system riscv64-unknown-elf-gdb
if command -v riscv64-unknown-elf-gdb >/dev/null 2>&1; then
    echo "Ì†ºÌæØ Found system RISC-V GDB"

    if test_gdb_functionality "riscv64-unknown-elf-gdb" "system riscv64-unknown-elf-gdb"; then
        echo "‚úÖ Using system riscv64-unknown-elf-gdb (optimal)"
        echo "GDB Version: $(riscv64-unknown-elf-gdb --version | head -1)"
        export MICROBLAZE_GDB="riscv64-unknown-elf-gdb"
        echo "export MICROBLAZE_GDB=riscv64-unknown-elf-gdb" > "$PROJECT_ROOT/.gdb_config"
        exit 0
    fi
fi

# Fallback to gdb-multiarch
if command -v gdb-multiarch >/dev/null 2>&1; then
    echo "Ì†ΩÌ¥Ñ Falling back to gdb-multiarch"

    if test_gdb_functionality "gdb-multiarch" "gdb-multiarch"; then
        echo "‚úÖ Using gdb-multiarch (compatible fallback)"
        echo "GDB Version: $(gdb-multiarch --version | head -1)"
        export MICROBLAZE_GDB="gdb-multiarch"
        echo "export MICROBLAZE_GDB=gdb-multiarch" > "$PROJECT_ROOT/.gdb_config"

        echo ""
        echo "Ì†ΩÌ≥ù Note: Using gdb-multiarch as fallback."
        echo "   For optimal experience, consider building riscv64-unknown-elf-gdb:"
        echo "   See RISC_V_GDB_BUILD_GUIDE.md for instructions"
        exit 0
    fi
fi

# No suitable GDB found
echo "‚ùå No suitable GDB debugger found!"
echo ""
echo "Please install one of the following:"
echo "  1. riscv64-unknown-elf-gdb (preferred)"
echo "  2. gdb-multiarch (fallback)"
echo ""
echo "Ubuntu/Debian: sudo apt install gdb-multiarch"
echo "Or build from source: see RISC_V_GDB_BUILD_GUIDE.md"
exit 1

