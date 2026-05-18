---
name: "clash-proxy"
description: "Use when shell commands need external network access from this environment and direct access is flaky or blocked, especially for GitHub, package registries, curl, wget, git clone, npm, pip, uv, cargo, or Codex skill downloads. Detect a Clash proxy exposed from the Windows host or local machine, then run the network command through that proxy."
---

# Clash Proxy

Use this skill whenever terminal-based network access matters and direct egress is unreliable.
This environment may not inherit proxy variables automatically even when Clash is running on the host.
Do not assume `HTTP_PROXY` or `HTTPS_PROXY` are already set.

## When to use

- Downloading from GitHub
- Installing packages with `npm`, `pnpm`, `yarn`, `pip`, `uv`, `cargo`, `go`, or `gem`
- `curl`, `wget`, `git clone`, `gh`, `docker pull`, or similar shell-based network tasks
- Any time a direct request times out but the user says a proxy or Clash is enabled
- WSL or VM environments where the proxy runs on the host instead of inside the guest

## Required workflow

1. Check whether proxy env vars are already set.
2. If not, detect a usable Clash endpoint with `scripts/detect_proxy.sh`.
3. For external commands, prefer `scripts/with_proxy.sh <command...>` instead of setting ad hoc env vars by hand.
4. Verify with a small request before attempting a larger download.
5. If detection fails, surface the exact host and ports tested.

## Detection rules

- First, prefer an already-working `HTTP_PROXY`, `HTTPS_PROXY`, or `ALL_PROXY`.
- Otherwise, probe likely Clash endpoints:
  - `127.0.0.1`
  - the default gateway from `ip route` which is commonly the Windows host in WSL
- Probe common ports in this order:
  - `CLASH_PROXY_PORT` if set
  - `7890`
  - `7897`
  - `9090`
- Prefer HTTP proxy mode if both HTTP and SOCKS work.

## Core commands

Export a proxy for the current shell:

```bash
eval "$("$HOME/.codex/skills/clash-proxy/scripts/detect_proxy.sh")"
```

Run one command through the detected proxy:

```bash
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" curl -I https://raw.githubusercontent.com
```

Use it with GitHub skill downloads:

```bash
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" \
  python3 "$HOME/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --repo openai/skills \
  --path skills/.curated/screenshot \
  --method download
```

## Verification

Use one of these before a large operation:

```bash
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" curl -I https://api.github.com
"$HOME/.codex/skills/clash-proxy/scripts/with_proxy.sh" curl -I https://raw.githubusercontent.com
```

## References

Open only when needed:

- `references/commands.md` for common wrapped command patterns

## Guardrails

- Do not assume the proxy port is `7890`; detect it.
- Do not hardcode the current gateway IP; detect it from routing.
- Prefer the wrapper script over manually repeating proxy env vars.
- If the command is fully local, do not route it through the proxy.
- If a tool ignores env proxy vars, report that explicitly instead of assuming the proxy worked.
