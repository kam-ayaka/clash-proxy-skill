# Clash Proxy Commands

Assume:

```bash
export CLASH_SKILL="$HOME/.codex/skills/clash-proxy"
```

## Print detected proxy env

```bash
"$CLASH_SKILL/scripts/with_proxy.sh" --print-env
```

## curl and wget

```bash
"$CLASH_SKILL/scripts/with_proxy.sh" curl -I https://api.github.com
"$CLASH_SKILL/scripts/with_proxy.sh" wget -O- https://raw.githubusercontent.com
```

## GitHub and git

```bash
"$CLASH_SKILL/scripts/with_proxy.sh" gh repo view openai/skills
"$CLASH_SKILL/scripts/with_proxy.sh" git clone https://github.com/openai/skills.git
```

## Python and package managers

```bash
"$CLASH_SKILL/scripts/with_proxy.sh" pip install requests
"$CLASH_SKILL/scripts/with_proxy.sh" uv pip install requests
"$CLASH_SKILL/scripts/with_proxy.sh" npm install @playwright/cli
```

## Codex skill downloads

```bash
"$CLASH_SKILL/scripts/with_proxy.sh" \
  python3 "$HOME/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --repo openai/skills \
  --path skills/.curated/screenshot \
  --method download
```

## One-off shell block

```bash
"$CLASH_SKILL/scripts/with_proxy.sh" bash -lc '
  curl -I https://api.github.com
  curl -I https://raw.githubusercontent.com
'
```
