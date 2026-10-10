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
	#修改WIFI名称
		sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
			#修改WIFI密码
				sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
				fi


				CFG_FILE="./package/base-files/files/bin/config_generate"
				#修改默认IP地址
				sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
				#修改默认主机名
				sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE


				#配置文件修改
				echo "CONFIG_PACKAGE_luci=y" >> ./.config
				echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
				echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
				echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config


				#引入私有扩展配置
				if [ -f "$GITHUB_WORKSPACE/Config/PRIVATE.txt" ]; then
					echo "Applying private configurations from PRIVATE.txt..."
						cat $GITHUB_WORKSPACE/Config/PRIVATE.txt >> ./.config
						fi


						#手动调整的插件
						if [ -n "$WRT_PACKAGE" ]; then
							echo -e "$WRT_PACKAGE" >> ./.config
							fi


							#高通平台调整
							DTS_PATH="./target/linux/qualcommax/dts/"
							if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
								#无WIFI配置调整Q6大小
									if [[ "$WRT_WIFI" == "WIFI-NO" ]]; then
											find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
													echo "qualcommax set up nowifi successfully!"
														fi
														fi


														# ========== eBPF 内核配置（支持 DAED/eBPF 透明代理） ==========

														# 1. 用户态 eBPF 配置（写入 .config）
														cat >> ./.config <<'EOF'
														#eBPF
														CONFIG_DEVEL=y
														CONFIG_KERNEL_DEBUG_INFO=y
														CONFIG_KERNEL_DEBUG_INFO_REDUCED=n
														CONFIG_KERNEL_DEBUG_INFO_BTF=y
														CONFIG_KERNEL_CGROUPS=y
														CONFIG_KERNEL_CGROUP_BPF=y
														CONFIG_KERNEL_BPF_EVENTS=y
														CONFIG_BPF_TOOLCHAIN_HOST=y
														CONFIG_KERNEL_XDP_SOCKETS=y
														CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
														EOF

														# 2. 内核 BPF 配置（写入目标平台 config-default）
														TARGET_DIR="./target/linux/$WRT_TARGET"
														if [ -d "$TARGET_DIR" ]; then
														  CONFIG_DEFAULT=$(find $TARGET_DIR -name "config-default" -path "*/$WRT_SUBTARGET/*" 2>/dev/null | head -n 1)
														    if [ -z "$CONFIG_DEFAULT" ]; then
															    CONFIG_DEFAULT=$(find $TARGET_DIR -maxdepth 2 -name "config-default" 2>/dev/null | head -n 1)
																  fi
																    if [ -n "$CONFIG_DEFAULT" ] && [ -f "$CONFIG_DEFAULT" ]; then
																	    cat >> $CONFIG_DEFAULT <<'EOF'
																		CONFIG_BPF=y
																		CONFIG_BPF_SYSCALL=y
																		CONFIG_BPF_JIT=y
																		CONFIG_CGROUPS=y
																		CONFIG_KPROBES=y
																		CONFIG_NET_INGRESS=y
																		CONFIG_NET_EGRESS=y
																		CONFIG_NET_SCH_INGRESS=m
																		CONFIG_NET_CLS_BPF=m
																		CONFIG_NET_CLS_ACT=y
																		CONFIG_BPF_STREAM_PARSER=y
																		CONFIG_DEBUG_INFO=y
																		# CONFIG_DEBUG_INFO_REDUCED is not set
																		CONFIG_DEBUG_INFO_BTF=y
																		CONFIG_KPROBE_EVENTS=y
																		CONFIG_BPF_EVENTS=y
																		EOF
																		    echo "eBPF kernel config applied to $CONFIG_DEFAULT"
																			  else
																			      echo "Warning: config-default not found for $WRT_TARGET/$WRT_SUBTARGET"
																				    fi
																					fi
																					
