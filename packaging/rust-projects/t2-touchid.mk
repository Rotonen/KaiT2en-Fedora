PROJECT_DIR := $(ROOT_DIR)/t2-services/t2-touchid

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-touchid|$(BINDIR)/t2-touchid|0755 \
	$(PROJECT_DIR)/integration/fprintd/fprintd-kait2en-t2-touchid.conf|$(SYSTEMD_UNIT_DIR)/fprintd.service.d/kait2en-t2-touchid.conf|0644 \
	$(PROJECT_DIR)/integration/dbus/org.kait2en.TouchId.conf|$(DATADIR)/dbus-1/system.d/org.kait2en.TouchId.conf|0644

STAGE_HOOK = \
	unit="$(DESTDIR)$(SYSTEMD_UNIT_DIR)/kait2en-t2-touchid.service"; \
	mkdir -p "$$(dirname "$$unit")"; \
	$(INSTALL) -m 0644 "$(PROJECT_DIR)/integration/systemd/kait2en-t2-touchid.service" "$$unit.new"; \
	sed 's|@BINDIR@|$(BINDIR)|g' "$$unit.new" >"$$unit.rendered"; \
	chmod 0644 "$$unit.rendered"; \
	mv -f "$$unit.rendered" "$$unit"; \
	rm -f "$$unit.new"; \
	config="$(DESTDIR)$(SYSCONFDIR)/kait2en/t2-touchid.conf"; \
	if [ ! -e "$$config" ]; then \
		mkdir -p "$$(dirname "$$config")"; \
		$(INSTALL) -m 0644 "$(PROJECT_DIR)/config/t2-touchid.conf" "$$config.new"; \
		mv -f "$$config.new" "$$config"; \
	fi

ACTIVATE_HOOK = \
	$(SYSTEMCTL) daemon-reload; \
	if [ -d "$(RUNDIR)/t2-touchid" ]; then $(RESTORECON) -R "$(RUNDIR)/t2-touchid"; fi; \
	$(SYSTEMCTL) enable kait2en-t2-touchid.service; \
	$(SYSTEMCTL) restart kait2en-t2-touchid.service

DEACTIVATE_HOOK = \
	$(SYSTEMCTL) disable --now kait2en-t2-touchid.service || true; \
	$(SYSTEMCTL) daemon-reload
