#!/bin/bash

readonly COMMAND="${1:?Provide a command}"
readonly TIMES="${2:?How many times?}"
readonly DOMAIN="158.176.93.40.nip.io"
readonly CURL_COUNT="5"
readonly TIME_BETWEEN_CURLS="1"

FAIL=0

push-it() {
    cf push -m "256M" "staticfile${1}" >"../logs/staticfile${1}" 2>&1
}

delete() {
    for i in $(seq 1 "$TIMES");do cf delete -f "staticfile${i}"; done
}

curl-it() {
    echo -e "\n\n================== CURLING TIME ==================\n\n" >> "../logs/staticfile${1}"
    local url="staticfile${1}.${DOMAIN}"
    for i in $(seq 1 "$CURL_COUNT");do
        curl --fail "$url" >> "../logs/staticfile{1}" 2>&1
        if [ $? -eq 0 ]; then
            echo -e "Try ${i}: success\n" >> "../logs/staticfile${1}"
        else
            echo -e "Try ${i}: failure\n" >> "../logs/staticfile${1}"
            FAIL=1
        fi
        sleep "$TIME_BETWEEN_CURLS"
    done
}


test() {
    local index="$1"
    touch "../logs/staticfile${index}"
    push-it "$index"
    curl-it "$index"
}

main() {
    if [ "$COMMAND" == "clean" ];then
        delete
    elif [ "$COMMAND" == "push" ];then
        cd staticfile
        for i in $(seq 1 $TIMES);do
            test "$i" &
        done
        wait
        exit $FAIL
    fi
}

main
