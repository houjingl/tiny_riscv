# ========= Project layout (based on your repo) =========
# DUT (multi-cycle) RTL: core/multicycle/rtl/** (including hardware_module/)
# Testbenches:          core/multicycle/testbench/*_tb.sv
# Optional peripheral:  peripheral/uart_controller/rtl/**
#
# This Makefile ONLY targets multi-cycle; it ignores singlecycle and vivado trees.

# -------- Tools --------
IVERILOG := iverilog
VVP      := vvp

# Compiler flags
IVERILOG_FLAGS := -g2012 -Wall -Wimplicit -Wportbind -Wpinmissing -Wselect-range -Wtimescale -pfileline=1
# Include paths (left-to-right precedence). Add/remove as needed.
INC_FLAGS := \
  -I . \
  -I core \
  -I core/multicycle/rtl \
  -I core/multicycle/testbench \
  -I peripheral/uart_controller/rtl

# -------- Output / Paths --------
OUT_DIR        := out
MC_RTL_DIR     := core/multicycle/rtl
MC_TB_DIR      := core/multicycle/testbench
MC_HW_DIR      := core/multicycle/rtl/hardware_module
UART_RTL_DIR   := peripheral/uart_controller/rtl
VIVADO_DIR     := core/vivado
TOP            := core/multicycle/rtl/multi_cycle.sv

# VCD directory used by TB via +VCD_PATH plusarg
TB_VCD_BASE_PATH := $(MC_TB_DIR)/vcd

# Optional: include UART peripheral RTL by "make USE_UART=1 ..."
USE_UART ?= 0

# -------- Source discovery (stable order) --------
# Multi-cycle RTL only; exclude testbench and vivado explicitly.
MC_SRCS := $(shell find $(MC_RTL_DIR) -type f \( -name "*.sv" -o -name "*.v" \) | sort)
# Optional peripheral UART sources
UART_SRCS := $(if $(filter 1,$(USE_UART)),$(shell find $(UART_RTL_DIR) -type f \( -name "*.sv" -o -name "*.v" \) | sort),)

SRCS := $(MC_SRCS) $(UART_SRCS)

# Testbench sources/patterns
TB_SRCS := $(wildcard $(MC_TB_DIR)/*_tb.sv)
TB_VVPS := $(patsubst $(MC_TB_DIR)/%_tb.sv,$(OUT_DIR)/%_tb.vvp,$(TB_SRCS))

# Common TB headers to trigger rebuilds if changed
TB_HEADERS := $(wildcard $(MC_TB_DIR)/*.svh)

# -------- Phony targets --------
.PHONY: all build_mc_tb run_mc_tb list_mc_tb clean

all: run_mc_tb

# Ensure directories exist
$(OUT_DIR):
	@mkdir -p $@

$(TB_VCD_BASE_PATH):
	@mkdir -p $@

# -------- Build all multicycle TBs --------
build_mc_tb: $(TB_VVPS) $(TB_SRCS) $(TB_HEADERS) $(SRCS)

# Pattern rule: compile a single TB (design SRCS + the TB)
# NOTE: we do not pull in singlecycle or vivado files.
$(OUT_DIR)/%_tb.vvp: $(MC_TB_DIR)/%_tb.sv $(TB_HEADERS) $(SRCS) | $(OUT_DIR)
	@echo "Compiling TB -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) $(INC_FLAGS) -o $@ $(SRCS) $<

# -------- Run all multicycle TBs --------
run_mc_tb: build_mc_tb $(TB_VCD_BASE_PATH)
	@if [ -z "$(TB_SRCS)" ]; then \
		echo "No multicycle testbenches found under $(MC_TB_DIR)"; exit 0; \
	fi; \
	failed=0; \
	for tb in $(TB_VVPS); do \
		echo "Running $$tb..."; \
		if ! $(VVP) $$tb +VCD_PATH=$(abspath $(TB_VCD_BASE_PATH)); then \
			echo "\033[31mFAILED: $$tb\033[0m"; failed=1; \
		else \
			echo "\033[32mPASSED: $$tb\033[0m"; \
		fi; \
		echo ""; \
	done; \
	if [ $$failed -eq 1 ]; then \
		echo "\033[31mSome testbenches failed!\033[0m"; exit 1; \
	else \
		echo "\033[32mAll testbenches passed!\033[0m"; \
	fi

# List discovered TBs
list_mc_tb:
	@echo "Discovered multicycle TBs:"; \
	for f in $(TB_SRCS); do echo " - $$f"; done

# Clean generated artifacts
clean:
	@rm -rf $(OUT_DIR) $(TB_VCD_BASE_PATH)