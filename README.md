# baota-mirror

定时镜像原安装脚本从 `io.bt.sb` 获取的两个文件：

- `public.sh`
- `panel6_latest.zip`

GitHub Actions 每天 03:23 UTC 自动拉取、检查 Shell 语法、验证 ZIP 完整性并计算 SHA-256。只有文件发生变化时，才会更新固定的 `mirror-latest` Release。

`io.bt.sy/install/userInfo.json` 已从安装脚本中移除，不会下载或使用；`tj.bt.sb` 统计请求也已关闭。操作系统依赖和其他宝塔文件仍从 Linux 发行版仓库或 `download.bt.cn` 获取。

## 使用

```bash
curl -fsSL https://raw.githubusercontent.com/liuli9914-bitch/baota-mirror/main/install.sh -o install.sh && bash install.sh
```

安装脚本会从以下 Release 地址读取镜像文件：

```text
https://github.com/liuli9914-bitch/baota-mirror/releases/download/mirror-latest/
```

也可以临时覆盖镜像地址：

```bash
BAOTA_MIRROR_URL=https://example.com/path bash install.sh
```

覆盖地址下需要直接提供 `public.sh` 和 `panel6_latest.zip`。

## 手动同步

在仓库的 Actions 页面运行 `Sync io.bt.sb assets`，或在 Linux 上执行：

```bash
bash scripts/sync-assets.sh dist
```

## 安全提示

`io.bt.sb` 不是宝塔官方域名。本仓库只负责镜像、基本格式校验和哈希记录，不代表这些文件经过宝塔官方验证。使用前请自行审查文件内容并承担相应风险。
