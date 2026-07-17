# AI client — ollama + aider bridge

**You are on your laptop. This is NOT the server.** These scripts install
`ollama` on *this* machine so that when you SSH into fishtown, `aider`
(installed there by `scripts/setup/setup-aider.sh`) can borrow this
machine's CPU/GPU for LLM inference via an SSH reverse tunnel.

## Topology

```
[your Mac / Linux laptop wherever you are]   [fishtown]
  ollama serving on 127.0.0.1:11434          aider CLI in /srv/footballhome
           ↑                                          ↓
           └──────── SSH reverse tunnel ──────────────┘
                 ssh -R 11434:localhost:11434
```

## One-time install (on this client)

```bash
# macOS
./install-mac.sh

# Linux
./install-linux.sh
```

Both scripts are idempotent — safe to re-run to upgrade ollama or pull a
different model. Override the default model with `--model=...`:

```bash
./install-mac.sh --model qwen2.5-coder:14b
```

## Persistent SSH tunnel (recommended)

Add this to `~/.ssh/config` on this machine (edit `HostName`/`User`):

```
Host fishtown
    HostName fishtown.example.com
    User jbreslin
    RemoteForward 11434 127.0.0.1:11434
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Now every `ssh fishtown` auto-forwards 11434 back to this machine. No
flags to remember.

## Daily use

```bash
# On this client:
ssh fishtown              # tunnel opens automatically

# Now on fishtown:
cd /srv/footballhome
aider                     # reads .aider.conf.yml, talks to your ollama
```

## Troubleshooting

**"Connection refused" from aider on fishtown**
```bash
# On fishtown, verify tunnel is alive:
curl -s http://127.0.0.1:11434/api/tags
```
- Empty models list → tunnel is up, no model pulled. `ollama pull ...` on client.
- Connection refused → tunnel not established. On client: `brew services restart ollama` (Mac) or `sudo systemctl restart ollama` (Linux), then re-SSH.

**Model too slow**
- Lower parameter count: `qwen2.5-coder:7b` → `qwen2.5-coder:3b`
- Or on the client, `htop` — is ollama swapping? Then the model is too big for the machine.

**Switch models without rerunning setup**
```bash
# On client:
ollama pull deepseek-coder-v2:16b

# On fishtown:
aider --model ollama_chat/deepseek-coder-v2:16b
# (or edit .aider.conf.yml to make it the new default)
```
