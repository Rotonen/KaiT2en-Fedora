PROJECT_DIR := $(ROOT_DIR)/apps/t2-force-click

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-force-click|$(BINDIR)/t2-force-click|0755 \
	$(PROJECT_DIR)/org.t2forceclick.gtk.desktop|$(DATADIR)/applications/org.t2forceclick.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2forceclick.gtk.svg|$(DATADIR)/icons/hicolor/scalable/apps/org.t2forceclick.gtk.svg|0644 \
	$(PROJECT_DIR)/systemd/t2-force-click.service|$(SYSTEMD_UNIT_DIR)/t2-force-click.service|0644

USER_STAGED_FILES := \
	$(TARGET_DIR)/release/t2-force-click|$(USER_PREFIX)/bin/t2-force-click|0755 \
	$(PROJECT_DIR)/org.t2forceclick.gtk.desktop|$(USER_PREFIX)/share/applications/org.t2forceclick.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2forceclick.gtk.svg|$(USER_PREFIX)/share/icons/hicolor/scalable/apps/org.t2forceclick.gtk.svg|0644

ACTIVATE_HOOK = \
	$(SYSTEMCTL) daemon-reload; \
	$(SYSTEMCTL) enable t2-force-click.service; \
	$(SYSTEMCTL) restart t2-force-click.service; \
	$(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"

DEACTIVATE_HOOK = \
	$(SYSTEMCTL) disable --now t2-force-click.service || true; \
	if [ -d "$(DATADIR)/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; fi; \
	$(SYSTEMCTL) daemon-reload

USER_ACTIVATE_HOOK = $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(USER_PREFIX)/share/icons/hicolor"
USER_DEACTIVATE_HOOK = if [ -d "$(USER_PREFIX)/share/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(USER_PREFIX)/share/icons/hicolor"; fi
