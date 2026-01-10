# AI Development Tools

Football Home provides multiple AI coding assistants for different use cases. Choose based on your needs:

## 🤖 Available AI Tools

| Tool | Type | Cost | Internet | Best For |
|------|------|------|----------|----------|
| **Claude CLI** | Cloud API | ~$3-15 per million tokens | Required | Quick questions, code generation |
| **Aider** | Cloud API | ~$3-15 per million tokens | Required | File editing, refactoring, multi-file changes |
| **Ollama (ai-cli)** | Local | Free | After initial download | Offline development, privacy-sensitive code |

---

## 1️⃣ Claude CLI - Quick Q&A

**Best for:** Fast code generation, quick questions, documentation lookup

### Setup
```bash
./scripts/setup/setup-claude.sh
```

### Usage
```bash
# Quick single query
./claude query "How do I use std::mutex in C++?"

# Interactive chat mode
./claude chat
```

### Examples
```bash
# Generate code
./claude query "Write a C++ function to validate email addresses"

# Debug help
./claude query "Why am I getting a segmentation fault with this pointer?"

# SQL assistance
./claude query "Optimize this PostgreSQL query: SELECT * FROM..."

# Explain code
./claude query "Explain what this JavaScript async function does"
```

**Pros:**
- ⚡ Fastest for quick questions
- 📝 Great for code snippets
- 💰 Pay per use (only costs when you use it)

**Cons:**
- ❌ Doesn't edit files directly
- ❌ Requires internet + API key

---

## 2️⃣ Aider - Full Agent Mode

**Best for:** File editing, refactoring, multi-file changes, architecture work

### Setup
```bash
./scripts/setup/setup-aider.sh
```

### Usage
```bash
# Start interactive session (scans entire codebase)
./aider

# Start with specific files
./aider backend/src/main.cpp backend/src/Router.cpp

# One-shot edit
./aider --message "Add error handling to AuthController.cpp"
```

### Examples
```bash
# Inside Aider session:
You: Add input validation to all login endpoints
Aider: [shows proposed changes]
You: y  # Accept changes

You: Refactor the database connection code to use connection pooling
Aider: [edits multiple files, shows diffs]
You: y  # Apply changes

You: /help  # See all commands
You: /exit  # Quit
```

**Pros:**
- ✅ Edits files directly (with your approval)
- ✅ Understands entire codebase context
- ✅ Multi-file refactoring
- ✅ Git integration (auto-commits)

**Cons:**
- 💰 Higher token usage (scans whole codebase)
- ⏱️ Slower initial startup (repo scan)

---

## 3️⃣ Ollama (ai-cli) - Local AI

**Best for:** Offline development, privacy-sensitive code, no API costs

### Setup
```bash
./scripts/ai-cli.sh install
```

### Usage
```bash
# Interactive chat
./scripts/ai-cli.sh chat

# Quick query
./scripts/ai-cli.sh query "How do I use C++ templates?"

# Code generation
./scripts/ai-cli.sh code "Write a function to parse JSON in C++"
```

### Examples
```bash
# In chat mode:
You: Write a C++ class for HTTP request handling
AI: [generates code locally]

You: How do I optimize this SQL query?
AI: [provides suggestions]

# One-shot queries:
./scripts/ai-cli.sh query "Explain PostgreSQL indexes"
./scripts/ai-cli.sh code "Create a JavaScript promise wrapper"
```

**Pros:**
- 💰 Completely free
- 🔒 100% private (runs locally)
- 🌐 Works offline
- ⚡ Fast after initial model download

**Cons:**
- 📦 Requires ~4GB download (first time only)
- 🧠 Less capable than Claude (smaller model)
- 💻 Uses local compute resources

---

## 📊 Comparison Matrix

### When to use each tool:

**Use Claude CLI (`./claude`) when:**
- ✅ You need a quick answer or code snippet
- ✅ You want the most capable AI (GPT-4 level)
- ✅ You don't need to edit files
- ✅ Cost isn't a concern (~$0.01 per query)

**Use Aider (`./aider`) when:**
- ✅ You need to edit actual project files
- ✅ You're refactoring or making architectural changes
- ✅ You want AI to understand full codebase context
- ✅ You want changes committed to git automatically

**Use Ollama (`./scripts/ai-cli.sh`) when:**
- ✅ You're offline or have poor internet
- ✅ You're working with sensitive/proprietary code
- ✅ You want zero API costs
- ✅ Quick code generation is sufficient

---

## 💰 Cost Estimation

### Claude (claude + aider)
- **Input**: ~$3 per million tokens
- **Output**: ~$15 per million tokens
- **Typical query**: $0.01 - $0.05
- **Typical aider session**: $0.10 - $1.00
- **Monthly (active use)**: $10 - $50

### Ollama (ai-cli)
- **Cost**: $0 (completely free)
- **One-time download**: ~4GB
- **Hardware**: Uses local CPU/GPU

---

## 🚀 Quick Start Guide

### First time setup:
```bash
# One-time setup (choose what you want)
./scripts/setup/setup-claude.sh   # Cloud AI (requires API key)
./scripts/ai-cli.sh install        # Local AI (free)
```

### Daily workflow:

```bash
# Quick questions while coding:
./claude query "how to use async/await in JavaScript?"

# Edit files with AI assistance:
./aider backend/src/Router.cpp
> Add error handling to all routes

# Offline code generation:
./scripts/ai-cli.sh code "write a function to parse CSV"
```

---

## 🔧 Configuration

### Claude/Aider Settings
Located in `.aider.conf.yml`:
```yaml
model: claude-sonnet-4-20250514
auto-commits: false  # Manual approval required
read:
  - README.md
  - .github/copilot-instructions.md
```

### Ollama Settings
Edit `scripts/ai-cli.sh`:
```bash
OLLAMA_MODEL="deepseek-coder:6.7b"  # Default model
```

---

## 🆘 Troubleshooting

### Claude/Aider not working?
```bash
# Check API key is set:
echo $ANTHROPIC_API_KEY

# If empty, run setup again:
./scripts/setup/setup-claude.sh
```

### Ollama not working?
```bash
# Check if service is running:
pgrep ollama

# Restart service:
./scripts/ai-cli.sh install
```

---

## 📚 More Resources

- **Claude API Docs**: https://docs.anthropic.com/
- **Aider Docs**: https://aider.chat/docs/
- **Ollama Models**: https://ollama.com/library

---

## 🎯 Best Practices

1. **Use the right tool for the job** - Don't use Aider for simple questions
2. **Review AI changes carefully** - Always check diffs before accepting
3. **Keep context focused** - Add only relevant files to Aider
4. **Start small** - Test AI tools on non-critical code first
5. **Commit often** - AI tools work best with clean git state

---

## ⚙️ Advanced Usage

### Custom Aider workflows:
```bash
# Architecture mode (chat only, no edits)
./aider --architect

# Specific files with custom prompt:
./aider src/*.cpp --message "Add const correctness"

# Different model:
./aider --model gpt-4-turbo
```

### Ollama model switching:
```bash
# Install different model:
ollama pull codellama:13b

# Use in ai-cli (edit OLLAMA_MODEL in script)
```

---

## 🔐 Security Notes

- **API Keys**: Never commit `.env` or share API keys
- **Private Code**: Use Ollama for sensitive/proprietary code
- **Code Review**: Always review AI-generated code for security issues
- **Data Privacy**: Claude/Aider send code to Anthropic APIs

---

**For general VS Code development, you're already using GitHub Copilot Chat (the best integrated option)!**
