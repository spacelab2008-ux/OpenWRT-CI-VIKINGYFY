#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

#移除luci-app-attendedsysupgrade
find ./feeds/luci/collections/ -type f -name "Makefile" -exec sed -i "/attendedsysupgrade/d" {} +
#修改默认主题
find ./feeds/luci/collections/ -type f -name "Makefile" -exec sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" {} +
#修改immortalwrt.lan关联IP
find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js" -exec sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" {} +
#添加编译日期标识
find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js" -exec sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" {} +

WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_UC" ]; then
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
		sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
		fi

		CFG_FILE="./package/base-files/files/bin/config_generate"
		sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
		sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

		echo "CONFIG_PACKAGE_luci=y" >> ./.config
		echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
		echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
		echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

		if [ -f "$GITHUB_WORKSPACE/Config/PRIVATE.txt" ]; then
			echo "Applying private configurations from PRIVATE.txt..."
				cat $GITHUB_WORKSPACE/Config/PRIVATE.txt >> ./.config
				fi

				if [ -n "$WRT_PACKAGE" ]; then
					echo -e "$WRT_PACKAGE" >> ./.config
					fi

					DTS_PATH="./target/linux/qualcommax/dts/"
					if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
						if [[ "$WRT_WIFI" == "WIFI-NO" ]]; then
								find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
										echo "qualcommax set up nowifi successfully!"
											fi
											fi

											# ========== eBPF 内核配置（直接写入 .config，不修改 config-default） ==========
											echo "CONFIG_DEVEL=y" >> ./.config
											echo "CONFIG_KERNEL_DEBUG_INFO=y" >> ./.config
											echo "CONFIG_KERNEL_DEBUG_INFO_REDUCED=n" >> ./.config
											echo "CONFIG_KERNEL_DEBUG_INFO_BTF=y" >> ./.config
											echo "CONFIG_KERNEL_CGROUPS=y" >> ./.config
											echo "CONFIG_KERNEL_CGROUP_BPF=y" >> ./.config
											echo "CONFIG_KERNEL_BPF_EVENTS=y" >> ./.config
											echo "CONFIG_BPF_TOOLCHAIN_HOST=y" >> ./.config
											echo "CONFIG_KERNEL_XDP_SOCKETS=y" >> ./.config
											echo "CONFIG_PACKAGE_kmod-xdp-sockets-diag=y" >> ./.config
											echo "eBPF config applied to .config"
											
