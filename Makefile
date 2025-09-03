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
QEMU = ../qemu-microblaze-v/build/qemu-system-riscv32

.PHONY: all clean run disasm

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

help:
	@echo "Available targets:"
	@echo "  all     - Build the project"
	@echo "  clean   - Clean build files"
	@echo "  run     - Run in QEMU"
	@echo "  disasm  - Show disassembly"
	@echo "  help    - Show this help"
