#!/usr/bin/env bash
# ZCode TUI 一键安装脚本 —— macOS Intel (x86_64) 已验证
# 从官方仓库 zai-org/ZCode 源码构建 CLI/TUI，安装为 ~/.local/bin/zcode
set -euo pipefail

# ---- 可配置项 ----
ZCODE_REF="${ZCODE_REF:-aac4755666d09fdcd70272fcf063c077a639015f}"  # v3.15.1
ZCODE_DIR="${ZCODE_DIR:-$HOME/ZCode}"
PNPM_VERSION="${PNPM_VERSION:-10.33.2}"   # 仓库 packageManager 锁定
NODE_BIN="${NODE_BIN:-$HOME/.nvm/versions/node/v24.15.0/bin/node}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
MIRRORS=(
  "https://ghproxy.net/https://github.com"
  "https://gh-proxy.com/https://github.com"
)

# 绕过失效的本地代理（proxy 软件未开时 npm/git 会 ECONNREFUSED）
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY || true

echo "==> 目标版本: $ZCODE_REF"
echo "==> 安装目录: $ZCODE_DIR"

# ---- 1. 检查 Node ----
if [ ! -x "$NODE_BIN" ]; then
  echo "ERROR: 未找到 Node: $NODE_BIN" >&2
  echo "请先安装 Node.js >= 24.14.0，或用 NODE_BIN=/path/to/node 指定。" >&2
  exit 1
fi
echo "==> Node: $($NODE_BIN --version)"

# ---- 2. 下载源码 tarball（clone 易中断且不能续传，tarball 可整包重试）----
TARBALL=/tmp/zcode-src.tar.gz
rm -f "$TARBALL"
ok=0
for base in "${MIRRORS[@]}"; do
  echo "==> 尝试镜像: $base"
  if curl -fL --http1.1 --retry 3 --retry-all-errors --retry-delay 3 -sS \
      -o "$TARBALL" "$base/zai-org/ZCode/archive/$ZCODE_REF.tar.gz"; then
    ok=1; break
  fi
done
[ "$ok" -eq 1 ] || { echo "ERROR: 所有镜像均下载失败" >&2; exit 1; }
tar -tzf "$TARBALL" > /dev/null 2>&1 || { echo "ERROR: tarball 损坏" >&2; exit 1; }

# ---- 3. 解压 ----
mkdir -p "$ZCODE_DIR"
tar -xzf "$TARBALL" -C "$ZCODE_DIR" --strip-components 1
echo "==> 源码已解压到 $ZCODE_DIR"

# ---- 4. pnpm ----
if [ "$(pnpm --version 2>/dev/null || true)" != "$PNPM_VERSION" ]; then
  echo "==> 安装 pnpm@$PNPM_VERSION"
  npm install -g "pnpm@$PNPM_VERSION"
fi

# ---- 5. 安装依赖（含 ssh2 / node-pty 原生编译，约 6 分钟）----
cd "$ZCODE_DIR"
COREPACK_ENABLE_PROJECT_SPEC=0 \
ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/" \
  pnpm install

# ---- 6. 只构建 CLI 及其依赖（跳过 Electron 桌面版）----
COREPACK_ENABLE_PROJECT_SPEC=0 pnpm --filter @zcode/cli... build

DIST="$ZCODE_DIR/apps/zcode-cli/packages/cli/dist/zcode.cjs"
[ -f "$DIST" ] || { echo "ERROR: 构建产物缺失: $DIST" >&2; exit 1; }

# ---- 7. 安装入口 wrapper ----
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/zcode" <<EOF
#!/usr/bin/env bash
# ZCode CLI (built from source at $ZCODE_DIR, ref $ZCODE_REF)
exec "$NODE_BIN" "$DIST" "\$@"
EOF
chmod +x "$BIN_DIR/zcode"

echo
echo "==> 完成。验证："
"$BIN_DIR/zcode" --version
echo
echo "下一步："
echo "  1. 确认 $BIN_DIR 在 PATH 中（且优先于 nvm bin，which -a zcode 检查）"
echo "  2. zcode login   # 浏览器授权 Z.AI 账号"
echo "  3. zcode         # 进入 TUI"
