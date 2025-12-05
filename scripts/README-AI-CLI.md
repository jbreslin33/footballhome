# AI CLI for Football Home

A command-line interface powered by **GitHub Copilot** - uses your existing Copilot subscription, no additional API keys needed!

## Quick Start

### 1. Install GitHub Copilot CLI

```bash
./scripts/ai-cli.sh install
```

This will:
- Install GitHub CLI (if needed)
- Authenticate with GitHub (if needed)
- Install the GitHub Copilot extension

### 2. Start Chatting

```bash
./scripts/ai-cli.sh chat
```

That's it! No API keys, no additional subscriptions needed.

## Usage Examples

### Interactive Chat Mode

```bash
./scripts/ai-cli.sh chat
```

In chat mode:
- Type your questions naturally
- Type `exit`, `quit`, or `q` to exit
- Prefix with `suggest` for command suggestions
- Prefix with `explain` for explanations

### Single Query

```bash
./scripts/ai-cli.sh query "How do I schedule a practice?"
./scripts/ai-cli.sh query "explain docker compose logs"
```

### Get Help

```bash
./scripts/ai-cli.sh help
```

## Features

- **No API Keys Required**: Uses your GitHub Copilot subscription
- **Command Suggestions**: Get shell commands for tasks
- **Code Explanations**: Understand what commands do
- **Context Aware**: Understands Football Home features
- **Color-coded Output**: Easy to read terminal interface

## Example Chat Session

```
$ ./scripts/ai-cli.sh chat
✓ Ask me anything about your Football Home app!
ℹ Commands: 'exit', 'suggest', 'explain'

You: How do I restart the backend container?
AI:
  Suggestion: docker compose restart backend
  
You: suggest create a database backup
AI:
  $ docker exec footballhome_db pg_dump -U footballhome_user footballhome > backup.sql

You: exit
✓ Goodbye!
```

## Requirements

- **GitHub CLI** (`gh`) - installed automatically by the script
- **GitHub account** with Copilot access (which you already have!)
- **Internet connection** - to connect to GitHub Copilot

## Troubleshooting

### "GitHub CLI not installed"

The install script should handle this automatically. If it fails:

**Ubuntu/Debian:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

**macOS:**
```bash
brew install gh
```

### "GitHub Copilot extension not installed"

Run:
```bash
gh extension install github/gh-copilot
```

### "Not authenticated"

Run:
```bash
gh auth login
```

## What Can You Ask?

### Football Home Specific
- "How do I create a new practice?"
- "What's the database schema for teams?"
- "How do I add a player to a roster?"
- "Explain the RSVP workflow"

### Docker & DevOps
- "How do I restart all containers?"
- "Show me the database logs"
- "How do I backup the database?"

### Git & Development
- "How do I create a new branch?"
- "What files have I changed?"
- "How do I undo my last commit?"

### General Commands
- "suggest find all JavaScript files"
- "explain grep -r 'pattern' ."
- "How do I check disk space?"

## Advanced Usage

### Direct GitHub Copilot Commands

You can also use the GitHub Copilot CLI directly:

```bash
# Get command suggestions
gh copilot suggest "restart nginx"

# Get explanations
gh copilot explain "docker compose up -d --build"

# Shell integration (add to ~/.bashrc)
eval "$(gh copilot alias -- bash)"
# Then use: ?? for suggest, ?! for explain
```

### Aliases

Add to your `~/.bashrc`:

```bash
alias ai='./scripts/ai-cli.sh chat'
alias ask='./scripts/ai-cli.sh query'
```

Then simply use:
```bash
ai                              # Start chat
ask "How do I build the backend?"
```

## Cost & Privacy

- ✅ **Free** - Uses your existing GitHub Copilot subscription
- ✅ **No additional charges** - Already included with Copilot Pro
- ✅ **Secure** - Authenticated through GitHub
- ⚠️ **Cloud-based** - Queries are sent to GitHub (same as VS Code Copilot)

## Comparison with Other Options

| Feature | GitHub Copilot CLI | OpenAI API | Local (Ollama) |
|---------|-------------------|------------|----------------|
| Cost | Included with Copilot | Pay-per-use | Free |
| Setup | `./scripts/ai-cli.sh install` | Need API key | Need to download models |
| Quality | Excellent | Excellent | Good |
| Speed | Fast | Fast | Slower |
| Privacy | Cloud | Cloud | Local |
| API Key | No | Yes | No |
