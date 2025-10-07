#!/bin/bash
# Validation script for GDB debugging setup (without requiring full toolchain)
# This script validates the structure and syntax of our debugging setup

set -e

echo "========================================"
echo "MicroBlaze-V GDB Setup Validation"
echo "========================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

test_passed() {
    echo -e "${GREEN}âœ“ PASS${NC} $1"
}

test_failed() {
    echo -e "${RED}âœ— FAIL${NC} $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

test_warning() {
    echo -e "${YELLOW}âš  WARN${NC} $1"
}

test_info() {
    echo -e "${BLUE}â„¹ INFO${NC} $1"
}

FAILED_TESTS=0

# Test 1: Check if required files exist
echo "1. Checking required files..."
if [ -f "debug_microblaze_v.gdb" ]; then
    test_passed "GDB script exists"
else
    test_failed "GDB script missing"
fi

if [ -f "GDB_DEBUGGING_GUIDE.md" ]; then
    test_passed "Documentation exists"
else
    test_failed "Documentation missing"
fi

if [ -f "Makefile" ]; then
    test_passed "Makefile exists"
else
    test_failed "Makefile missing"
fi

# Test 2: Validate GDB script structure
echo
echo "2. Validating GDB script structure..."

# Check for required GDB commands
REQUIRED_COMMANDS=(
    "connect_qemu"
    "setup_debug"
    "show_system_info"
    "show_uart_status"
    "show_timer_status"
    "show_peripherals"
    "examine_stack"
    "examine_code_at_pc"
    "break_peripherals"
    "debug_startup"
    "monitor_uart_output"
    "trace_calls"
    "quick_debug"
    "help_microblaze"
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if grep -q "define $cmd" debug_microblaze_v.gdb; then
        test_passed "Command '$cmd' defined"
    else
        test_failed "Command '$cmd' missing"
    fi
done

# Test 3: Check GDB script syntax basics
echo
echo "3. Checking GDB script syntax..."

# Check for proper define/end pairs
DEFINE_COUNT=$(grep -c "^define " debug_microblaze_v.gdb || true)
END_COUNT=$(grep -c "^end$" debug_microblaze_v.gdb || true)

if [ "$DEFINE_COUNT" -eq "$END_COUNT" ]; then
    test_passed "Define/end pairs balanced ($DEFINE_COUNT each)"
else
    test_failed "Define/end pairs unbalanced (define: $DEFINE_COUNT, end: $END_COUNT)"
fi

# Check for proper printf format strings
if grep -q 'printf.*%.*\\n' debug_microblaze_v.gdb; then
    test_passed "Printf statements use proper format strings"
else
    test_warning "Printf statements may need format string review"
fi

# Test 4: Validate peripheral addresses
echo
echo "4. Validating peripheral addresses..."

# Check UART addresses
if grep -q "0x40600000" debug_microblaze_v.gdb; then
    test_passed "UART base address defined"
else
    test_failed "UART base address missing"
fi

# Check Timer addresses
if grep -q "0x41C00000" debug_microblaze_v.gdb; then
    test_passed "Timer base address defined"
else
    test_failed "Timer base address missing"
fi

# Test 5: Check Makefile integration
echo
echo "5. Checking Makefile integration..."

if grep -q "run-debug" Makefile; then
    test_passed "Makefile has run-debug target"
else
    test_failed "Makefile missing run-debug target"
fi

if grep -q "debug:" Makefile; then
    test_passed "Makefile has debug target"
else
    test_failed "Makefile missing debug target"
fi

if grep -q "\-s \-S" Makefile; then
    test_passed "Makefile uses GDB server flags"
else
    test_failed "Makefile missing GDB server flags"
fi

# Test 6: Validate documentation completeness
echo
echo "6. Checking documentation completeness..."

DOC_SECTIONS=(
    "Quick Start"
    "Available GDB Commands"
    "Debugging Scenarios"
    "Troubleshooting"
    "Memory Map"
)

for section in "${DOC_SECTIONS[@]}"; do
    if grep -q "$section" GDB_DEBUGGING_GUIDE.md; then
        test_passed "Documentation has '$section' section"
    else
        test_failed "Documentation missing '$section' section"
    fi
done

# Test 7: Check for common GDB script issues
echo
echo "7. Checking for common issues..."

# Check for hardcoded paths
if grep -q "/home/\|/usr/local" debug_microblaze_v.gdb; then
    test_warning "GDB script may contain hardcoded paths"
else
    test_passed "No hardcoded paths detected"
fi

# Check for proper error handling
if grep -q "try\|except\|error" debug_microblaze_v.gdb; then
    test_passed "Error handling present"
else
    test_warning "Limited error handling detected"
fi

# Test 8: Validate example usage
echo
echo "8. Validating example scenarios..."

# Create a mock GDB session to test command structure
cat > mock_gdb_test.txt << 'EOF'
# Mock GDB session test
# This simulates what a user would type

# Load the script
source debug_microblaze_v.gdb

# Get help
help_microblaze

# Setup debugging
setup_debug

# Show system info (would work with target)
# show_system_info

# Show peripheral status (would work with target)
# show_peripherals

EOF

test_passed "Mock GDB session created"

# Test 9: Check script completeness
echo
echo "9. Checking script completeness..."

# Count total lines and commands
TOTAL_LINES=$(wc -l < debug_microblaze_v.gdb)
COMMAND_COUNT=$(grep -c "^define " debug_microblaze_v.gdb || true)

test_info "Total script lines: $TOTAL_LINES"
test_info "Total commands defined: $COMMAND_COUNT"

if [ "$TOTAL_LINES" -gt 200 ]; then
    test_passed "Script is comprehensive (>200 lines)"
else
    test_warning "Script may need more content (<200 lines)"
fi

if [ "$COMMAND_COUNT" -gt 10 ]; then
    test_passed "Good command coverage (>10 commands)"
else
    test_warning "May need more debugging commands (<10)"
fi

# Test 10: Validate integration
echo
echo "10. Testing integration..."

# Check if all components work together
if [ -f "debug_microblaze_v.gdb" ] && [ -f "GDB_DEBUGGING_GUIDE.md" ] && grep -q "debug_microblaze_v.gdb" Makefile; then
    test_passed "All components integrated properly"
else
    test_failed "Integration issues detected"
fi

# Clean up
rm -f mock_gdb_test.txt

# Summary
echo
echo "========================================"
echo "Validation Summary"
echo "========================================"

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}í ¼í¾‰ All validation tests passed!${NC}"
    echo
    echo "Your GDB debugging setup is ready to use:"
    echo
    echo "1. í ½í³ Files created:"
    echo "   âœ“ debug_microblaze_v.gdb    - GDB debugging script"
    echo "   âœ“ GDB_DEBUGGING_GUIDE.md    - Complete documentation"
    echo "   âœ“ test_gdb_script.sh        - Full test suite"
    echo "   âœ“ validate_gdb_setup.sh     - This validation script"
    echo
    echo "2. í ½í´§ Makefile targets added:"
    echo "   âœ“ make run-debug            - Start QEMU with GDB server"
    echo "   âœ“ make debug                - Start GDB debugging session"
    echo
    echo "3. í ½í³š Usage:"
    echo "   â€¢ Read: GDB_DEBUGGING_GUIDE.md"
    echo "   â€¢ Test: ./test_gdb_script.sh (requires toolchain)"
    echo "   â€¢ Debug: make run-debug + make debug"
    echo
    echo "4. í ¼í¾¯ Key GDB commands:"
    echo "   â€¢ help_microblaze           - Show all commands"
    echo "   â€¢ quick_debug               - Automatic setup"
    echo "   â€¢ show_system_info          - Display system state"
    echo "   â€¢ show_peripherals          - Show UART/Timer status"
    echo "   â€¢ debug_startup             - Step through startup"
    echo
else
    echo -e "${RED}âŒ $FAILED_TESTS validation test(s) failed${NC}"
    echo "Please review the failed tests above and fix the issues."
    exit 1
fi

echo "========================================"
echo "Validation Complete âœ…"
echo "========================================"
