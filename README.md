# Clash Proxy Skill

这是一个给 Codex 使用的 skill，用来自动检测可用的 Clash 代理，并把需要外网的 shell 命令包到代理环境里执行。

## 内容

- `clash-proxy/SKILL.md`：skill 入口
- `clash-proxy/scripts/detect_proxy.sh`：探测可用代理
- `clash-proxy/scripts/with_proxy.sh`：通过代理执行命令
- `clash-proxy/references/commands.md`：常用命令示例

## 安装到 Codex

把 `clash-proxy/` 目录复制到你的 Codex skills 目录即可：

```bash
cp -R clash-proxy ~/.codex/skills/
```

安装后，Codex 就可以直接识别 `clash-proxy` 这个 skill。

## 用法

```bash
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" curl -I https://api.github.com
```

## 设计目标

- 不捆绑 Clash 本体，只负责检测和应用代理环境变量
- 优先复用已有 `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY`
- 如果没有现成代理，就按本机常见端点探测
- 检测失败时输出尝试过的地址，方便排查

## 许可

MIT
