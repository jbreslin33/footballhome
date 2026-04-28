# Shared helpers for scripts/setup/*.sh
# Sourced from each setup script. Keeps colors + logging consistent.

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status()  { echo -e "${BLUE}→${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1" >&2; }

OS_TYPE="$(uname -s)"

# Locate repo root from any setup script location
setup_repo_root() {
  local d="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
  while [ ! -f "$d/Makefile" ]; do
    d="$(dirname "$d")"
    if [ "$d" = "/" ]; then
      print_error "Could not find repo root"
      exit 1
    fi
  done
  echo "$d"
}
