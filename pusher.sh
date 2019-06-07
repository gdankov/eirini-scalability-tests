#!/bin/bash

set -e

readonly TIMES="${1:?How many times?}"
readonly BATCH_SIZE="${2:?What batch size}"
readonly DOMAIN="bbl-scale-test.eirini-test.tk"
readonly CURL_COUNT="5"
readonly TIME_BETWEEN_CURLS="1"

readonly APP_NAME="dora"
readonly LOGS_DIR="$PWD/logs"


push-it() {
    local current_app_name="${APP_NAME}${1}"
    cf push -m "256M" "${current_app_name}" -p /Users/eirini/workspace/cf-acceptance-tests/assets/dora  >"${LOGS_DIR}/${current_app_name}" 2>&1
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

deploy() {
    local from=$1
    local to=$2
    for i in $(seq "$from" "$to");do
        test-it "$i" &
        # sleep 0.5
    done
    wait
}

main() {
    local start=0;
    local end=0
    while [[ "$end" -lt "$TIMES" ]]; do
        end=$(bc <<< "$start + $BATCH_SIZE")
        deploy $start $end
        start=$(bc <<< "$end + 1")
    done

    for i in $(seq 1 $TIMES);do
        curl-it "$i" &
    done
}

main
