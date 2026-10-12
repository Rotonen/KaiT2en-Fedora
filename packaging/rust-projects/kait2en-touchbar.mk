PROJECT_DIR := $(ROOT_DIR)/apps/t2-touchbar

STAGED_FILES := \
	$(TARGET_DIR)/release/kait2en-touchbar|$(BINDIR)/kait2en-touchbar|0755 \
	$(PROJECT_DIR)/integration/systemd/user/kait2en-touchbar.service|$(PREFIX)/lib/systemd/user/kait2en-touchbar.service|0644 \
	$(PROJECT_DIR)/integration/systemd/system/kait2en-touchbar-attach.service|$(SYSTEMD_UNIT_DIR)/kait2en-touchbar-attach.service|0644 \
	$(PROJECT_DIR)/integration/udev/99-zz-kait2en-touchbar.rules|$(PREFIX)/lib/udev/rules.d/99-zz-kait2en-touchbar.rules|0644 \
	$(PROJECT_DIR)/THIRD-PARTY-NOTICES.md|$(DATADIR)/licenses/kait2en-touchbar/THIRD-PARTY-NOTICES.md|0644

STAGE_HOOK = \
	config="$(DESTDIR)$(SYSCONFDIR)/kait2en/touchbar.toml"; \
	if [ ! -e "$$config" ]; then \
		mkdir -p "$$(dirname "$$config")"; \
		$(INSTALL) -m 0644 "$(PROJECT_DIR)/config/touchbar.toml" "$$config.new"; \
		mv -f "$$config.new" "$$config"; \
	fi; \
	rm -f "$(DESTDIR)$(PREFIX)/lib/modprobe.d/kait2en-touchbar.conf"

ACTIVATE_HOOK = \
	$(SYSTEMCTL) daemon-reload; \
	$(SYSTEMCTL) --global enable kait2en-touchbar.service; \
	$(SYSTEMCTL) enable kait2en-touchbar-attach.service; \
	$(UDEVADM) control --reload

DEACTIVATE_HOOK = \
	$(SYSTEMCTL) --global disable kait2en-touchbar.service || true; \
	$(SYSTEMCTL) disable --now kait2en-touchbar-attach.service 2>/dev/null || true; \
	$(UDEVADM) control --reload; \
	$(SYSTEMCTL) daemon-reload
