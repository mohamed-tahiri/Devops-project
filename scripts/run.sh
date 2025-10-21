#!/bin/bash
set -e

case "$1" in
    backup) bash backup.sh ;;
    monitor) python3 monitor.py --loop ;;
    orchestrator) bash orchestrator.sh status ;;
    pipeline) bash pipeline.sh ;;
    verify) bash verify.sh ;;
    *) echo "Usage: $0 {backup|monitor|orchestrator|pipeline|verify}" ;;
esac
