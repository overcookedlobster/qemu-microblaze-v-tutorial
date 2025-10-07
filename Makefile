# Microblaze-V Makefile

# Toolchain
CC = riscv64-unknown-elf-gcc
OBJDUMP = riscv64-unknown-elf-objdump
OBJCOPY = riscv64-unknown-elf-objcopy

# Flags
CFLAGS = -march=rv32imafc -mabi=ilp32f -nostdlib -Iinclude
LDFLAGS = -T linker/microblaze_v.ld

# Directories
SRCDIR = src
INCDIR = include
BUILDDIR = build

# Source files
ASM_SOURCES = $(SRCDIR)/start.s
C_SOURCES = $(SRCDIR)/main.c $(SRCDIR)/peripherals.c

# Object files
ASM_OBJECTS = $(ASM_SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
C_OBJECTS = $(C_SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)
OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS)

# Target
TARGET = $(BUILDDIR)/microblaze_v_demo

# QEMU path (adjust as needed)
QEMU = ./qemu-microblaze-v/build/qemu-system-riscv32

.PHONY: all clean run disasm run-debug debug help

all: $(TARGET)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(TARGET): $(BUILDDIR) $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/%.o: $(SRCDIR)/%.s
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILDDIR)

run: $(TARGET)
	$(QEMU) -M amd-microblaze-v-generic \
		-display none -serial stdio -monitor none \
		-device loader,addr=0x00000000,file=$(TARGET),cpu-num=0

disasm: $(TARGET)
	$(OBJDUMP) -d $(TARGET)

run-debug: $(TARGET)
	@echo "Starting QEMU with GDB server..."
	@echo "Connect with: gdb -x debug_microblaze_v.gdb"
	$(QEMU) -M amd-microblaze-v-generic \
		-display none -serial stdio -monitor none \
		-device loader,addr=0x00000000,file=$(TARGET),cpu-num=0 \
		-s -S

debug: $(TARGET)
	@echo "Starting GDB debugging session..."
	@echo "QEMU should be running with -s -S flags"
	@if [ -f .gdb_config ]; then \
		source .gdb_config && $$MICROBLAZE_GDB -x debug_microblaze_v.gdb $(TARGET); \
	elif command -v riscv64-unknown-elf-gdb >/dev/null 2>&1; then \
		riscv64-unknown-elf-gdb -x debug_microblaze_v.gdb $(TARGET); \
	elif command -v gdb-multiarch >/dev/null 2>&1; then \
		gdb-multiarch -x debug_microblaze_v.gdb $(TARGET); \
	else \
		echo "❌ No suitable GDB found. Run: source tools/setup_gdb.sh"; \
		exit 1; \
	fi

# Setup GDB environment
setup-gdb:
	@echo "Setting up GDB environment..."
	@bash tools/setup_gdb.sh

help:
	@echo "Available targets:"
	@echo "  all       - Build the project"
	@echo "  clean     - Clean build files"
	@echo "  run       - Run in QEMU"
	@echo "  run-debug - Run QEMU with GDB server (use -s -S)"
	@echo "  debug     - Start GDB debugging session"
	@echo "  setup-gdb - Configure optimal GDB debugger"
	@echo "  disasm    - Show disassembly"
	@echo "  help      - Show this help"
