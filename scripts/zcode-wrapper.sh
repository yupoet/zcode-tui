#!/usr/bin/env bash
# ZCode CLI (built from source at ~/ZCode)
# 将此文件放到 ~/.local/bin/zcode 并 chmod +x。
# NODE_BIN 按你的 Node 24 安装路径调整（仓库 mise.toml 要求 >= 24.14.0）。
NODE_BIN="${NODE_BIN:-$HOME/.nvm/versions/node/v24.15.0/bin/node}"
exec "$NODE_BIN" "$HOME/ZCode/apps/zcode-cli/packages/cli/dist/zcode.cjs" "$@"
