# ZCode TUI 预编译版 (Ubuntu x86_64)

- 上游：https://github.com/zai-org/ZCode v3.15.1 (commit aac47556, Apache-2.0)
- CLI 版本：0.16.9（`zcode --version`）
- 构建环境：Ubuntu x86_64, Node.js v24.14.0, pnpm 10.33.2
- 构建命令：`pnpm --filter @zcode/cli... build`（仅 CLI，不含 Electron 桌面版）

## 使用

要求 Node.js >= 24.14.0（`node --version` 确认）。

```bash
./bin/zcode --version   # 验证
./bin/zcode login       # 首次登录（浏览器授权 Z.AI / BigModel）
./bin/zcode             # 进入全屏 TUI
```

可选：把 `bin/` 加入 PATH，或建软链 `ln -s "$PWD/bin/zcode" ~/.local/bin/zcode`。

注意：这是官方 OpenTUI 界面的 CLI（源码构建）。如果想要与桌面客户端一致的界面和版本号（如 v3.14.5-34），用 npm 装 `zcode-app-cli` 更省事，见仓库根 README 的 Ubuntu 章节。两者登录凭证不通用，共存时建议把本入口命名为 `zcode-oss`。

同一产物的压缩包（含 SHA-256）见仓库 [Releases](https://github.com/yupoet/zcode-tui/releases) 页面。
