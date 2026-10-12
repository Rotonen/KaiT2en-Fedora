PROJECT_DIR := $(ROOT_DIR)/apps/t2-hybrid-gpu-control

STAGED_FILES := \
	$(TARGET_DIR)/release/t2-hybrid-gpu-control|$(BINDIR)/t2-hybrid-gpu-control|0755 \
	$(PROJECT_DIR)/contrib/t2-hybrid-gpu-control-helper|$(LIBEXECDIR)/t2-hybrid-gpu-control-helper|0755 \
	$(PROJECT_DIR)/contrib/t2-hybrid-gpu-control-status|$(LIBEXECDIR)/t2-hybrid-gpu-control-status|0755 \
	$(PROJECT_DIR)/org.t2hybridgpucontrol.gtk.desktop|$(DATADIR)/applications/org.t2hybridgpucontrol.gtk.desktop|0644 \
	$(PROJECT_DIR)/assets/icons/hicolor/scalable/apps/org.t2hybridgpucontrol.gtk.svg|$(DATADIR)/icons/hicolor/scalable/apps/org.t2hybridgpucontrol.gtk.svg|0644 \
	$(PROJECT_DIR)/contrib/org.t2hybridgpucontrol.policy|$(POLICY_DIR)/org.t2hybridgpucontrol.policy|0644 \
	$(PROJECT_DIR)/contrib/org.t2hybridgpucontrol.status.policy|$(POLICY_DIR)/org.t2hybridgpucontrol.status.policy|0644 \
	$(PROJECT_DIR)/contrib/90-kait2en-gsk-renderer.conf|/etc/environment.d/90-kait2en-gsk-renderer.conf|0644

ACTIVATE_HOOK = \
	for unit in kait2en-dgpu-off.service kait2en-dgpu-suspend.service kait2en-amdgpu-profile.service kait2en-amdgpu-profile-resume.service; do \
		$(SYSTEMCTL) disable --now "$$unit" || true; \
		rm -f "$(SYSTEMD_OVERRIDE_DIR)/$$unit" "$(SYSTEMD_UNIT_DIR)/$$unit" "$(SYSTEMD_VENDOR_DIR)/$$unit"; \
	done; \
	rm -rf "$(RUNDIR)/t2-dgpu-control" "$(RUNDIR)/t2-hybrid-gpu-control"; \
	$(SYSTEMCTL) daemon-reload; \
	if command -v $(FLATPAK) >/dev/null 2>&1; then $(FLATPAK) override --system --env=GSK_RENDERER=ngl; fi; \
	$(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; \
	$(SYSTEMCTL) daemon-reload

DEACTIVATE_HOOK = \
	for unit in kait2en-dgpu-off.service kait2en-dgpu-suspend.service kait2en-amdgpu-profile.service kait2en-amdgpu-profile-resume.service; do \
		$(SYSTEMCTL) disable --now "$$unit" || true; \
		rm -f "$(SYSTEMD_OVERRIDE_DIR)/$$unit" "$(SYSTEMD_UNIT_DIR)/$$unit" "$(SYSTEMD_VENDOR_DIR)/$$unit"; \
	done; \
	rm -rf "$(RUNDIR)/t2-dgpu-control" "$(RUNDIR)/t2-hybrid-gpu-control"; \
	$(SYSTEMCTL) daemon-reload; \
	if [ -f "$(FLATPAK_OVERRIDES)" ]; then \
		override_tmp="$(FLATPAK_OVERRIDES).new"; \
		awk '$$0 != "GSK_RENDERER=ngl"' "$(FLATPAK_OVERRIDES)" >"$$override_tmp"; \
		chmod 0644 "$$override_tmp"; \
		mv -f "$$override_tmp" "$(FLATPAK_OVERRIDES)"; \
	fi; \
	if [ -d "$(DATADIR)/icons/hicolor" ]; then $(GTK_UPDATE_ICON_CACHE) --force --ignore-theme-index "$(DATADIR)/icons/hicolor"; fi; \
	$(SYSTEMCTL) daemon-reload
