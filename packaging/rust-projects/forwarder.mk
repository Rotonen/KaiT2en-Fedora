.DEFAULT_GOAL := all
.PHONY: all build test check-build install uninstall activate deactivate \
	install-user uninstall-user activate-user deactivate-user clean clean-workspace rebuild

all build test check-build install uninstall activate deactivate \
	install-user uninstall-user activate-user deactivate-user clean clean-workspace rebuild:
	+$(MAKE) --no-print-directory -C "$(ROOT_DIR)" PROJECT="$(PROJECT)" $@
