# Project Settings
NAME = v7os

# Compile Settings
CROSS_COMPILE = arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
AR = $(CROSS_COMPILE)ar
OBJCOPY = $(CROSS_COMPILE)objcopy
GDB = $(CROSS_COMPILE)gdb
HOSTCC  = gcc

# CMSIS
CMSIS := external/cmsis

# Compile Flags
CFLAGS_BASE = -std=c99 -ffunction-sections -fdata-sections
CFLAGS_WARN = -W -Wall -Wno-main
CFLAGS_OPTS = -O0 -g3 -gdwarf-4
CFLAGS_ARCH = -mthumb -mcpu=cortex-m3 -march=armv7-m
CMSIS_INCS := \
	-I$(CMSIS) \
	-I$(CMSIS)/util \
	-I$(CMSIS)/arm \
	-I$(CMSIS)/arm/TARGET_CORTEX_M \
	-I$(CMSIS)/arm/TARGET_CORTEX_M/TOOLCHAIN_GCC \
	-I$(CMSIS)/TARGET_STM \
	-I$(CMSIS)/TARGET_STM/TARGET_STM32F1 \
	-I$(CMSIS)/TARGET_STM/TARGET_STM32F1/device \
	-I$(CMSIS)/TARGET_STM/TARGET_STM32F1/TARGET_NUCLEO_F103RB \
	-I$(CMSIS)/TARGET_STM/TARGET_STM32F1/TARGET_NUCLEO_F103RB/device

CFLAGS_INCS = -I. -Iinclude \
	$(CMSIS_INCS)

CFLAGS := \
	$(CFLAGS_BASE) \
	$(CFLAGS_WARN) \
	$(CFLAGS_OPTS) \
	$(CFLAGS_ARCH) \
	$(CFLAGS_INCS)

LDFLAGS := \
    -nostartfiles -T v7os.ld


# Source Files
CSRC := \
	kernel/init.c \
	kernel/main.c

CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/system_stm32f1xx.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/stm32f1xx_hal.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/stm32f1xx_hal_cortex.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/stm32f1xx_hal_rcc.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/stm32f1xx_hal_rcc_ex.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/stm32f1xx_hal_gpio.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/stm32f1xx_hal_uart.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/device/stm32f1xx_hal_dma.c
CSRC += $(CMSIS)/TARGET_STM/TARGET_STM32F1/TARGET_NUCLEO_F103RB/device/system_clock.c


OBJS += $(CSRC:.c=.o)
OBJS := $(sort $(OBJS))


# Rules
.PHONY: all

all: $(CMSIS) $(NAME).bin

include mk/cmsis.mk

clean:
	$(RM) $(OBJS) $(NAME).bin $(NAME).elf

$(NAME).bin: $(NAME).elf
	$(Q)$(OBJCOPY) -Obinary $< $@

$(NAME).elf: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

# Implict Rules
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@


# Deploy
QEMU_FLAGS := \
	-semihosting -nographic -cpu cortex-m3 -machine stm32-p103 -kernel $(NAME).bin

run:
	qemu-system-arm $(QEMU_FLAGS)

dbg:
	qemu-system-arm $(QEMU_FLAGS) -s -S

gdb:
	$(GDB) -q -nw $(NAME).elf -ex "target remote :1234"
