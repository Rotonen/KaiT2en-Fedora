ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

CARGO ?= cargo
CARGO_FLAGS ?= --locked
TARGET_DIR ?= $(ROOT_DIR)/target
PROJECT ?=

PROJECTS := \
	t2-dgpu-control \
	t2-fancontrol-gtk \
	t2-force-click \
	t2-hybrid-gpu-control \
	t2-power-explorer \
	t2-smc-control \
	kait2en-touchbar \
	t2-zonepower-gtk \
	t2-ave \
	t2-journal \
	t2-touchid

BINARIES_t2-dgpu-control := t2-dgpu-control
BINARIES_t2-fancontrol-gtk := t2-fancontrol-gtk
BINARIES_t2-force-click := t2-force-click
BINARIES_t2-hybrid-gpu-control := t2-hybrid-gpu-control
BINARIES_t2-power-explorer := t2-power-explorer
BINARIES_t2-smc-control := t2-smc-control
BINARIES_kait2en-touchbar := kait2en-touchbar
BINARIES_t2-zonepower-gtk := t2-zonepower-gtk
BINARIES_t2-ave := t2remote
BINARIES_t2-journal := t2journal
BINARIES_t2-touchid := t2-touchid

.DEFAULT_GOAL := all
.PHONY: all validate-project build test check-build clean

all: build

validate-project:
	@case " $(PROJECTS) " in \
		*" $(PROJECT) "*) ;; \
		*) printf 'error: set PROJECT to one of: %s\n' "$(PROJECTS)" >&2; exit 2 ;; \
	esac

build: validate-project
	$(CARGO) build --release $(CARGO_FLAGS) --package $(PROJECT) --target-dir $(TARGET_DIR)

test: validate-project
	$(CARGO) test $(CARGO_FLAGS) --package $(PROJECT) --target-dir $(TARGET_DIR)

check-build: validate-project
	@for bin in $(BINARIES_$(PROJECT)); do \
		test -x "$(TARGET_DIR)/release/$$bin" || { \
			printf "error: binary %s is missing; run 'make PROJECT=%s build' first\n" "$$bin" "$(PROJECT)" >&2; \
			exit 1; \
		}; \
	done

clean: validate-project
	$(CARGO) clean --package $(PROJECT) --target-dir $(TARGET_DIR)
