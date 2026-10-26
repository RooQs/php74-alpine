# php74-alpine

基于官方 PHP 7.4 Alpine 镜像，应用 PHP2Shell 官方最小缓解补丁并重新编译 PHP 的修复镜像。

## 基础信息

- 基础镜像：`php:7.4.33-fpm-alpine3.16`
- 固定 digest：`sha256:0aeb129a60daff2874c5c70fcd9d88cdf3015b4fb4cc7c3f1a32a21e84631036`
- 补丁：PHP2Shell 官方最小缓解补丁 `712e60f9`
- 补丁文件：`patches/7.4-CVE-2026-109618-109619.patch`
- 补丁 SHA-256：`5fe57ca6ee96d59b36c6e0ca842843c50884f177bef1e85234cf669b577f5e48`
- 修复的 CVE：CVE-2026-109618、CVE-2026-109619
- 镜像标签：`7.4.33-fpm-alpine3.16-cve2026-109618`
- 支持架构：`linux/amd64`、`linux/arm64`

## 验证

修复版会新增 `max_multipart_body_parts` 配置项。工作流会校验：

- `php -r 'echo ini_get("max_multipart_body_parts");'` 输出 `-1`
- `php-fpm -t` 配置有效
- 核心扩展（mysqli、pdo_mysql、mbstring、curl、openssl、zlib、sqlite、sodium）存在

`php -v` 仍显示 7.4.33，不能用版本号判断是否已修复，应以 `max_multipart_body_parts` 为准。

## 已知限制

- 这是 PHP 7.4（已 EOL）的最小缓解，不是完整升级，其他已知漏洞仍然存在。
- 镜像只包含 PHP 核心和 FPM，mcrypt、imap、pdo_pgsql 等扩展不在本镜像中。
- Alpine 3.16 已停止维护，需要关注 `apk` 安全更新。
- 长期方案仍是升级到 PHP 8.2 以上。

## 构建

推送到 `main` 分支或手动运行 `build-and-push` 工作流即可。需要在仓库 Secrets 中配置：

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

Trivy 扫描结果以报告形式输出在 Actions 日志中，不阻止推送。
