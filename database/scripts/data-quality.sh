#!/bin/bash

# Data Quality Tools - Wrapper Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    echo "Football Home - Data Quality Tools"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  check              Run data quality checks"
    echo "  assign             Auto-assign teams to clubs (dry-run mode)"
    echo "  assign --execute   Auto-assign teams to clubs (execute mode - makes changes!)"
    echo ""
    echo "Examples:"
    echo "  $0 check                    # Check data quality"
    echo "  $0 assign                   # Preview team-to-club assignments"
    echo "  $0 assign --execute         # Execute team-to-club assignments"
    echo ""
}

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1
shift

case "$COMMAND" in
    check)
        echo "Running data quality checks..."
        node "$SCRIPT_DIR/data-quality-check.js"
        ;;
    assign)
        if [ "$1" = "--execute" ]; then
            echo "⚠️  WARNING: This will modify the database!"
            echo "Press Ctrl+C to cancel, or Enter to continue..."
            read
            node "$SCRIPT_DIR/assign-teams-to-clubs.js" --execute
        else
            node "$SCRIPT_DIR/assign-teams-to-clubs.js" --dry-run
        fi
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo ""
        show_help
        exit 1
        ;;
esac
