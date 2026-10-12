# zcode-tui

<p align="center">
  <strong>Build &amp; install the ZCode terminal / command-line CLI &amp; TUI — no Electron desktop app needed</strong>
</p>

<p align="center">
  <a href="https://github.com/zai-org/ZCode/tree/v3.15.1"><img src="https://img.shields.io/badge/upstream-zai--org%2FZCode%20v3.15.1-3178c6?logo=github" alt="upstream zai-org/ZCode v3.15.1"></a>
  <a href="https://github.com/yupoet/zcode-tui/releases"><img src="https://img.shields.io/badge/CLI-0.16.9-339933" alt="CLI 0.16.9"></a>
  <a href="https://nodejs.org/"><img src="https://img.shields.io/badge/node-%E2%89%A5%2024.14-43853d?logo=nodedotjs" alt="Node >= 24.14"></a>
  <a href="#platform-support"><img src="https://img.shields.io/badge/platform-macOS%20%7C%20Ubuntu%20(x86__64)-8b8b8b" alt="platform macOS | Ubuntu (x86_64)"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-0078b4" alt="License Apache-2.0"></a>
</p>

<p align="center">
  <a href="README.md">简体中文</a> | English
</p>

---

## FAQ

### Does ZCode have a CLI or terminal version?

Yes. ZCode is open source, and the official repo [zai-org/ZCode](https://github.com/zai-org/ZCode) contains the Agent CLI/TUI source (`apps/zcode-cli/`), from which you can build a pure terminal entry point. There is also a community npm wrapper, `zcode-app-cli`.

However, the official channels ([website](https://zcode-ai.com), GitHub Releases) **only ship desktop installers**, and the build instructions in the upstream README are written for developers — there is no user-facing "install the CLI" path. That is the gap this repository fills: it turns the official source-build steps into an end-to-end user guide, with one-shot scripts and verified prebuilt artifacts.

### How do the three ways of using ZCode compare?

| | Desktop client (official) | Source-built CLI (this repo) | `zcode-app-cli` (community) |
| --- | --- | --- | --- |
| How to get | Installer from the [website](https://zcode-ai.com) | This repo's scripts / [prebuilt artifacts](release/) | `npm install -g zcode-app-cli` |
| UI | Electron desktop GUI | Official OpenTUI terminal UI | Desktop UI (official runtime + pi-tui wrapper) |
| Version | v3.x (desktop) | `0.16.9` (maintained separately) | Desktop version (e.g. `3.14.5-34`) |
| Node.js requirement | None (runtime bundled) | >= 24.14 | >= 22.19 |
| Desktop app needed? | Is the app itself | No | No (runtime bundled) |
| `--web` browser mode | The app is a GUI | Not included (see [notes below](#relationship-with-the-upstream-official-docs)) | — |
| Login credentials | Log in inside the GUI | `zcode login`; not shared with desktop/community versions | `zcode login`; not shared with the source-built CLI |

### Why is there no official ZCode CLI package on npm?

ZCode has **no official standalone npm CLI package** (`@zhipu/zcode` does not exist on npm). The [`zcode-app-cli`](https://github.com/kingsword09/zcode-cli) on npm is a community-made unofficial wrapper: it extracts the official runtime from the desktop release artifacts (e.g. the `.deb`) and adds a self-made pi-tui terminal front-end — convenient, but not official.

### Do I need to install the desktop app first?

No. Building from source (or using this repo's prebuilt artifacts) does not depend on the desktop app, and `zcode-app-cli` bundles its own runtime. The `~/.zcode/` data directory (config, etc.) is shared with the desktop app, but login credentials must be authorized separately.

## Background

- The official distribution channel of ZCode is the desktop client (Electron GUI) from [zcode-ai.com](https://zcode-ai.com); both the website and GitHub Releases only provide desktop installers.
- [`zcode-app-cli`](https://github.com/kingsword09/zcode-cli) on npm is a community-made unofficial wrapper: it extracts the **official runtime** from the desktop release artifacts (e.g. the `.deb`), adds a self-made pi-tui terminal front-end, and bundles the runtime inside the npm package, so **no local desktop install is needed**. Its UI and version (e.g. `3.14.5-34`) match the desktop client; it works on Linux/macOS/Windows with Node.js >= 22.19, and is the easiest option on Ubuntu.
- The official repo [zai-org/ZCode](https://github.com/zai-org/ZCode) is open source and contains the desktop app, web, backend, and the Agent CLI/TUI source (`apps/zcode-cli/`), so you can build a pure terminal entry point yourself. The source build produces the official OpenTUI CLI (version `0.16.9`), whose UI differs from the desktop client.

This repo documents the full process of building the ZCode TUI from source on each platform, ships repeatable scripts, and publishes verified prebuilt artifacts.

## Relationship with the upstream official docs

The build method in this repo **is the official command from the upstream README**, not an invented process:

- The core build command `pnpm --filter @zcode/cli... build` comes from the upstream README's "Development → CLI source development" section;
- The version requirements for Node.js (24.14.0 pinned by `mise.toml`) and pnpm (10.33.2 pinned by `packageManager`) likewise come from the upstream repo.

What this repo adds: re-arranging the steps for end users rather than developers (mirror-accelerated source download, entry wrapper, login and PATH troubleshooting, a verified two-platform matrix) plus prebuilt artifacts. Two transparent deviations from the upstream docs:

1. **Dependency init uses `pnpm install` instead of `pnpm bootstrap`**: `bootstrap` additionally prepares desktop runtime resources and runs `build:bootstrap`, which a CLI-only build does not need; this has been verified on macOS Intel and Ubuntu.
2. **The artifact is the single-file entry `apps/zcode-cli/packages/cli/dist/zcode.cjs`** (the same entry used by the upstream CLI development section), not the full "command-line distribution package" assembled by `pnpm build:zcode`. The latter also bundles web/backend, TUI native libraries and workers, supports the `zcode --web` browser mode, and requires a self-hosted `ZCODE_DIST_BASE_URL` — therefore **the CLI built by this repo does not include `--web` mode**. For that capability, see the upstream README's "ZCode command-line edition" packaging section.

## Quick Start (Prebuilt Artifacts)

If you don't want to build from source, use the prebuilt files under [`release/`](release/) (contains `bin/zcode.cjs` plus the `bin/zcode` entry script), or download the tarballs from the [Releases](https://github.com/yupoet/zcode-tui/releases) page (SHA-256 provided; both extract into a top-level directory):

| Artifact | Platform | Source version | CLI version |
| --- | --- | --- | --- |
| [`release/macos-x86_64/`](release/macos-x86_64/) | macOS Intel (x86_64) | v3.15.1 (`aac47556`) | 0.16.9 |
| [`release/ubuntu-x86_64/`](release/ubuntu-x86_64/) | Ubuntu (x86_64) | v3.15.1 (`aac47556`) | 0.16.9 |
| `zcode-tui-v3.15.1-macos-x86_64.tar.gz` (Release asset) | macOS Intel (x86_64) | v3.15.1 (`aac47556`) | 0.16.9 |
| `zcode-tui-v3.15.1-ubuntu-x86_64.tar.gz` (Release asset) | Ubuntu (x86_64) | v3.15.1 (`aac47556`) | 0.16.9 |

```bash
git clone https://github.com/yupoet/zcode-tui.git
cd zcode-tui/release/macos-x86_64   # on Ubuntu use release/ubuntu-x86_64
./bin/zcode --version               # requires Node.js >= 24.14.0
./bin/zcode login                   # first-time login
./bin/zcode                         # enter the TUI
```

## Platform Support

| Platform | Status | Approach |
| --- | --- | --- |
| macOS Intel (x86_64) | ✅ Verified | Build the official OpenTUI CLI from source (see below) |
| Ubuntu (x86_64) | ✅ Verified | npm install `zcode-app-cli` (recommended) or build from source (see below) |

---

## macOS (Intel, x86_64)

Verified on the following environment:

- Machine: MacBook Pro Intel (`uname -m` → `x86_64`)
- Node.js: v24.15.0 (managed by nvm; satisfies the repo's `mise.toml` requirement of `>= 24.14.0`)
- pnpm: 10.33.2 (pinned by the repo's `packageManager` field)
- Source version: v3.15.1, commit `aac4755666d09fdcd70272fcf063c077a639015f`
- Build output: `~/ZCode/apps/zcode-cli/packages/cli/dist/zcode.cjs` (~28.5 MB)

### Network Notes (for users in mainland China)

- Direct GitHub access is unstable (HTTP/2 framing errors / timeouts); cloning a large repo often fails with `early EOF`.
- Workaround: download the **source tarball** through a mirror site instead of cloning (a broken clone cannot resume, while a tarball download can simply be retried):
  - `https://ghproxy.net/https://github.com/...` (verified working)
  - `https://gh-proxy.com/https://github.com/...` (fallback)
  - Note: the mirrors don't support HTTP Range resume; if interrupted, re-download the whole file (~85 MB).
- The npm registry (registry.npmjs.org) is directly reachable. If your shell has a stale local proxy configured (e.g. `127.0.0.1:7890` while the proxy app is off), npm/git will fail with `ECONNREFUSED`; bypass with `env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY`.

### Manual Install Steps

```bash
# 0. Bypass a stale proxy (if needed)
alias noproxy='env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY'

# 1. Download the source tarball (v3.15.1, commit aac47556)
noproxy curl -fL --http1.1 --retry 3 --retry-all-errors --retry-delay 3 \
  -o /tmp/zcode-main.tar.gz \
  "https://ghproxy.net/https://github.com/zai-org/ZCode/archive/aac4755666d09fdcd70272fcf063c077a639015f.tar.gz"

# 2. Extract into ~/ZCode
mkdir -p ~/ZCode
tar -xzf /tmp/zcode-main.tar.gz -C ~/ZCode --strip-components 1

# 3. Install the pnpm version pinned by the repo
noproxy npm install -g pnpm@10.33.2

# 4. Install workspace dependencies (~6 min, includes native builds of ssh2 / node-pty)
cd ~/ZCode
noproxy COREPACK_ENABLE_PROJECT_SPEC=0 \
  ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/" \
  pnpm install

# 5. Build only the CLI and its workspace deps (skips the Electron desktop app)
noproxy COREPACK_ENABLE_PROJECT_SPEC=0 pnpm --filter @zcode/cli... build

# 6. Create the terminal entry wrapper (~/.local/bin must be in PATH)
cat > ~/.local/bin/zcode <<'EOF'
#!/usr/bin/env bash
# ZCode CLI (built from source at ~/ZCode)
exec "$HOME/.nvm/versions/node/v24.15.0/bin/node" \
  "$HOME/ZCode/apps/zcode-cli/packages/cli/dist/zcode.cjs" "$@"
EOF
chmod +x ~/.local/bin/zcode

# 7. Verify
zcode --version
zcode doctor
```

Or just run the one-shot script from this repo:

```bash
bash scripts/install-macos-intel.sh
```

### Usage

```bash
zcode login     # First use: opens the Z.AI auth page in a browser
                # (CLI and desktop share no login state; authorize once for the CLI)
zcode           # Enter the full-screen TUI
zcode tui       # Same, explicit subcommand
zcode -p "task" --json   # Single headless run
zcode -c        # Continue the previous session in the current directory
zcode doctor    # Diagnose runtime / config issues
```

### Upgrading

```bash
cd ~/ZCode
git pull        # Requires the source tree to be a git clone (see note below)
pnpm install
pnpm --filter @zcode/cli... build
```

Notes:

- A `~/ZCode` installed via the tarball steps above has **no `.git`**, so `git pull` won't work. To gain upgradeability, re-clone with git (mirror URLs also work for cloning, though large clones break easily — prefer `--depth 1`), or run `git init && git remote add origin ... && git fetch && git reset` in the existing directory.
- Upgrades only affect newly started sessions; a running TUI must be restarted.
- A full build (`pnpm -r build`) also compiles the Electron desktop app and is very slow on Intel Macs; `--filter @zcode/cli...` is all you need for the CLI/TUI.

### Known Issues

- **Version number**: `zcode --version` reports `0.16.9`, which differs from the repo version (v3.15.1). This is expected — the CLI version is maintained independently in `apps/zcode-cli/package.json`, and v3.15.1's changes (UI plugins, desktop, remote workspaces, etc.) did not bump it.
- **PATH precedence**: make sure `~/.local/bin` comes before the nvm bin dir (`which -a zcode` should list `~/.local/bin/zcode` first), otherwise you may hit the community `zcode-app-cli` installed via npm global.
- **Data directory**: the CLI shares `~/.zcode/` (v2 runtime, config) with the desktop app, but login credentials must be authorized separately.
- The husky warning `.git can't be found` during `pnpm install` (tarball has no git metadata) is harmless.

---

## Ubuntu (x86_64)

Verified on the following environment:

- OS: Ubuntu (`uname -m` → `x86_64`)
- Node.js: v22.23.2 (satisfies zcode-app-cli's `>= 22.19.0`; note that only building the official CLI from source needs Node >= 24, the npm package does not)
- Package: `zcode-app-cli@3.14.5-34` (published 2026-10-11; `zcode --version` reports `zcode-app-cli 3.14.5-34` + `zcode-runtime 0.16.9`)
- Runtime source: extracted from the official desktop `ZCode-3.14.5-linux-x64.deb` (see `vendor/extraction.json` inside the package)

There are two paths on Ubuntu: **(A) npm install zcode-app-cli (recommended)** — UI and version match the desktop client; **(B) the official OpenTUI CLI** — use the prebuilt artifacts in [`release/ubuntu-x86_64/`](release/ubuntu-x86_64/) (needs Node >= 24.14) or build from source following the macOS section.

### A. npm install zcode-app-cli (recommended)

```bash
# 0. Bypass a stale proxy (if needed)
alias noproxy='env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY'

# 1. Install globally (npm registry is directly reachable; ~88 MB unpacked, runtime bundled)
noproxy npm install -g zcode-app-cli@latest

# 2. Confirm PATH resolves to the npm version (npm global bin, e.g. ~/.npm-global/bin)
which -a zcode        # first hit should be <npm prefix>/bin/zcode
zcode --version       # zcode-app-cli 3.14.5-34

# 3. Log in and enter the TUI
zcode login bigmodel-coding-plan   # BigModel Coding Plan; for a Z.AI account use zcode login
zcode
```

Or just run the one-shot script from this repo:

```bash
bash scripts/install-ubuntu.sh
```

### B. Official OpenTUI CLI (prebuilt or from source)

```bash
# Prebuilt artifacts (requires Node >= 24.14.0)
git clone https://github.com/yupoet/zcode-tui.git
cd zcode-tui/release/ubuntu-x86_64
./bin/zcode --version
./bin/zcode login
```

Building from source is identical to the macOS section (extract tarball → `pnpm install` → `pnpm --filter @zcode/cli... build` → wrapper); verified on a local Ubuntu machine.

### Ubuntu Known Issues

- **Credentials are not interchangeable**: login credentials written by the source-built official CLI (`~/.zcode/v2/credentials.json`) may not be recognized by zcode-app-cli's desktop-extracted runtime, showing up as `Model creation failed` or `Provider Registry 中不存在 Model: account:bigmodel-individual-coding-plan/GLM-5.3`. Simply re-authorize with `zcode login bigmodel-coding-plan` (on Linux this uses a server-side callback poll; confirm in the opened auth page). The same applies in reverse; back up that file when switching between the two clients.
- **PATH shadowing**: if you previously installed the `~/.local/bin/zcode` wrapper from the source-build path, it takes precedence over the npm global bin (`~/.local/bin` usually comes first in PATH). The one-shot script automatically renames it to `~/.local/bin/zcode-oss` as a backup.
- **Shared config**: provider config is shared with the desktop app via `~/.zcode/v2/provider_config.json` (default model selection, etc.); the CLI's own settings live in `~/.zcode/cli/setting.json`.
- **Upgrading**: `npm install -g zcode-app-cli@latest`. `@latest` always points to the latest verified "desktop + build number" combination (versions like `3.14.5-34`, with a prerelease segment).
- If you prefer the official OpenTUI UI over the desktop UI, you can still build from source on Ubuntu following the macOS section (same steps, `~/ZCode` + wrapper); name the entry `zcode-oss` to avoid conflicts.

---

## Repository Layout

```
scripts/
  install-macos-intel.sh   # macOS Intel one-shot installer (builds the official CLI from source)
  install-ubuntu.sh        # Ubuntu one-shot installer (npm install zcode-app-cli)
  zcode-wrapper.sh         # Template for the ~/.local/bin/zcode entry
release/
  macos-x86_64/            # Prebuilt artifacts (macOS Intel)
  ubuntu-x86_64/           # Prebuilt artifacts (Ubuntu x86_64)
                           # Each contains bin/zcode.cjs + bin/zcode + README.md
                           # + the upstream LICENSE / NOTICE.md / THIRD-PARTY-NOTICES.md
vendor/
  README.md                # Snapshot source, version, license and usage notes
  ZCode/                   # Source snapshot of upstream zai-org/ZCode (v3.15.1, aac47556, Apache-2.0)
                           # node_modules/dist and other build outputs stripped; can pnpm install directly
```

**Release naming rules** (directory, tag, asset and title aligned):

| Item | Rule | Example |
| --- | --- | --- |
| Directory | `release/<os>-x86_64/` | `release/macos-x86_64/` |
| Tag | `v<upstream version>-<os>-x86_64` | `v3.15.1-macos-x86_64` |
| Asset | `zcode-tui-v<upstream version>-<os>-x86_64.tar.gz` | `zcode-tui-v3.15.1-macos-x86_64.tar.gz` |
| Title | `ZCode TUI 预编译版 v<upstream version> (<OS> x86_64)` | `ZCode TUI 预编译版 v3.15.1 (macOS x86_64)` |

## License

- The scripts and docs of this repository are licensed under [Apache-2.0](LICENSE).
- `vendor/ZCode/` is a source snapshot of upstream [zai-org/ZCode](https://github.com/zai-org/ZCode) (Apache-2.0, Copyright Z.AI Co., Ltd) and keeps its own `LICENSE`, `NOTICE.md` and `THIRD-PARTY-NOTICES.md`.
- The prebuilt artifacts under `release/` are build results of the upstream source; each platform directory ships the upstream's three license/notice files.

## References

- Official repository: https://github.com/zai-org/ZCode
- Official site (desktop download / GLM Coding Plan): https://zcode-ai.com
- Community unofficial npm wrapper: https://github.com/kingsword09/zcode-cli

## Search Keywords

<details>
<summary>Click to expand the search phrases this guide covers</summary>

zcode cli, zcode tui, zcode terminal, zcode command line, zcode command-line edition, zcode cli install, zcode cli npm, zcode npm package, @zhipu/zcode, zcode-app-cli, z.ai coding plan cli, glm coding plan terminal, zcode linux, zcode ubuntu, zcode macos intel, zcode headless, zcode --json, zcode without desktop app, zcode no electron, build zcode from source, build zcode cli from source

</details>
