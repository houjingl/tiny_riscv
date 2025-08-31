# ====== Config ======
OUT_DIR := out
IVERILOG := iverilog
VVP := vvp

# iverilog flags（可按需加 -Wall 等）
IVERILOG_FLAGS := -g2012

# Include search paths（按你的 include 写法调整/追加）
INC_FLAGS := -I . -I multicycle
# ====== Sources ======
# 所有非 testbench 的 .sv/.v（稳定排序，避免编译顺序抖动）
SRCS := $(shell find core peripheral -type f \( -name "*.sv" -o -name "*.v" \) ! -path "core/testbench/*" | sort)

# 默认 multi-cycle 顶层模块名（若不同：make TOP=<your_top>）
TOP ?= multi_cycle
MC_OUTPUT := $(OUT_DIR)/multi_cycle_top.vvp

# ====== Multicycle testbenches ======
MC_TB_DIR := core/testbench/multi_cycle
MC_TB_SRCS := $(wildcard $(MC_TB_DIR)/*_tb.sv)
MC_TB_VVPS := $(patsubst $(MC_TB_DIR)/%_tb.sv,$(OUT_DIR)/%_tb.vvp,$(MC_TB_SRCS))

# 常见头文件（例如 utils.svh），变化时触发重编译
TB_COMMON_HEADERS := $(wildcard $(MC_TB_DIR)/*.svh) $(wildcard core/testbench/*.svh)

# VCD 输出目录（由 tb 通过 +VCD_PATH 使用）
TB_VCD_BASE_PATH := $(MC_TB_DIR)/vcd

# ====== Phony targets ======
.PHONY: all build_mc_top run_mc_top build_mc_tb run_mc_tb clean list_mc_tb

all: run_mc_tb

$(OUT_DIR):
	@mkdir -p $@

$(TB_VCD_BASE_PATH):
	@mkdir -p $@

# ====== Build & run multi-cycle top (optional) ======
build_mc_top: $(MC_OUTPUT)

$(MC_OUTPUT): $(SRCS) | $(OUT_DIR)
	@echo "Compiling multi-cycle top -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) $(INC_FLAGS) -s $(TOP) -o $@ $(SRCS)

run_mc_top: build_mc_top
	$(VVP) $(MC_OUTPUT)

# ====== Build all multicycle TBs ======
build_mc_tb: $(MC_TB_VVPS)

# 单个 tb 的模式规则：源 + 公共头 + 所有设计源码
$(OUT_DIR)/%_tb.vvp: $(MC_TB_DIR)/%_tb.sv $(TB_COMMON_HEADERS) $(SRCS) | $(OUT_DIR)
	@echo "Compiling tb -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) $(INC_FLAGS) -o $@ $(SRCS) $<

# ====== Run all multicycle TBs ======
run_mc_tb: build_mc_tb $(TB_VCD_BASE_PATH)
	@if [ -z "$(MC_TB_SRCS)" ]; then \
		echo "No multicycle testbenches found under $(MC_TB_DIR)"; exit 0; \
	fi; \
	failed=0; \
	for tb in $(MC_TB_VVPS); do \
		echo "Running $$tb..."; \
		if ! $(VVP) $$tb +VCD_PATH=$(TB_VCD_BASE_PATH); then \
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

# 列出发现到的 TB
list_mc_tb:
	@echo "Discovered multicycle TBs:"; \
	for f in $(MC_TB_SRCS); do echo " - $$f"; done

# 清理
clean:
	@rm -rf $(OUT_DIR) $(TB_VCD_BASE_PATH)
