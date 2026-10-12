# vendor/ZCode

本目录是上游开源项目 [zai-org/ZCode](https://github.com/zai-org/ZCode) 的**源码快照**（第三方 vendored copy），仅用于离线查阅与可复现构建。

- 上游版本：v3.15.1
- 上游提交：`aac4755666d09fdcd70272fcf063c077a639015f`
- 获取方式：GitHub 镜像 tarball 解压（`archive/<commit>.tar.gz`），**不含 `.git` 元数据**
- 许可证：Apache License 2.0（见本目录 `LICENSE`，版权声明见 `NOTICE.md` / `THIRD-PARTY-NOTICES.md`）
- 已排除内容：`node_modules/`、`dist/`、`.turbo/` 等构建产物与依赖目录（原始快照约 220MB / 1.7 万文件）

## 直接使用本快照构建（无需再访问 GitHub）

```bash
cd vendor/ZCode
npm install -g pnpm@10.33.2        # 仓库 packageManager 锁定版本
COREPACK_ENABLE_PROJECT_SPEC=0 \
ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/" \
  pnpm install                     # 仍需访问 npm registry
COREPACK_ENABLE_PROJECT_SPEC=0 pnpm --filter @zcode/cli... build
node apps/zcode-cli/packages/cli/dist/zcode.cjs --version
```

注意：`pnpm install` 仍需访问 npm registry 下载依赖；本快照只解决 GitHub 源码获取问题。

## 更新快照

```bash
# 在上游 clone 或新 tarball 解压的目录中执行，再同步进来：
rsync -a --delete \
  --exclude 'node_modules' --exclude 'dist' --exclude '.git' \
  --exclude '.turbo' --exclude '*.tsbuildinfo' \
  /path/to/new-ZCode/ vendor/ZCode/
# 并更新本文件的版本号与提交哈希
```
