#!/bin/bash

set -e

readonly TIMES="${1:?How many times?}"
readonly DOMAIN="158.176.93.40.nip.io"
readonly CURL_COUNT="5"
readonly TIME_BETWEEN_CURLS="1"

readonly APP_NAME="staticfile"
readonly LOGS_DIR="../logs"


push-it() {
    local current_app_name="${APP_NAME}${1}"
    cf push -m "256M" "${current_app_name}" >"${LOGS_DIR}/${current_app_name}" 2>&1
}

curl-it() {
    local app_index="$1"
    local url="${APP_NAME}${1}.${DOMAIN}"

    echo -e "\n\n================== CURLING TIME ==================\n\n" >> "${LOGS_DIR}/${APP_NAME}${1}"
    for i in $(seq 1 "$CURL_COUNT");do
        curl --fail "$url" >> "${LOGS_DIR}/${APP_NAME}${app_index}" 2>&1
        if [ $? -eq 0 ]; then
            echo -e "Try ${i}: success\n" >> "${LOGS_DIR}/${APP_NAME}${app_index}"
        else
            echo -e "Try ${i}: failure\n" >> "${LOGS_DIR}/${APP_NAME}${app_index}"
        fi
        sleep "$TIME_BETWEEN_CURLS"
    done
}

test-it() {
    local index="$1"
    mkdir -p "$LOGS_DIR"
    touch "${LOGS_DIR}/${APP_NAME}${index}"
    push-it "$index"
    curl-it "$index"
}

main() {
    cd staticfile
    for i in $(seq 1 $TIMES);do
        test-it "$i" &
        # sleep 0.5
    done
    wait
}

main
