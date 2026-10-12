# zcode-tui

<p align="center">
  <strong>从源码构建并安装 ZCode（智谱 Z.AI Coding Agent）的终端 CLI/TUI —— 无需 Electron</strong>
</p>

<p align="center">
  <a href="https://github.com/zai-org/ZCode/tree/v3.15.1"><img src="https://img.shields.io/badge/upstream-zai--org%2FZCode%20v3.15.1-3178c6?logo=github" alt="upstream zai-org/ZCode v3.15.1"></a>
  <a href="https://github.com/yupoet/zcode-tui/releases"><img src="https://img.shields.io/badge/CLI-0.16.9-339933" alt="CLI 0.16.9"></a>
  <a href="https://nodejs.org/"><img src="https://img.shields.io/badge/node-%E2%89%A5%2024.14-43853d?logo=nodedotjs" alt="Node >= 24.14"></a>
  <a href="#平台支持状态"><img src="https://img.shields.io/badge/platform-macOS%20%7C%20Ubuntu%20(x86__64)-8b8b8b" alt="platform macOS | Ubuntu (x86_64)"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-0078b4" alt="License Apache-2.0"></a>
</p>

<p align="center">
  简体中文 | <a href="README.en.md">English</a>
</p>

---

## 背景

- ZCode **没有官方独立 npm CLI 包**（`@zhipu/zcode` 在 npm 上不存在，404）。官方分发渠道是 [zcode-ai.com](https://zcode-ai.com) 的桌面客户端（Electron GUI）。
- npm 上的 [`zcode-app-cli`](https://github.com/kingsword09/zcode-cli) 是社区非官方封装：它直接从官方桌面版发布物（.deb 等）提取**官方 runtime**、套上自研的 pi-tui 终端界面，npm 包内置 runtime，**不需要本机安装桌面版**。其界面与版本号（如 `3.14.5-34`）与桌面客户端一致，支持 Linux/macOS/Windows，Node.js >= 22.19 即可，是 Ubuntu 上最省事的方案。
- 官方仓库 [zai-org/ZCode](https://github.com/zai-org/ZCode) 是开源的，包含桌面应用、Web、后端以及 Agent CLI/TUI 源码（`apps/zcode-cli/`），可以自己构建出纯终端入口，无需 Electron。源码构建出的是官方 OpenTUI 版 CLI（版本号 `0.16.9`），界面与桌面客户端不同。

本仓库记录各平台从源码构建 ZCode TUI 的完整过程，提供可重复执行的脚本，并收录已验证的预编译产物。

## 快速开始（预编译产物）

不想从源码构建的，可以直接用仓库内 [`release/`](release/) 目录中的预编译文件（含 `bin/zcode.cjs` 与入口脚本 `bin/zcode`），或下载 [Releases](https://github.com/yupoet/zcode-tui/releases) 页面中的压缩包（附 SHA-256，解压后均带顶层目录）：

| 产物 | 平台 | 源码版本 | CLI 版本 |
| --- | --- | --- | --- |
| [`release/macos-x86_64/`](release/macos-x86_64/) | macOS Intel（x86_64） | v3.15.1（`aac47556`） | 0.16.9 |
| [`release/ubuntu-x86_64/`](release/ubuntu-x86_64/) | Ubuntu（x86_64） | v3.15.1（`aac47556`） | 0.16.9 |
| `zcode-tui-v3.15.1-macos-x86_64.tar.gz`（Release 资产） | macOS Intel（x86_64） | v3.15.1（`aac47556`） | 0.16.9 |
| `zcode-tui-v3.15.1-ubuntu-x86_64.tar.gz`（Release 资产） | Ubuntu（x86_64） | v3.15.1（`aac47556`） | 0.16.9 |

```bash
git clone https://github.com/yupoet/zcode-tui.git
cd zcode-tui/release/macos-x86_64   # Ubuntu 用 release/ubuntu-x86_64
./bin/zcode --version               # 需 Node.js >= 24.14.0
./bin/zcode login                   # 首次登录
./bin/zcode                         # 进入 TUI
```

## 平台支持状态

| 平台 | 状态 | 方案 |
| --- | --- | --- |
| macOS Intel（x86_64） | ✅ 已验证 | 源码构建官方 OpenTUI CLI（见下文） |
| Ubuntu（x86_64） | ✅ 已验证 | npm 安装 `zcode-app-cli`（推荐）或源码构建（见下文） |

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

## Ubuntu（x86_64）

已在以下环境验证：

- 系统：Ubuntu（`uname -m` → `x86_64`）
- Node.js：v22.23.2（满足 zcode-app-cli 要求的 `>= 22.19.0`；注意源码构建官方 CLI 才需要 Node >= 24，npm 包不需要）
- 包：`zcode-app-cli@3.14.5-34`（2026-10-11 发布；`zcode --version` 显示 `zcode-app-cli 3.14.5-34` + `zcode-runtime 0.16.9`）
- 运行时来源：官方桌面版 `ZCode-3.14.5-linux-x64.deb` 提取（见包内 `vendor/extraction.json`）

Ubuntu 上有两条路：**(A) npm 安装 zcode-app-cli（推荐）**——界面/版本号与桌面客户端一致；**(B) 官方 OpenTUI CLI**——直接用 [`release/ubuntu-x86_64/`](release/ubuntu-x86_64/) 的预编译产物（需 Node >= 24.14），或照 macOS 章节从源码构建。

### A. npm 安装 zcode-app-cli（推荐）

```bash
# 0. 绕过失效代理（如需要）
alias noproxy='env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY'

# 1. 全局安装（npm registry 可直连；解压后约 88MB，含内置 runtime）
noproxy npm install -g zcode-app-cli@latest

# 2. 确认 PATH 命中的是 npm 版（npm 全局 bin，如 ~/.npm-global/bin）
which -a zcode        # 第一个应是 <npm prefix>/bin/zcode
zcode --version       # zcode-app-cli 3.14.5-34

# 3. 登录并进入 TUI
zcode login bigmodel-coding-plan   # BigModel 编码计划；Z.AI 账号用 zcode login
zcode
```

也可以直接运行本仓库的一键脚本：

```bash
bash scripts/install-ubuntu.sh
```

### B. 官方 OpenTUI CLI（预编译或源码构建）

```bash
# 预编译产物（需 Node >= 24.14.0）
git clone https://github.com/yupoet/zcode-tui.git
cd zcode-tui/release/ubuntu-x86_64
./bin/zcode --version
./bin/zcode login
```

源码构建步骤与 macOS 章节完全相同（tarball 解压 → `pnpm install` → `pnpm --filter @zcode/cli... build` → wrapper），在本机 Ubuntu 上已验证通过。

### Ubuntu 已知事项

- **凭证不通用**：源码构建的官方 CLI 写入的登录凭证（`~/.zcode/v2/credentials.json`）可能不被 zcode-app-cli 的桌面版提取 runtime 识别，表现为 `Model creation failed` 或 `Provider Registry 中不存在 Model: account:bigmodel-individual-coding-plan/GLM-5.3`。用 `zcode login bigmodel-coding-plan` 重新授权一次即可（Linux 上走服务端回调轮询，浏览器打开授权页确认即可）。反向亦然；两个客户端换着用时建议先备份该文件。
- **PATH 遮蔽**：如果之前按源码构建方案装过 `~/.local/bin/zcode` wrapper，它会优先于 npm 全局 bin 命中（`~/.local/bin` 通常排在 PATH 前面）。一键脚本会自动把它改名为 `~/.local/bin/zcode-oss` 保留备用。
- **配置共享**：provider 配置与桌面版共用 `~/.zcode/v2/provider_config.json`（默认模型选择等）；CLI 自身设置在 `~/.zcode/cli/setting.json`。
- **升级**：`npm install -g zcode-app-cli@latest`。`@latest` 始终指向最新验证过的「桌面版+构建号」组合（版本号形如 `3.14.5-34`，带 prerelease 段）。
- 想用官方 OpenTUI 界面而非桌面版界面的，仍可按 macOS 章节的源码构建方案在 Ubuntu 上构建（步骤相同，`~/ZCode` + wrapper），入口建议命名为 `zcode-oss` 避免冲突。

---

## 仓库结构

```
scripts/
  install-macos-intel.sh   # macOS Intel 一键安装脚本（源码构建官方 CLI）
  install-ubuntu.sh        # Ubuntu 一键安装脚本（npm 安装 zcode-app-cli）
  zcode-wrapper.sh         # ~/.local/bin/zcode 入口模板
release/
  macos-x86_64/            # 预编译产物（macOS Intel）
  ubuntu-x86_64/           # 预编译产物（Ubuntu x86_64）
                           # 均为 bin/zcode.cjs + bin/zcode + README.md
                           # + 上游 LICENSE / NOTICE.md / THIRD-PARTY-NOTICES.md
vendor/
  README.md                # 快照来源、版本、许可证与使用说明
  ZCode/                   # 上游 zai-org/ZCode 源码快照（v3.15.1, aac47556, Apache-2.0）
                           # 已剔除 node_modules/dist 等构建产物，可直接 pnpm install 构建
```

**Release 命名规则**（目录、tag、资产、标题四者对齐）：

| 项 | 规则 | 示例 |
| --- | --- | --- |
| 目录 | `release/<os>-x86_64/` | `release/macos-x86_64/` |
| tag | `v<上游版本>-<os>-x86_64` | `v3.15.1-macos-x86_64` |
| 资产 | `zcode-tui-v<上游版本>-<os>-x86_64.tar.gz` | `zcode-tui-v3.15.1-macos-x86_64.tar.gz` |
| 标题 | `ZCode TUI 预编译版 v<上游版本> (<OS> x86_64)` | `ZCode TUI 预编译版 v3.15.1 (macOS x86_64)` |

## 许可证

- 本仓库自身的脚本与文档以 [Apache-2.0](LICENSE) 发布。
- `vendor/ZCode/` 是上游 [zai-org/ZCode](https://github.com/zai-org/ZCode) 的源码快照（Apache-2.0，版权 Z.AI Co., Ltd），保留其自带的 `LICENSE`、`NOTICE.md`、`THIRD-PARTY-NOTICES.md`。
- `release/` 中的预编译产物是上游源码的构建结果，各平台目录随附上游的三份许可/声明文件。

## 参考

- 官方仓库：https://github.com/zai-org/ZCode
- 官网（桌面版下载 / GLM Coding Plan）：https://zcode-ai.com
- 社区非官方 npm 封装：https://github.com/kingsword09/zcode-cli
