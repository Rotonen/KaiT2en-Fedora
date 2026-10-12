PROJECT_DIR := $(ROOT_DIR)/apps/t2-power-explorer

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-power-explorer|$(BINDIR)/t2-power-explorer|0755 \
	$(PROJECT_DIR)/t2-power-explorer-status|$(LIBEXECDIR)/t2-power-explorer-status|0755 \
	$(PROJECT_DIR)/org.t2powerexplorer.policy|$(POLICY_DIR)/org.t2powerexplorer.policy|0644 \
	$(PROJECT_DIR)/org.t2powerexplorer.gtk.desktop|$(DATADIR)/applications/org.t2powerexplorer.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2powerexplorer.gtk.svg|$(DATADIR)/icons/hicolor/scalable/apps/org.t2powerexplorer.gtk.svg|0644

ACTIVATE_HOOK = $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"
DEACTIVATE_HOOK = if [ -d "$(DATADIR)/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; fi
