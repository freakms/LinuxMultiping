#!/bin/bash

read -rp "Bitte IP-Adressen eingeben (kommagetrennt): " input

IFS=',' read -ra targets <<< "$input"

pids=()

cleanup() {
    echo
    echo "Beende alle Ping-Prozesse..."
    for pid in "${pids[@]}"; do
        kill "$pid" 2>/dev/null
    done
    exit 0
}

trap cleanup SIGINT SIGTERM

for raw_target in "${targets[@]}"; do
    target="$(echo "$raw_target" | xargs)"   # Leerzeichen entfernen

    if [[ -z "$target" ]]; then
        continue
    fi

    logfile="/tmp/${target}.txt"

    echo "Starte dauerhaftes Ping für $target"
    echo "Logdatei: $logfile"

    (
        while true; do
            timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

            if ping -c 1 -W 1 "$target" >/dev/null 2>&1; then
                echo "$timestamp - $target - erreichbar" >> "$logfile"
            else
                echo "$timestamp - $target - nicht erreichbar" >> "$logfile"
            fi

            sleep 1
        done
    ) &

    pids+=("$!")
done

wait
