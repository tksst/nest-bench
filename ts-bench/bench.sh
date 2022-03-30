#!/bin/bash

set -o posix

function is_not_int(){
    if [[ $1 =~ ^([0-9]|[1-9][0-9]+)$ ]]; then
        return 1
    fi
    return 0
}

function testarg(){
    if is_not_int "$1"; then
        echo "$2 is not a number" 1>&2
        exit 1
    fi
}

function run(){
    local name=$1
    local times=$2
    local opt=$3

    for ((i=0; i < times; i++)); do
        timeresult=$( mktemp "ts-bench-${name}_time_${i}_XXXXXX" )
        output=$( mktemp "ts-bench-${name}_out_${i}_XXXXXX" )
        if [[ $name == "local" ]];then
            npx gulp clean > /dev/null 2>&1
        fi
        echo -n "${name}: "
        # shellcheck disable=SC2086
        ( time npx gulp "${name}" ${opt} > "$output" 2>&1 ) 2> "$timeresult"
        rv=$?

        if [[ $rv == 0 ]]; then
            cat "$timeresult"
        else
            echo "exited status $rv, output below:"
            cat "$output" >&2
            exit $rv
        fi
        rm -f "$timeresult" "$output"
    done
}

TIMEFORMAT='elapsed: %3R seconds,  CPU usage: %P%%'

OPT=$( getopt -o l:t:w:o: -l local:,runtests-parallel:,workers:,out-dir: -- "$@" ) || exit 4

eval set -- "$OPT"

local_times=0
runtestsparallel_times=0
workers=0

while true
do
    case $1 in
        -l | --local)
            shift
            testarg "$1" local
            local_times=$1
            shift
            ;;
        -t | --runtests-parallel)
            shift
            testarg "$1" runtests-parallel
            runtestsparallel_times=$1
            shift
            ;;
        -w | --workers)
            shift
            testarg "$1" workers
            workers=$1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error" 1>&2
            exit 5
            ;;
    esac
done

if [[ $workers -gt 0 ]]; then
    workersopt=--workers=$workers
fi

cd /home/node/TypeScript || exit 1

run local "$local_times"
run runtests-parallel "$runtestsparallel_times" "$workersopt"
