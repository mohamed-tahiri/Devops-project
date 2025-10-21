#!/bin/bash
set -e

BASE_DIR=$(dirname "$0")/..
PIDS_DIR="${BASE_DIR}/pids"
SERVICES_DIR="${BASE_DIR}/tools/services"
LOGS_DIR="${BASE_DIR}/logs"

start_service() {
    local service_name=$1
    echo "[INFO] Starting $service_name..."
    mkdir -p "$LOGS_DIR" "$PIDS_DIR"
    nohup "${SERVICES_DIR}/${service_name}.sh" > "${LOGS_DIR}/${service_name}.log" 2>&1 &
    echo $! > "${PIDS_DIR}/${service_name}.pid"
}

stop_service() {
    local service_name=$1
    local pid_file="${PIDS_DIR}/${service_name}.pid"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        echo "[INFO] Stopping ${service_name} (PID: ${pid})..."
        kill "$pid" 2>/dev/null || true
        rm -f "$pid_file"
    fi
}

start() {
    start_service "database"
    sleep 2
    start_service "api"
    sleep 2
    start_service "web"
}

stop() {
    stop_service "web"
    stop_service "api"
    stop_service "database"
}

status() {
    for service in database api web; do
        local pid_file="${PIDS_DIR}/${service}.pid"
        if [ -f "$pid_file" ] && kill -0 $(cat "$pid_file") >/dev/null 2>&1; then
            echo -e "[\033[32m$service\033[0m] RUNNING"
        else
            echo -e "[\033[31m$service\033[0m] STOPPED"
        fi
    done
}

case "$1" in
    start) start ;;
    stop) stop ;;
    status) status ;;
    restart) stop; start ;;
    *) echo "Usage: $0 {start|stop|status|restart}"; exit 1 ;;
esac
