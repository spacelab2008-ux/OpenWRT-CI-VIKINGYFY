

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
							
