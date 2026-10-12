# ZCode TUI 预编译版（macOS x86_64）

从上游 [zai-org/ZCode](https://github.com/zai-org/ZCode) v3.15.1（commit `aac47556`）源码构建的纯终端 CLI/TUI，不含 Electron 桌面版。

- 平台：macOS Intel（x86_64）
- 源码版本：v3.15.1（commit `aac47556`）
- CLI 版本：0.16.9（`zcode --version`）
- 构建环境：Node.js v24.15.0、pnpm 10.33.2
- 构建命令：`pnpm --filter @zcode/cli... build`（仅构建 CLI，不含桌面版）

## 使用

要求 Node.js >= 24.14.0（`node --version` 确认）。

```bash
./bin/zcode --version   # 验证
./bin/zcode login       # 首次登录（浏览器授权 Z.AI）
./bin/zcode             # 进入全屏 TUI
```

可选：把 `bin/` 加入 PATH，或建软链 `ln -s "$PWD/bin/zcode" ~/.local/bin/zcode`。

同一产物的压缩包（含 SHA-256）见仓库 [Releases](https://github.com/yupoet/zcode-tui/releases) 页面。

## 许可

本产物为上游 Apache-2.0 源码的构建结果，随附上游的 `LICENSE`、`NOTICE.md` 与 `THIRD-PARTY-NOTICES.md`。仓库自身脚本与文档的许可证见仓库根目录 `LICENSE`。
