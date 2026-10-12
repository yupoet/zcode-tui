#!/usr/bin/env bash
# ZCode TUI 一键安装脚本 —— Ubuntu (x86_64) 已验证
# 安装社区封装的 zcode-app-cli：内置从官方桌面版 .deb 提取的官方 runtime，
# 界面/版本号与桌面客户端一致（如 v3.14.5-34），无需从源码构建。
set -euo pipefail

# ---- 可配置项 ----
PKG_NAME="${PKG_NAME:-zcode-app-cli}"
PKG_VERSION="${PKG_VERSION:-latest}"            # 锁定版本示例：3.14.5-34
MIN_NODE_MAJOR=22
MIN_NODE_MINOR=19                               # 要求 Node.js >= 22.19.0
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
RENAME_EXISTING="${RENAME_EXISTING:-1}"         # ~/.local/bin/zcode 遮蔽 npm 版时改名为 zcode-oss

# 绕过失效的本地代理（proxy 软件未开时 npm/git 会 ECONNREFUSED）
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY || true

# ---- 1. 检查 Node >= 22.19 ----
if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: 未找到 node，请先安装 Node.js >= ${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}.0" >&2
  exit 1
fi
node_ver="$(node --version)"                    # 形如 v22.23.2
node_major_minor="${node_ver#v}"
if [ "$(printf '%s\n' "${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}" "$node_major_minor" | sort -V | head -1)" != "${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}" ]; then
  echo "ERROR: Node 版本过低: $node_ver（要求 >= ${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}.0）" >&2
  exit 1
fi
echo "==> Node: $node_ver"

# ---- 2. 安装 npm 包（npm registry 可直连；约 88MB 解压体积）----
echo "==> 安装 $PKG_NAME@$PKG_VERSION"
npm install -g "$PKG_NAME@$PKG_VERSION"

NPM_BIN="$(npm config get prefix)/bin"
PKG_BIN="$NPM_BIN/zcode"
[ -x "$PKG_BIN" ] || { echo "ERROR: 未找到安装产物: $PKG_BIN" >&2; exit 1; }

# ---- 3. 处理 PATH 遮蔽：~/.local/bin/zcode（源码构建 wrapper）优先于 npm 全局 bin ----
# which -a 的第一个命中必须是 npm 版，否则 TUI 版本对不上桌面客户端
first_hit="$(which -a zcode 2>/dev/null | head -1 || true)"
if [ "$first_hit" != "$PKG_BIN" ]; then
  local_wrap="$BIN_DIR/zcode"
  if [ "$first_hit" = "$local_wrap" ] && [ "$RENAME_EXISTING" = "1" ]; then
    mv "$local_wrap" "$BIN_DIR/zcode-oss"
    echo "==> 已将原有源码构建入口改名为 $BIN_DIR/zcode-oss（保留备用）"
    first_hit="$(which -a zcode 2>/dev/null | head -1 || true)"
  fi
  if [ "$first_hit" != "$PKG_BIN" ]; then
    echo "WARN: zcode 当前命中 $first_hit 而非 $PKG_BIN，请调整 PATH 顺序" >&2
  fi
fi

# ---- 4. 验证 ----
echo
echo "==> 完成。验证："
"$PKG_BIN" --version
echo
echo "下一步："
echo "  1. zcode login bigmodel-coding-plan   # 浏览器授权（BigModel 编码计划；其他账号用 zcode login）"
echo "  2. zcode                              # 进入 TUI"
echo
echo "注意：若机器上之前用过源码构建的 CLI，其写入的登录凭证可能不被本版本"
echo "（桌面版提取 runtime）识别，表现为 'Provider Registry 中不存在 Model'；"
echo "用上面第 1 步重新登录一次即可。"
