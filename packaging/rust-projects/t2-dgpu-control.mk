PROJECT_DIR := $(ROOT_DIR)/apps/t2-dgpu-control

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-dgpu-control|$(BINDIR)/t2-dgpu-control|0755 \
	$(PROJECT_DIR)/contrib/t2-dgpu-control-helper|$(LIBEXECDIR)/t2-dgpu-control-helper|0755 \
	$(PROJECT_DIR)/contrib/t2-dgpu-control-status|$(LIBEXECDIR)/t2-dgpu-control-status|0755 \
	$(PROJECT_DIR)/org.t2dgpucontrol.gtk.desktop|$(DATADIR)/applications/org.t2dgpucontrol.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2dgpucontrol.gtk.svg|$(DATADIR)/icons/hicolor/scalable/apps/org.t2dgpucontrol.gtk.svg|0644 \
	$(PROJECT_DIR)/systemd/kait2en-dgpu-off.service|$(SYSTEMD_UNIT_DIR)/kait2en-dgpu-off.service|0644 \
	$(PROJECT_DIR)/systemd/kait2en-dgpu-suspend.service|$(SYSTEMD_UNIT_DIR)/kait2en-dgpu-suspend.service|0644 \
	$(PROJECT_DIR)/systemd/kait2en-amdgpu-profile.service|$(SYSTEMD_UNIT_DIR)/kait2en-amdgpu-profile.service|0644 \
	$(PROJECT_DIR)/systemd/kait2en-amdgpu-profile-resume.service|$(SYSTEMD_UNIT_DIR)/kait2en-amdgpu-profile-resume.service|0644 \
	$(PROJECT_DIR)/contrib/org.t2dgpucontrol.policy|$(POLICY_DIR)/org.t2dgpucontrol.policy|0644 \
	$(PROJECT_DIR)/contrib/org.t2dgpucontrol.status.policy|$(POLICY_DIR)/org.t2dgpucontrol.status.policy|0644

ACTIVATE_HOOK = \
	for unit in kait2en-dgpu-off.service kait2en-dgpu-suspend.service kait2en-amdgpu-profile.service kait2en-amdgpu-profile-resume.service; do \
		enabled=0; $(SYSTEMCTL) is-enabled --quiet "$$unit" && enabled=1; \
		rm -f "$(SYSTEMD_OVERRIDE_DIR)/$$unit"; \
		$(SYSTEMCTL) daemon-reload; \
		if [ "$$enabled" -eq 1 ]; then $(SYSTEMCTL) enable "$$unit"; fi; \
	done; \
	if $(SYSTEMCTL) is-enabled --quiet kait2en-dgpu-off.service; then \
		$(SYSTEMCTL) enable kait2en-dgpu-suspend.service; \
	else \
		$(SYSTEMCTL) disable kait2en-dgpu-suspend.service; \
	fi; \
	$(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; \
	$(SYSTEMCTL) daemon-reload

DEACTIVATE_HOOK = \
	$(SYSTEMCTL) disable --now kait2en-dgpu-off.service kait2en-dgpu-suspend.service kait2en-amdgpu-profile.service kait2en-amdgpu-profile-resume.service || true; \
	if [ -d "$(DATADIR)/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; fi; \
	$(SYSTEMCTL) daemon-reload
