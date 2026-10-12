ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

CARGO ?= cargo
CARGO_FLAGS ?= --locked
TARGET_DIR ?= $(ROOT_DIR)/target
PROJECT ?=
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
LIBEXECDIR ?= $(PREFIX)/libexec
DATADIR ?= $(PREFIX)/share
SYSCONFDIR ?= /etc
SYSTEMD_UNIT_DIR ?= $(PREFIX)/lib/systemd/system
SYSTEMD_OVERRIDE_DIR ?= /etc/systemd/system
SYSTEMD_VENDOR_DIR ?= /usr/lib/systemd/system
RUNDIR ?= /run
FLATPAK_OVERRIDES ?= /var/lib/flatpak/overrides/global
POLICY_DIR ?= /usr/share/polkit-1/actions
USER_PREFIX ?= $(HOME)/.local
INSTALL ?= install
GTK_UPDATE_ICON_CACHE ?= gtk-update-icon-cache
SYSTEMCTL ?= systemctl
UDEVADM ?= udevadm
FLATPAK ?= flatpak
RESTORECON ?= restorecon

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

PROJECT_DIRS := \
	apps/t2-dgpu-control \
	apps/t2-fan-control \
	apps/t2-force-click \
	apps/t2-hybrid-gpu-control \
	apps/t2-power-explorer \
	apps/t2-smc-control \
	apps/t2-touchbar \
	apps/t2-zone-power \
	t2-services/t2-ave \
	t2-services/t2-journal \
	t2-services/t2-touchid \
	t2-services/shared/protocols/t2-bridgexpc \
	t2-services/t2-journal/libs/macos-unifiedlogs \
	t2-services/t2-touchid/protocols/t2-biometrickit
LEGACY_TARGET_DIRS := $(addsuffix /target,$(addprefix $(ROOT_DIR)/,$(PROJECT_DIRS)))

STAGE_HOOK = :
UNINSTALL_HOOK = :
ACTIVATE_HOOK = :
DEACTIVATE_HOOK = :
USER_STAGE_HOOK = :
USER_UNINSTALL_HOOK = :
USER_ACTIVATE_HOOK = :
USER_DEACTIVATE_HOOK = :

ifneq ($(filter $(PROJECT),$(PROJECTS)),)
include $(ROOT_DIR)/packaging/rust-projects/$(PROJECT).mk
endif

.DEFAULT_GOAL := all
.PHONY: all validate-project build test check-build install uninstall activate deactivate \
	install-user uninstall-user activate-user deactivate-user clean clean-workspace rebuild

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
	rm -rf "$(PROJECT_DIR)/target"

clean-workspace:
	$(CARGO) clean --target-dir $(TARGET_DIR)
	rm -rf $(LEGACY_TARGET_DIRS)

define stage_files
	@set -e; \
	set -- $(subst |, ,$(STAGED_FILES)); \
	while [ "$$#" -ge 3 ]; do \
		source=$$1; destination=$$2; mode=$$3; shift 3; \
		staged="$(DESTDIR)$$destination"; \
		mkdir -p "$$(dirname "$$staged")"; \
		$(INSTALL) -m "$$mode" "$$source" "$$staged.new"; \
		mv -f "$$staged.new" "$$staged"; \
	done; \
	$(STAGE_HOOK)
endef

define uninstall_files
	@set -e; \
	set -- $(subst |, ,$(STAGED_FILES)); \
	while [ "$$#" -ge 3 ]; do \
		destination=$$2; shift 3; \
		rm -f "$(DESTDIR)$$destination" "$(DESTDIR)$$destination.new"; \
	done; \
	$(UNINSTALL_HOOK)
endef

define stage_user_files
	@set -e; \
	set -- $(subst |, ,$(USER_STAGED_FILES)); \
	while [ "$$#" -ge 3 ]; do \
		source=$$1; destination=$$2; mode=$$3; shift 3; \
		staged="$(DESTDIR)$$destination"; \
		mkdir -p "$$(dirname "$$staged")"; \
		$(INSTALL) -m "$$mode" "$$source" "$$staged.new"; \
		mv -f "$$staged.new" "$$staged"; \
	done; \
	$(USER_STAGE_HOOK)
endef

define uninstall_user_files
	@set -e; \
	set -- $(subst |, ,$(USER_STAGED_FILES)); \
	while [ "$$#" -ge 3 ]; do \
		destination=$$2; shift 3; \
		rm -f "$(DESTDIR)$$destination" "$(DESTDIR)$$destination.new"; \
	done; \
	$(USER_UNINSTALL_HOOK)
endef

install: check-build
	$(call stage_files)

uninstall: validate-project
	$(call uninstall_files)

activate: validate-project
	@test -z "$(DESTDIR)" || { echo "error: activate cannot be used with DESTDIR" >&2; exit 2; }
	@set -e; $(ACTIVATE_HOOK)

deactivate: validate-project
	@test -z "$(DESTDIR)" || { echo "error: deactivate cannot be used with DESTDIR" >&2; exit 2; }
	@set -e; $(DEACTIVATE_HOOK)

install-user: check-build
	@test -n "$(USER_STAGED_FILES)" || { echo "error: PROJECT=$(PROJECT) has no per-user install" >&2; exit 2; }
	$(call stage_user_files)

uninstall-user: validate-project
	@test -n "$(USER_STAGED_FILES)" || { echo "error: PROJECT=$(PROJECT) has no per-user install" >&2; exit 2; }
	$(call uninstall_user_files)

activate-user: validate-project
	@test -n "$(USER_STAGED_FILES)" || { echo "error: PROJECT=$(PROJECT) has no per-user install" >&2; exit 2; }
	@test -z "$(DESTDIR)" || { echo "error: activate-user cannot be used with DESTDIR" >&2; exit 2; }
	@set -e; $(USER_ACTIVATE_HOOK)

deactivate-user: validate-project
	@test -n "$(USER_STAGED_FILES)" || { echo "error: PROJECT=$(PROJECT) has no per-user install" >&2; exit 2; }
	@test -z "$(DESTDIR)" || { echo "error: deactivate-user cannot be used with DESTDIR" >&2; exit 2; }
	@set -e; $(USER_DEACTIVATE_HOOK)

rebuild: clean
	$(MAKE) --no-print-directory PROJECT=$(PROJECT) build
