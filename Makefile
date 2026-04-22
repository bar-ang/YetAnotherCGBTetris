# Game Boy build Makefile
# Usage:
#   make GAME=mygame
# or set GAME variable inside this file.

# Default game name (without extension)
GAME ?= yatetris
MAIN ?= main

# ----------------------------------------
# Directories
# ----------------------------------------
SRC_DIR ?= src
ASSETS_DIR ?= assets
BUILD_DIR ?= build

# ----------------------------------------
# Collect all files recursively
# ----------------------------------------
SRC_FILES := $(shell find $(SRC_DIR) -type f)
ASSET_FILES := $(shell \
	if [ -d "$(ASSETS_DIR)" ]; then \
		find "$(ASSETS_DIR)" -type f; \
	fi \
)

ALL_INPUTS := $(SRC_FILES) $(ASSET_FILES)

# Output file
TARGET := $(BUILD_DIR)/$(GAME)

# Tools
RGBASM = rgbasm
RGBLINK = rgblink
RGBFIX = rgbfix

# Flags
RGBFIXFLAGS = -v -p 0xFF

# Default rule
all: $(TARGET).gb

# ----------------------------------------
# Rule to build output
# Re-run this rule if ANY source/asset changes
# ----------------------------------------
$(TARGET).o: $(ALL_INPUTS)
	@mkdir -p $(BUILD_DIR)
	$(RGBASM) -o $@ $(SRC_DIR)/$(MAIN).asm


$(TARGET).gb: $(TARGET).o
	$(RGBLINK) -o $@ $<
	$(RGBFIX) $(RGBFIXFLAGS) $@

linker_test:
	@echo "=== TEST COMPILE START ==="
	@echo "Source directory: $(SRC_DIR)"
	@echo "Files:"
	@for f in $(SRC_FILES); do echo "  - $$f"; done
	@echo ""

	@set -e; \
	for f in $(SRC_FILES); do \
		echo "----------------------------------------"; \
		echo "Compiling: $$f"; \
		obj=$$(mktemp); \
		gb=$$(mktemp); \
		rgbasm "$$f" -o $$obj; \
		rgblink $$obj -o $$gb; \
		rm -f $$obj $$gb; \
		echo "  ✔ OK: $$f"; \
	done; \
	echo "----------------------------------------"; \
	echo "=== ALL FILES COMPILED SUCCESSFULLY ==="

# ----------------------------------------
# Cleaning
# ----------------------------------------
clean:
	rm -rf $(BUILD_DIR)


.PHONY: all clean test_compile

