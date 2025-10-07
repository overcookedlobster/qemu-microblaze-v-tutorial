# MicroBlaze-V GDB Debugging Guide

This guide provides comprehensive instructions for debugging MicroBlaze-V applications using GDB with QEMU.

## Ì†ºÌæØ Overview

The MicroBlaze-V debugging setup includes:
- **GDB Script**: `debug_microblaze_v.gdb` - Custom debugging commands
- **Test Suite**: `test_gdb_script.sh` - Validation and testing
- **Makefile Targets**: Integrated build and debug commands
- **QEMU Integration**: Remote debugging via GDB server

## Ì†ΩÌ∫Ä Quick Start

### 1. Setup GDB Environment (First Time)
```bash
make setup-gdb
```

### 2. Build the Project
```bash
make clean && make
```

### 3. Start Debugging Session

**Terminal 1** (Start QEMU with GDB server):
```bash
make run-debug
```

**Terminal 2** (Connect GDB):
```bash
make debug
```

### 3. Use GDB Commands
Once in GDB:
```gdb
(gdb) help_microblaze     # Show all available commands
(gdb) quick_debug         # Automatic setup
(gdb) show_system_info    # Display system state
(gdb) show_peripherals    # Show UART and Timer status
```

## Ì†ΩÌ≥ã Available GDB Commands

### Connection Commands
| Command | Description |
|---------|-------------|
| `connect_qemu` | Connect to QEMU GDB server (localhost:1234) |
| `setup_debug` | Configure debug environment and breakpoints |
| `quick_debug` | Complete automated setup |

### System Information
| Command | Description |
|---------|-------------|
| `show_system_info` | Display registers, PC, and memory layout |
| `show_uart_status` | Show UARTlite registers and decoded status |
| `show_timer_status` | Show Timer registers and control bits |
| `show_peripherals` | Display all peripheral status |

### Memory Examination
| Command | Description |
|---------|-------------|
| `examine_stack` | Show stack contents (32 words) |
| `examine_code_at_pc` | Show instructions around current PC |

### Breakpoint Management
| Command | Description |
|---------|-------------|
| `break_peripherals` | Set breakpoints on all peripheral functions |
| `break_main_loop` | Set breakpoints in main application |

### Advanced Debugging
| Command | Description |
|---------|-------------|
| `debug_startup` | Step through system startup sequence |
| `monitor_uart_output` | Monitor UART character output |
| `trace_calls` | Trace function calls with stack info |

## Ì†ΩÌ¥ß Debugging Scenarios

### Scenario 1: System Startup Issues

If your system doesn't start or produces no output:

```gdb
(gdb) quick_debug
(gdb) debug_startup
```

This will:
1. Reset the system
2. Break at `_start`
3. Show register state
4. Step to `main()`
5. Display peripheral status

### Scenario 2: UART Communication Problems

To debug UART issues:

```gdb
(gdb) show_uart_status
(gdb) break uartlite_putc
(gdb) monitor_uart_output
(gdb) continue
```

This will:
- Show current UART register state
- Break on every character output
- Display each character being sent

### Scenario 3: Timer and Timing Issues

To debug timer problems:

```gdb
(gdb) show_timer_status
(gdb) break timer_init
(gdb) break delay_ms
(gdb) continue
```

### Scenario 4: Function Call Tracing

To trace all function calls:

```gdb
(gdb) trace_calls
(gdb) continue
```

This shows every function call with arguments and call stack.

### Scenario 5: Memory and Register Inspection

To examine system state:

```gdb
(gdb) show_system_info
(gdb) examine_stack
(gdb) examine_code_at_pc
(gdb) info registers
```

## Ì†ΩÌª†Ô∏è Manual Debugging Commands

### Basic GDB Commands
```gdb
# Execution control
continue (c)          # Continue execution
step (s)              # Step one source line
stepi (si)            # Step one instruction
next (n)              # Step over function calls
finish                # Run until function returns

# Breakpoints
break main            # Break at main function
break *0x1000         # Break at specific address
info breakpoints      # List all breakpoints
delete 1              # Delete breakpoint 1

# Memory examination
x/10i $pc             # Show 10 instructions at PC
x/16wx $sp            # Show 16 words at stack pointer
print $a0             # Print register a0
print *(int*)0x40600000  # Print memory contents

# Register examination
info registers        # Show all registers
print $pc             # Show program counter
print $sp             # Show stack pointer
```

### MicroBlaze-V Specific Registers
```gdb
# RISC-V Register Names
$pc    # Program Counter
$sp    # Stack Pointer (x2)
$ra    # Return Address (x1)
$gp    # Global Pointer (x3)
$tp    # Thread Pointer (x4)
$a0-$a7 # Function arguments (x10-x17)
$t0-$t6 # Temporary registers
$s0-$s11 # Saved registers
```

## Ì†ΩÌ≥ç Memory Map

