PROJECT_DIR := $(ROOT_DIR)/apps/t2-smc-control

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-smc-control|$(BINDIR)/t2-smc-control|0755 \
	$(PROJECT_DIR)/org.t2smccontrol.gtk.desktop|$(DATADIR)/applications/org.t2smccontrol.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2smccontrol.gtk.svg|$(DATADIR)/icons/hicolor/scalable/apps/org.t2smccontrol.gtk.svg|0644

ACTIVATE_HOOK = $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"
DEACTIVATE_HOOK = if [ -d "$(DATADIR)/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; fi
