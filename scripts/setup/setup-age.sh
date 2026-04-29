#!/bin/bash
# scripts/setup/setup-age.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# age decryption — turns committed encrypted secrets into usable plaintext.
#
# Currently decrypts:
#   scrape-vpn.conf.age  →  scrape-vpn.conf   (gitignored, chmod 600)
#   env.age              →  env               (gitignored, chmod 600)
#
# Reproducing on a new server:
#   1. Clone the repo (the .age file is already in it).
#   2. Run ./setup.sh   — this step installs `age` and prompts for the
#      passphrase you used to encrypt the file.
#
# Unattended runs:
#   AGE_PASSPHRASE='...' ./setup.sh
#
# Re-encrypting after editing the plaintext:
#   age -p -o scrape-vpn.conf.age scrape-vpn.conf
#   git add scrape-vpn.conf.age && git commit -m "rotate vpn key"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
source "$(dirname "$0")/_lib.sh"
REPO_ROOT="$(setup_repo_root)"

# ── 1. Install age ────────────────────────────────────────────────────
if ! command -v age &> /dev/null; then
  print_status "Installing age..."
  case "$OS_TYPE" in
    Linux)
      if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y age
      elif command -v dnf &> /dev/null; then
        sudo dnf install -y age
      elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm age
      else
        print_error "Unsupported Linux distro — install age manually: https://age-encryption.org"
        exit 1
      fi
      ;;
    Darwin)
      if ! command -v brew &> /dev/null; then
        print_error "Homebrew required: https://brew.sh"
        exit 1
      fi
      brew install age
      ;;
    *)
      print_error "Unsupported OS: $OS_TYPE"
      exit 1
      ;;
  esac
fi
print_success "age $(age --version 2>&1 | head -1) ready"

# ── 2. Decrypt each *.age file in the repo root ───────────────────────
shopt -s nullglob
ENCRYPTED=( "$REPO_ROOT"/*.age )
shopt -u nullglob

if [ ${#ENCRYPTED[@]} -eq 0 ]; then
  print_warning "No .age files to decrypt"
  exit 0
fi

NEEDS_DECRYPT=()
for enc in "${ENCRYPTED[@]}"; do
  plain="${enc%.age}"
  if [ -f "$plain" ] && [ "$plain" -nt "$enc" ]; then
    print_success "$(basename "$plain") is up to date"
  else
    NEEDS_DECRYPT+=("$enc")
  fi
done

if [ ${#NEEDS_DECRYPT[@]} -eq 0 ]; then
  exit 0
fi

# ── 3. Get passphrase (env var or prompt once) ────────────────────────
if [ -z "${AGE_PASSPHRASE:-}" ]; then
  echo ""
  echo "Encrypted secrets need to be unlocked:"
  for enc in "${NEEDS_DECRYPT[@]}"; do
    echo "   $(basename "$enc")  →  $(basename "${enc%.age}")"
  done
  echo ""
  read -r -s -p "age passphrase: " AGE_PASSPHRASE
  echo ""
  if [ -z "$AGE_PASSPHRASE" ]; then
    print_error "No passphrase provided."
    exit 1
  fi
fi

# ── 4. Decrypt each file using `expect` to drive age's tty prompt ─────
if ! command -v expect &> /dev/null; then
  print_status "Installing expect (needed to feed passphrase to age)..."
  if command -v apt-get &> /dev/null; then
    sudo apt-get install -y expect
  elif command -v brew &> /dev/null; then
    brew install expect
  else
    print_error "Install 'expect' manually."
    exit 1
  fi
fi

for enc in "${NEEDS_DECRYPT[@]}"; do
  plain="${enc%.age}"
  print_status "Decrypting $(basename "$enc")..."
  AGE_PASSPHRASE="$AGE_PASSPHRASE" expect -c "
    log_user 0
    spawn age -d -o {$plain} {$enc}
    expect {
      \"passphrase*\" { send \"\$env(AGE_PASSPHRASE)\r\"; exp_continue }
      eof
    }
    catch wait result
    exit [lindex \$result 3]
  " > /dev/null
  if [ ! -s "$plain" ]; then
    print_error "Decryption failed (wrong passphrase?). Removing empty $plain."
    rm -f "$plain"
    exit 1
  fi
  chmod 600 "$plain"
  print_success "$(basename "$plain") decrypted"
done
