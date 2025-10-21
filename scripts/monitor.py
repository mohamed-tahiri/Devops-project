#!/usr/bin/env python3
import shutil
import psutil
import logging
import time
import argparse
from pathlib import Path

# Project base dir
BASE_DIR = Path(__file__).resolve().parent.parent  # remonte à la racine du projet
LOGS_DIR = BASE_DIR / "logs"
LOGS_DIR.mkdir(parents=True, exist_ok=True)  # crée le dossier s'il n'existe pas

# Thresholds
CPU_THRESHOLD = 80.0
MEM_THRESHOLD = 85.0
DISK_THRESHOLD = 90.0

# Setup logging
logging.basicConfig(
    filename=str(LOGS_DIR / "monitor.log"),
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)

def check_disk_usage(path="/"):
    total, used, free = shutil.disk_usage(path)
    return (used / total) * 100

def check_cpu_usage():
    return psutil.cpu_percent(interval=1)

def check_memory_usage():
    return psutil.virtual_memory().percent

def main(loop=False, interval=60):
    while True:
        cpu = check_cpu_usage()
        mem = check_memory_usage()
        disk = check_disk_usage()

        msg = f"CPU: {cpu:.2f}% | Memory: {mem:.2f}% | Disk: {disk:.2f}%"
        print(msg)
        logging.info(msg)

        if cpu > CPU_THRESHOLD:
            alert = f"ALERT: High CPU usage detected: {cpu:.2f}%"
            print(alert)
            logging.warning(alert)
        if mem > MEM_THRESHOLD:
            alert = f"ALERT: High Memory usage detected: {mem:.2f}%"
            print(alert)
            logging.warning(alert)
        if disk > DISK_THRESHOLD:
            alert = f"ALERT: Low Disk space detected: {disk:.2f}% used"
            print(alert)
            logging.warning(alert)

        if not loop:
            break
        time.sleep(interval)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monitor system health")
    parser.add_argument("--loop", action="store_true", help="Monitor continuously")
    parser.add_argument("--interval", type=int, default=60, help="Loop interval in seconds")
    args = parser.parse_args()
    main(loop=args.loop, interval=args.interval)
