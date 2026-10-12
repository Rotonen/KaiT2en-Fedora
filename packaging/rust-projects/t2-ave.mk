PROJECT_DIR := $(ROOT_DIR)/t2-services/t2-ave

STAGED_FILES := \
	$(TARGET_DIR)/release/t2remote|$(BINDIR)/t2remote|0755 \
	$(PROJECT_DIR)/integration/systemd/t2-ave-suspend|$(LIBEXECDIR)/t2-services/sleep.d/t2-ave|0755

STAGE_HOOK = \
	unit="$(DESTDIR)$(SYSTEMD_UNIT_DIR)/kait2en-t2-remote.service"; \
	mkdir -p "$$(dirname "$$unit")"; \
	$(INSTALL) -m 0644 "$(PROJECT_DIR)/integration/systemd/kait2en-t2-remote.service" "$$unit.new"; \
	sed 's|@BINDIR@|$(BINDIR)|g' "$$unit.new" >"$$unit.rendered"; \
	chmod 0644 "$$unit.rendered"; \
	mv -f "$$unit.rendered" "$$unit"; \
	rm -f "$$unit.new"

ACTIVATE_HOOK = \
	$(SYSTEMCTL) daemon-reload; \
	$(SYSTEMCTL) enable kait2en-t2-remote.service

DEACTIVATE_HOOK = \
	$(SYSTEMCTL) disable --now kait2en-t2-remote.service || true; \
	$(SYSTEMCTL) daemon-reload