### Peripheral Addresses
```
UARTlite Base:    0x40600000
‚îú‚îÄ‚îÄ RX FIFO:      0x40600000
‚îú‚îÄ‚îÄ TX FIFO:      0x40600004
‚îú‚îÄ‚îÄ Status Reg:   0x40600008
‚îî‚îÄ‚îÄ Control Reg:  0x4060000C

Timer Base:       0x41C00000
‚îú‚îÄ‚îÄ TCSR0:        0x41C00000
‚îú‚îÄ‚îÄ TLR0:         0x41C00004
‚îî‚îÄ‚îÄ TCR0:         0x41C00008

UART16550 Base:   0x44A11000
GPIO Base:        0x40000000
```

### Memory Layout
```
0x00000000: Program start (_start)
0x????????: Stack (grows downward)
0x40000000: Peripheral space
```

## Ì†æÌ∑™ Testing and Validation

### Run Test Suite
```bash
./test_gdb_script.sh
```

This validates:
- ‚úÖ Toolchain availability
- ‚úÖ Project build success
- ‚úÖ GDB script syntax
- ‚úÖ Binary debug symbols
- ‚úÖ Memory layout

### Manual Testing

1. **Test Basic Functionality**:
   ```bash
   make clean && make
   make run
   ```

2. **Test Debug Setup**:
   ```bash
   # Terminal 1
   make run-debug

   # Terminal 2
   make debug
   ```

3. **Test GDB Commands**:
   ```gdb
   (gdb) help_microblaze
   (gdb) show_system_info
   (gdb) show_peripherals
   ```

## Ì†ΩÌ∫® Troubleshooting

### Common Issues

#### 1. "No such file or directory" when starting GDB
**Problem**: GDB can't find the binary
**Solution**:
```bash
make clean && make  # Rebuild the project
ls build/           # Verify binary exists
```

#### 2. "Connection refused" when connecting to QEMU
**Problem**: QEMU GDB server not running
**Solution**:
```bash
# Make sure QEMU is running with -s -S flags
make run-debug
```

#### 3. "Remote 'g' packet reply is too long"
**Problem**: Architecture mismatch
**Solution**:
```gdb
(gdb) set architecture riscv:rv32
(gdb) target remote localhost:1234
```

#### 4. No output from UART
**Problem**: Entry point or peripheral issue
**Solution**:
```gdb
(gdb) show_uart_status
(gdb) break _start
(gdb) continue
(gdb) show_system_info
```

#### 5. GDB script commands not found
**Problem**: Script not loaded
**Solution**:
```gdb
(gdb) source debug_microblaze_v.gdb
(gdb) help_microblaze
```

### Debug Tips

1. **Always check peripheral status first**:
   ```gdb
   (gdb) show_peripherals
   ```

2. **Use single-step debugging for startup issues**:
   ```gdb
   (gdb) break _start
   (gdb) stepi
   (gdb) show_system_info
   ```

3. **Monitor UART for communication issues**:
   ```gdb
   (gdb) monitor_uart_output
   ```

4. **Check stack for corruption**:
   ```gdb
   (gdb) examine_stack
   ```

## Ì†ΩÌ≥ö Advanced Usage

### Custom Breakpoint Conditions
```gdb
# Break when heartbeat reaches 5
break main.c:32 if heartbeat == 5

# Break when UART status changes
watch *(int*)0x40600008

# Break on specific function with condition
break uartlite_putc if $a0 == 'H'
```

### Scripted Debugging Sessions
Create custom GDB scripts:

```gdb
# my_debug_session.gdb
source debug_microblaze_v.gdb
quick_debug
break main
continue
show_peripherals
monitor_uart_output
continue
```

Run with:
```bash
riscv64-unknown-elf-gdb -x my_debug_session.gdb build/microblaze_v_demo
```

### Performance Analysis
```gdb
# Count function calls
break uartlite_putc
commands
    silent
    set $uart_calls = $uart_calls + 1
    continue
end

# Time execution
break main
commands
    set $start_time = $pc
    continue
end
```

## Ì†ºÌæØ Best Practices

1. **Always use the test suite** before debugging sessions
2. **Start with `quick_debug`** for automatic setup
3. **Check peripheral status** when debugging communication issues
4. **Use `show_system_info`** to understand current state
5. **Set meaningful breakpoints** rather than single-stepping everything
6. **Save useful debugging sessions** as custom GDB scripts
7. **Monitor UART output** to understand program flow
8. **Use watchpoints** for memory corruption issues

---

**Happy Debugging!** Ì†ΩÌ∞õÌ†ΩÌ¥ç

For more information, see:
- `README.md` - Project overview
- `MICROBLAZE_V_COMPLETE_TUTORIAL.md` - Complete tutorial
- `debug_microblaze_v.gdb` - GDB script source
- `test_gdb_script.sh` - Test suite
