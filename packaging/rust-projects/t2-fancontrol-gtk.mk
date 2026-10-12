PROJECT_DIR := $(ROOT_DIR)/apps/t2-fan-control

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-fancontrol-gtk|$(BINDIR)/t2-fancontrol-gtk|0755 \
	$(PROJECT_DIR)/org.t2fancontrol.gtk.desktop|$(DATADIR)/applications/org.t2fancontrol.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2fancontrol.gtk.svg|$(DATADIR)/icons/hicolor/scalable/apps/org.t2fancontrol.gtk.svg|0644 \
	$(PROJECT_DIR)/systemd/t2-fancontrol.service|$(SYSTEMD_UNIT_DIR)/t2-fancontrol.service|0644

USER_STAGED_FILES := \
	$(TARGET_DIR)/release/t2-fancontrol-gtk|$(USER_PREFIX)/bin/t2-fancontrol-gtk|0755 \
	$(PROJECT_DIR)/org.t2fancontrol.gtk.desktop|$(USER_PREFIX)/share/applications/org.t2fancontrol.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2fancontrol.gtk.svg|$(USER_PREFIX)/share/icons/hicolor/scalable/apps/org.t2fancontrol.gtk.svg|0644

ACTIVATE_HOOK = \
	if $(SYSTEMCTL) list-unit-files t2fanrd.service >/dev/null 2>&1; then $(SYSTEMCTL) disable --now t2fanrd.service || true; fi; \
	$(SYSTEMCTL) daemon-reload; \
	$(SYSTEMCTL) enable t2-fancontrol.service; \
	$(SYSTEMCTL) restart t2-fancontrol.service; \
	$(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"

DEACTIVATE_HOOK = \
	$(SYSTEMCTL) disable --now t2-fancontrol.service || true; \
	if [ -d "$(DATADIR)/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; fi; \
	$(SYSTEMCTL) daemon-reload; \
	if $(SYSTEMCTL) list-unit-files t2fanrd.service >/dev/null 2>&1; then $(SYSTEMCTL) enable --now t2fanrd.service || true; fi

USER_ACTIVATE_HOOK = $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(USER_PREFIX)/share/icons/hicolor"
USER_DEACTIVATE_HOOK = if [ -d "$(USER_PREFIX)/share/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(USER_PREFIX)/share/icons/hicolor"; fi
