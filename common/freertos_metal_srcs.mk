# SPDX-License-Identifier: Apache-2.0
# Author: Robert Balas (balasr@iis.ee.ethz.ch)

# expects RTOS_ROOT to point to the FreeRTOS distribution root
# and COMMON_ROOT to the driver folder

# general OS
RTOS_SRCS = $(addprefix $(RTOS_ROOT)/,\
		event_groups.c list.c queue.c stream_buffer.c tasks.c timers.c)
# RISC-V port files
RTOS_SRCS += $(addprefix $(RTOS_ROOT)/portable/GCC/RISC-V/,\
		port.c portASM.S)
# memory managment
RTOS_SRCS += $(addprefix $(RTOS_ROOT)/portable/MemMang/,\
		heap_3.c)
# freertos generic headers
CPPFLAGS += $(addprefix -I, \
		"$(RTOS_ROOT)/include" \
		"$(RTOS_ROOT)/portable/GCC/RISC-V")
# freertos header for assembler
CPPFLAGS  += -I"$(RTOS_ROOT)/portable/GCC/RISC-V/chip_specific_extensions/PULPissimo"

# c runtime and init
ifneq ($(LIBC),no)
PULP_SRCS += $(COMMON_ROOT)/libc/syscalls.c # syscall shims / implementation
endif
PULP_SRCS += $(COMMON_ROOT)/target/crt0.S $(COMMON_ROOT)/target/vectors.S

# target/platform specific includes and srcs
ifeq ($(FREERTOS_CONFIG_FAMILY),pulp)
PULP_SRCS += $(COMMON_ROOT)/target/pulp/system_pulp_ri5cy_metal.c
CPPFLAGS += -I"$(COMMON_ROOT)/target/pulp/include"
else ifeq ($(FREERTOS_CONFIG_FAMILY),pulpissimo)
PULP_SRCS += $(COMMON_ROOT)/target/pulpissimo/system_pulpissimo_ri5cy_metal.c
CPPFLAGS += -I"$(COMMON_ROOT)/target/pulpissimo/include"
else ifeq ($(FREERTOS_CONFIG_FAMILY),mrwolf)
PULP_SRCS += $(COMMON_ROOT)/target/mrwolf/system_mrwolf_metal.c
CPPFLAGS += -I"$(COMMON_ROOT)/target/mrwolf/include"
else ifeq ($(FREERTOS_CONFIG_FAMILY),gap8)
$(error "GAP8 is not supported (yet)")
else
$(error "FREERTOS_CONFIG_FAMILY is unset. Run `source env/platform-you-want.sh' \
	from the freertos project's root folder.")
endif
# drivers and runtime
PULP_SRCS += $(addprefix $(COMMON_ROOT)/metal/, \
		fll.c timer_irq.c irq.c soc_eu.c gpio.c pinmux.c)
CPPFLAGS += -I"$(COMMON_ROOT)/metal/include"

