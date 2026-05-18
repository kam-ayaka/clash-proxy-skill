# Clash Proxy Skill

[简体中文](#简体中文) | [English](#english)

Repository for a Codex skill that detects a usable Clash proxy and runs networked shell commands through it.

## 简体中文

`clash-proxy` 是一个给 Codex 用的 skill。
它解决的是这类环境问题：宿主机明明开了 Clash，但 WSL、VM 或沙箱里的命令行没有自动继承代理，于是 `curl`、`git clone`、`npm install`、`pip install` 一类外网命令经常超时。

### 特性

- 优先复用已经可用的 `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY`
- 自动探测 `127.0.0.1` 和默认网关上的常见 Clash 端口
- 同时探测 HTTP 代理和 SOCKS5 代理
- 提供一个包装脚本，把单条命令放到代理环境里执行
- 探测失败时打印已尝试的端点，方便排查

### 仓库结构

- `clash-proxy/SKILL.md`：skill 入口说明
- `clash-proxy/scripts/detect_proxy.sh`：探测可用代理
- `clash-proxy/scripts/with_proxy.sh`：通过代理执行命令
- `clash-proxy/references/commands.md`：常用命令示例
- `install.sh`：把这个 skill 安装到本机 Codex skills 目录

### 快速安装

```bash
git clone https://github.com/kam-ayaka/clash-proxy-skill.git
cd clash-proxy-skill
bash install.sh
```

默认会安装到 `~/.codex/skills/clash-proxy`。

如果你要覆盖已有版本：

```bash
bash install.sh --force
```

如果你要安装到别的位置：

```bash
bash install.sh --target /path/to/skills
```

### 手动安装

```bash
cp -R clash-proxy ~/.codex/skills/
```

### 使用示例

```bash
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" curl -I https://api.github.com
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" git clone https://github.com/openai/skills.git
```

### 检测逻辑

- 先检查现有代理环境变量是否已经可用
- 如果没有，就依次探测 `127.0.0.1` 和默认网关
- 端口优先级是：`CLASH_PROXY_PORT`、`7890`、`7897`、`9090`
- 如果 HTTP 和 SOCKS 都可用，优先选 HTTP

## English

`clash-proxy` is a Codex skill for environments where Clash is running on the host, but shell commands inside WSL, a VM, or a sandbox do not automatically inherit proxy settings.

### Features

- Reuses working `HTTP_PROXY`, `HTTPS_PROXY`, and `ALL_PROXY` values first
- Probes `127.0.0.1` and the default gateway for common Clash ports
- Tests both HTTP proxy and SOCKS5 proxy modes
- Wraps a single command with the detected proxy environment
- Prints all attempted endpoints when detection fails

### Repository layout

- `clash-proxy/SKILL.md`: skill entry point
- `clash-proxy/scripts/detect_proxy.sh`: proxy detection
- `clash-proxy/scripts/with_proxy.sh`: command wrapper
- `clash-proxy/references/commands.md`: common command patterns
- `install.sh`: installs the skill into a local Codex skills directory

### Quick install

```bash
git clone https://github.com/kam-ayaka/clash-proxy-skill.git
cd clash-proxy-skill
bash install.sh
```

By default this installs to `~/.codex/skills/clash-proxy`.

To replace an existing copy:

```bash
bash install.sh --force
```

To install into a custom skills directory:

```bash
bash install.sh --target /path/to/skills
```

### Example usage

```bash
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" curl -I https://api.github.com
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" git clone https://github.com/openai/skills.git
```

### Requirements

- `bash`
- `curl`
- `ip`

## License

MIT
