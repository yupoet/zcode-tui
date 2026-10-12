# AGENTS.md

本文件面向 AI 编码代理，描述 `zcode-tui` 仓库的结构、构建方式与约定。阅读者默认对本项目一无所知。

## 项目概览

`zcode-tui` 是一个**构建方案与脚本仓库**，本身不是应用程序。目标是：从开源上游 [zai-org/ZCode](https://github.com/zai-org/ZCode)（智谱 Z.AI 的 Coding Agent，官方分发为 Electron 桌面客户端，没有官方独立 npm CLI 包）的源码构建出纯终端的 CLI/TUI（`zcode` 命令），无需 Electron。

仓库包含三部分：

1. **文档**：`README.md` 记录 macOS Intel（x86_64，源码构建官方 CLI）与 Ubuntu（x86_64，npm 安装 zcode-app-cli）两条已验证路径。
2. **脚本**：`scripts/` 下的一键安装脚本与终端入口 wrapper 模板。
3. **预编译产物**：`release/` 收录已构建好的 `zcode.cjs` 与入口脚本（macOS Intel 与 Ubuntu x86_64 各一份），clone 即可用（Node >= 24.14）。
4. **上游源码快照**：`vendor/ZCode/` 是上游 v3.15.1（提交 `aac4755666d09fdcd70272fcf063c077a639015f`，Apache-2.0）的 vendored copy，用于离线查阅与可复现构建，已剔除 `node_modules/`、`dist/`、`.turbo/` 等构建产物，**不含 `.git` 元数据**。

本仓库自身**没有构建系统**：没有 `package.json`、`pyproject.toml` 等顶层配置文件，不运行测试。所有真正的构建/测试都发生在 `vendor/ZCode/`（上游 monorepo）内部。

## 仓库结构

```
scripts/
  install-macos-intel.sh   # macOS Intel 一键安装：下载 tarball → pnpm install → 构建 CLI → 安装 wrapper
  install-ubuntu.sh        # Ubuntu 一键安装：npm 全局安装 zcode-app-cli（内置官方桌面版提取 runtime）
  zcode-wrapper.sh         # ~/.local/bin/zcode 入口模板（exec node .../dist/zcode.cjs）
release/
  macos-x86_64/            # 预编译产物（macOS Intel）
  ubuntu-x86_64/           # 预编译产物（Ubuntu x86_64）
                           # 每个目录：bin/zcode.cjs + 入口脚本 bin/zcode + README.md
                           #   + 上游 LICENSE / NOTICE.md / THIRD-PARTY-NOTICES.md（Apache-2.0 合规随附）
vendor/
  README.md                # 快照来源、版本、许可证、更新方法
  ZCode/                   # 上游 zai-org/ZCode 源码快照（详见下节）
LICENSE                    # 本仓库自身脚本/文档的许可证（Apache-2.0，归 yupoet）
README.md / README.en.md   # 中/英文 README，顶部互相链接，修改时必须同步两份
.gitignore                 # 仅忽略 node_modules/、dist/、.DS_Store
```

**Release 命名规则**（目录、tag、资产、标题四者对齐，规则详见 README）：目录 `release/<os>-x86_64/`；tag `v<上游版本>-<os>-x86_64`；资产 `zcode-tui-v<上游版本>-<os>-x86_64.tar.gz`（含顶层目录，确定性参数打包）；标题 `ZCode TUI 预编译版 v<上游版本> (<OS> x86_64)`。

## 构建与使用命令

本仓库层面的操作：

```bash
# 一键安装（macOS Intel 已验证；脚本可用环境变量覆盖默认值：
# ZCODE_REF / ZCODE_DIR / PNPM_VERSION / NODE_BIN / BIN_DIR）
bash scripts/install-macos-intel.sh

# 直接用 vendored 快照构建（无需访问 GitHub，但 pnpm install 仍需 npm registry）
cd vendor/ZCode
npm install -g pnpm@10.33.2        # packageManager 锁定的版本
COREPACK_ENABLE_PROJECT_SPEC=0 \
ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/" \
  pnpm install
COREPACK_ENABLE_PROJECT_SPEC=0 pnpm --filter @zcode/cli... build
node apps/zcode-cli/packages/cli/dist/zcode.cjs --version
```

安装后 CLI 的用法：`zcode login`（浏览器授权）→ `zcode`（全屏 TUI）；无头模式 `zcode -p "任务" --json`；排查 `zcode doctor`。

关键事实：

- 工具链要求：Node.js >= 24（`mise.toml` 锁定 24.14.0），pnpm 10.33.2（`packageManager` 字段锁定）。
- 只构建 CLI 用 `--filter @zcode/cli...`；`pnpm -r build` 会连 Electron 桌面版一起编译，Intel Mac 上非常慢。
- 构建产物：`apps/zcode-cli/packages/cli/dist/zcode.cjs`（约 28.5MB）。
- `zcode --version` 显示 `0.16.9`，与仓库版本 v3.15.1 不一致是正常的（CLI 版本号在 `apps/zcode-cli/package.json` 独立维护）。
- CLI 与桌面版共用数据目录 `~/.zcode/`，但登录凭证各自授权。

## 上游快照（vendor/ZCode）技术栈与结构

只有在修改 `vendor/ZCode/` 内的代码时才需要本节。上游是 TypeScript pnpm monorepo（`pnpm-workspace.yaml` + Turbo），Node >= 24，oxlint/oxfmt 做 lint/格式化，vitest 做单元测试，husky + lint-staged 做提交钩子。

主要目录（详见 `vendor/ZCode/AGENTS.md`，改动该目录前必读）：

- `apps/zcode-cli/`：Agent CLI/TUI 及其运行时（本仓库构建的目标）。其下 `packages/` 含 `cli`（入口）、`core`、`tui`、`bootstrap`、`contracts`、`adapters`、`i18n`、`telemetry` 及多个 `*-plugin` 包；构建经 Turbo 编排（`turbo run build`）。改动前必读 `apps/zcode-cli/AGENTS.md`。
- `packages/desktop`：Electron 桌面版（main/host/renderer）。
- `packages/web`、`packages/server`：Web 客户端与服务端。
- `packages/ui`：共享 React 组件、hooks、Zustand store。
- `packages/services`、`packages/rpc`、`packages/shared`、`packages/client`：业务服务、RPC 框架、共享协议/类型、Agent 客户端 SDK。
- `architecture-policy.yaml` + `scripts/architecture/`：架构治理检查；`DESIGN.md`：UI 设计规范；`CONTEXT.md`：插件商店领域词汇。

上游常用命令（在 `vendor/ZCode/` 根执行）：`pnpm typecheck`、`pnpm lint` / `pnpm lint:fix`、`pnpm fmt:check`、`pnpm test`（vitest 单测）、`pnpm verify:pre-push`（lint + 架构检查 + 受影响单测）、`pnpm architecture:check -- --changed`。

## 开发约定

### 本仓库（脚本与文档）

- 文档与注释统一使用**中文**；例外：`README.en.md` 为英文镜像，`README.md`（中文主版本）与 `README.en.md` 必须同步修改。
- shell 脚本使用 bash，开头 `set -euo pipefail`；路径与版本等可变项提取为可用环境变量覆盖的默认值（参考 `install-macos-intel.sh` 的 `ZCODE_REF`/`NODE_BIN` 等模式）。
- 脚本需对网络失败做容错：多镜像重试（ghproxy.net / gh-proxy.com）、`curl --retry`、解压前校验 tarball 完整性；下载前 `unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY` 以绕过失效的本地代理。
- 修改构建步骤或版本后，同步更新 `README.md`、`vendor/README.md`（版本号与提交哈希）和对应脚本，保持三处一致。
- 平台支持状态记录在 `README.md` 的表格中：macOS Intel 与 Ubuntu 均已验证（Ubuntu 走 npm 的 `zcode-app-cli`，开箱即用且界面/版本号与官方桌面客户端一致；源码构建在 Ubuntu 同样可行但非默认推荐）。

### vendor/ZCode 内（上游快照）

- 原则上 vendor 快照**只读**：它是第三方 vendored copy，用于查阅与构建。如需更新快照，按 `vendor/README.md` 中的 rsync 流程整体替换并更新版本信息，不做零散的手工修改。
- 若确实要在其中改代码，必须遵守 `vendor/ZCode/AGENTS.md`（以及 `apps/zcode-cli/AGENTS.md`）的规则：先更新 spec 再实现、改 tool 前读 `docs/design/v2/tool/00-tool-change-chain.md`、单文件不超 400 行、跨平台（Windows/macOS/Linux）兼容、外部 I/O 收敛到 adapter 层、执行 `pnpm typecheck` 和 `pnpm lint` 并如实报告结果等。

## 测试

- 本仓库自身没有测试。验证方式是端到端跑通安装脚本并执行 `zcode --version`、`zcode doctor`。
- 上游快照内：`pnpm test`（vitest 单元测试，排除 desktop E2E）；CLI 侧为 `pnpm --dir apps/zcode-cli test`（Turbo 编排）；桌面 E2E 走 WebdriverIO（`pnpm --filter @zcode/desktop test:e2e`），还有容器化 E2E 脚本。注意 vendor 快照不含 `node_modules`，须先 `pnpm install` 才能运行任何测试。

## 安全与注意事项

- 不在脚本、日志或提交中写入凭据、token、真实用户数据或内部服务地址。`.env.development` / `.env.production` 等上游示例文件属于快照内容，勿在其中填入真实密钥。
- 脚本只执行下载、解压、安装依赖、构建和写入 `~/.local/bin/zcode`；不会触碰系统目录，不需要 sudo。
- 国内网络环境注意：GitHub 直连不稳，下载走镜像 tarball；npm registry 可直连；失效的本地代理会导致 `ECONNREFUSED`，需 `env -u` 系列变量绕过。
- 两套 CLI 共存时注意 PATH：`zcode` 默认应命中 npm 全局 bin 里的 `zcode-app-cli`（与桌面客户端一致）；源码构建的官方 OpenTUI CLI 入口命名为 `zcode-oss`（如 `~/.local/bin/zcode-oss`），用 `which -a zcode` 检查。两者的登录凭证（`~/.zcode/v2/credentials.json`）互不识别，换用需重新登录，切换前备份该文件。
