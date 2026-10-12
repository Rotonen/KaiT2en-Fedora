PROJECT_DIR := $(ROOT_DIR)/apps/t2-zone-power

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-zonepower-gtk|$(BINDIR)/t2-zonepower-gtk|0755 \
	$(PROJECT_DIR)/org.t2zonepower.gtk.desktop|$(DATADIR)/applications/org.t2zonepower.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2zonepower.gtk.svg|$(DATADIR)/icons/hicolor/scalable/apps/org.t2zonepower.gtk.svg|0644 \
	$(PROJECT_DIR)/systemd/t2-zonepowerd.service|$(SYSTEMD_UNIT_DIR)/t2-zonepowerd.service|0644

USER_STAGED_FILES := \
	$(TARGET_DIR)/release/t2-zonepower-gtk|$(USER_PREFIX)/bin/t2-zonepower-gtk|0755 \
	$(PROJECT_DIR)/org.t2zonepower.gtk.desktop|$(USER_PREFIX)/share/applications/org.t2zonepower.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2zonepower.gtk.svg|$(USER_PREFIX)/share/icons/hicolor/scalable/apps/org.t2zonepower.gtk.svg|0644

ACTIVATE_HOOK = \
	$(SYSTEMCTL) daemon-reload; \
	$(SYSTEMCTL) enable t2-zonepowerd.service; \
	$(SYSTEMCTL) restart t2-zonepowerd.service; \
	$(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"

DEACTIVATE_HOOK = \
	$(SYSTEMCTL) disable --now t2-zonepowerd.service || true; \
	if [ -d "$(DATADIR)/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; fi; \
	$(SYSTEMCTL) daemon-reload

USER_ACTIVATE_HOOK = $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(USER_PREFIX)/share/icons/hicolor"
USER_DEACTIVATE_HOOK = if [ -d "$(USER_PREFIX)/share/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(USER_PREFIX)/share/icons/hicolor"; fi
