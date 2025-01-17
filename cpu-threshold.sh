#!/bin/bash

WEBHOOK_URL="WEBHOOK_URL_HERE"

HOSTNAME=$(hostname)
IP_LOCAL=$(hostname -I | awk '{print $1}')

send_discord_message() {
    local color="$1"
    local title="$2"
    local description="$3"

    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{
              "embeds": [
                {
                  "title": "'"$title"'",
                  "description": "'"$description"'",
                  "color": '"$color"'
                }
              ]
         }' "$WEBHOOK_URL"
}

while true; do
    TEMPERATURES=$(sensors | grep -E 'Package id 0|temp[0-9]+:' | awk '{print $2}' | tr -d '+°C')

    if [ -z "$TEMPERATURES" ]; then
        echo "No temp sensors detected. Check the sensors command."
        exit 1
    fi

    TEMP_SUM=0
    TEMP_COUNT=0

    for TEMP in $TEMPERATURES; do
        TEMP_SUM=$(echo "$TEMP_SUM + $TEMP" | bc)
        TEMP_COUNT=$((TEMP_COUNT + 1))
    done

    TEMP_AVG=$(echo "scale=2; $TEMP_SUM / $TEMP_COUNT" | bc)

    echo "Detected temperatures: $TEMPERATURES"
    echo "Average temp: $TEMP_AVG°C"

    if (( $(echo "$TEMP_AVG < 0" | bc -l) )); then
        send_discord_message "3447003" "⚠️ Abnormal temperature warning" \
            "The probe may be damaged or displaying erroneous results.\nHostname: ${HOSTNAME} (${IP_LOCAL})\nMeasured temperature: ${TEMP_AVG}°C"
    elif (( $(echo "$TEMP_AVG >= 0 && $TEMP_AVG <= 20" | bc -l) )); then
        send_discord_message "3447003" "⚠️ Too cold temperature warning" \
            "Hostname: ${HOSTNAME} (${IP_LOCAL})\nMeasured temperature: ${TEMP_AVG}°C"
    elif (( $(echo "$TEMP_AVG >= 21 && $TEMP_AVG <= 49" | bc -l) )); then
        echo "Good temp (${TEMP_AVG}°C). No send warnings."
    elif (( $(echo "$TEMP_AVG >= 50 && $TEMP_AVG <= 69" | bc -l) )); then
        send_discord_message "16776960" "⚠️ High temperature warning" \
            "Hostname: ${HOSTNAME} (${IP_LOCAL})\nMeasured temperature: ${TEMP_AVG}°C"
    elif (( $(echo "$TEMP_AVG >= 70 && $TEMP_AVG <= 79" | bc -l) )); then
        send_discord_message "16753920" "⚠️ Very high temperature warning" \
            "\nHostname: ${HOSTNAME} (${IP_LOCAL})\nMeasured temperature: ${TEMP_AVG}°C"
    elif (( $(echo "$TEMP_AVG >= 80" | bc -l) )); then
        send_discord_message "16711680" "🚨 Critical temperature warning" \
            "\nHostname: ${HOSTNAME} (${IP_LOCAL})\nMeasured temperature: ${TEMP_AVG}°C\n**Server will shut down in 10 seconds to prevent any damage.**"
        sleep 10
        shutdown now
    fi

    sleep 10
done
