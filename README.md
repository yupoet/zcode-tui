# zcode-tui

从源码构建并安装 [ZCode](https://github.com/zai-org/ZCode)（智谱 Z.AI）终端 TUI / CLI 的实践方案与脚本。

## 背景

- ZCode **没有官方独立 npm CLI 包**（`@zhipu/zcode` 在 npm 上不存在，404）。官方分发渠道是 [zcode-ai.com](https://zcode-ai.com) 的桌面客户端（Electron GUI）。
- npm 上的 `zcode-app-cli` 是社区非官方封装，且依赖从本地桌面版提取运行时。
- 官方仓库 [zai-org/ZCode](https://github.com/zai-org/ZCode) 是开源的，包含桌面应用、Web、后端以及 Agent CLI/TUI 源码（`apps/zcode-cli/`），可以自己构建出纯终端入口，无需 Electron。

本仓库记录各平台从源码构建 ZCode TUI 的完整过程，并提供可重复执行的脚本。

## 平台支持状态

| 平台 | 状态 | 文档 |
| --- | --- | --- |
| macOS Intel (x86_64) | ✅ 已验证 | 见下文 |
| Ubuntu | 🚧 待补充 | — |

---

## macOS（Intel, x86_64）

已在以下环境验证：

- 机型：MacBook Pro Intel（`uname -m` → `x86_64`）
- Node.js：v24.15.0（nvm 管理，满足仓库 `mise.toml` 要求的 `>= 24.14.0`）
- pnpm：10.33.2（仓库 `packageManager` 字段锁定版本）
- 源码版本：v3.15.1，提交 `aac4755666d09fdcd70272fcf063c077a639015f`
- 构建产物：`~/ZCode/apps/zcode-cli/packages/cli/dist/zcode.cjs`（约 28.5MB）

### 网络说明（国内环境）

- GitHub 直连不稳定（HTTP2 framing / 超时），git clone 大仓库容易 `early EOF` 中断。
- 解决方案：通过镜像站下载**源码 tarball** 而非 clone（clone 在中断后无法续传，tarball 可以重试）：
  - `https://ghproxy.net/https://github.com/...`（已验证可用）
  - `https://gh-proxy.com/https://github.com/...`（备用）
  - 注意：镜像不支持 HTTP Range 断点续传，中断了就整包重下（约 85MB）。
- npm registry（registry.npmjs.org）可直连。如果 shell 里配置了失效的本地代理（如 `127.0.0.1:7890` 但代理软件没开），npm/git 会报 `ECONNREFUSED`，需用 `env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY` 绕过。

### 手动安装步骤

```bash
# 0. 绕过失效代理（如需要）
alias noproxy='env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY'

# 1. 下载源码 tarball（v3.15.1, commit aac47556）
noproxy curl -fL --http1.1 --retry 3 --retry-all-errors --retry-delay 3 \
  -o /tmp/zcode-main.tar.gz \
  "https://ghproxy.net/https://github.com/zai-org/ZCode/archive/aac4755666d09fdcd70272fcf063c077a639015f.tar.gz"

# 2. 解压到 ~/ZCode
mkdir -p ~/ZCode
tar -xzf /tmp/zcode-main.tar.gz -C ~/ZCode --strip-components 1

# 3. 安装仓库锁定的 pnpm 版本
noproxy npm install -g pnpm@10.33.2

# 4. 安装 workspace 依赖（约 6 分钟，含 ssh2 / node-pty 原生编译）
cd ~/ZCode
noproxy COREPACK_ENABLE_PROJECT_SPEC=0 \
  ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/" \
  pnpm install

# 5. 只构建 CLI 及其 workspace 依赖（不编 Electron 桌面版）
noproxy COREPACK_ENABLE_PROJECT_SPEC=0 pnpm --filter @zcode/cli... build

# 6. 创建终端入口 wrapper（~/.local/bin 需在 PATH 中）
cat > ~/.local/bin/zcode <<'EOF'
#!/usr/bin/env bash
# ZCode CLI (built from source at ~/ZCode)
exec "$HOME/.nvm/versions/node/v24.15.0/bin/node" \
  "$HOME/ZCode/apps/zcode-cli/packages/cli/dist/zcode.cjs" "$@"
EOF
chmod +x ~/.local/bin/zcode

# 7. 验证
zcode --version
zcode doctor
```

也可以直接运行本仓库的一键脚本：

```bash
bash scripts/install-macos-intel.sh
```

### 使用

```bash
zcode login     # 首次使用：浏览器打开 Z.AI 授权页登录（CLI 与桌面版登录态不共享，需单独授权一次）
zcode           # 进入全屏 TUI
zcode tui       # 同上，显式子命令
zcode -p "任务" --json   # 单次无头执行
zcode -c        # 继续当前目录上一次会话
zcode doctor    # 排查运行时 / 配置问题
```

### 升级

```bash
cd ~/ZCode
git pull        # 前提是源码以 git 仓库形式存在（见下方说明）
pnpm install
pnpm --filter @zcode/cli... build
```

注意：

- 按上述 tarball 方式安装的 `~/ZCode` **没有 `.git`**，无法直接 `git pull`。如需升级能力，重新用 `git clone`（镜像地址同样可用于 clone，但大仓库易中断，建议浅克隆 `--depth 1`）或对现有目录 `git init && git remote add origin ... && git fetch && git reset`。
- 升级只影响新开的会话，正在运行的 TUI 需重启。
- 全量构建（`pnpm -r build`）会连 Electron 桌面版一起编译，Intel Mac 上耗时很长；只要 CLI/TUI 用 `--filter @zcode/cli...` 即可。

### 已知事项

- **版本号显示**：`zcode --version` 显示 `0.16.9`，与仓库版本（v3.15.1）不一致是正常的——CLI 版本号在 `apps/zcode-cli/package.json` 中独立维护，v3.15.1 的更新（UI 插件、desktop、远程工作区等）未 bump CLI 版本。
- **PATH 优先级**：确保 `~/.local/bin` 在 nvm 的 bin 目录之前（`which -a zcode` 第一个应是 `~/.local/bin/zcode`），否则可能命中 npm 全局装的社区版 `zcode-app-cli`。
- **数据目录**：CLI 与桌面版共用 `~/.zcode/`（v2 运行时、配置），但登录凭证需各自授权。
- `pnpm install` 时的 husky 警告 `.git can't be found`（tarball 无 git 元数据）无害，可忽略。

---

## Ubuntu

🚧 待补充（计划记录基于 Ubuntu 的构建方案）。

---

## 仓库结构

```
scripts/
  install-macos-intel.sh   # macOS Intel 一键安装脚本
  zcode-wrapper.sh         # ~/.local/bin/zcode 入口模板
vendor/
  README.md                # 快照来源、版本、许可证与使用说明
  ZCode/                   # 上游 zai-org/ZCode 源码快照（v3.15.1, aac47556, Apache-2.0）
                           # 已剔除 node_modules/dist 等构建产物，可直接 pnpm install 构建
```

## 参考

- 官方仓库：https://github.com/zai-org/ZCode
- 官网（桌面版下载 / GLM Coding Plan）：https://zcode-ai.com
- 社区非官方 npm 封装：https://github.com/kingsword09/zcode-cli
