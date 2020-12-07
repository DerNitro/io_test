#!/bin/bash

TEST_FOLDER=$1

TESTS="4k:100 4k:10000 1M:100 1M:1000 10M:10 10M:100"

if [ -z $TEST_FOLDER ]; then
    echo "Не указана директория тестирования!!"
    echo "run: $0 TEST_FOLDER"
    exit 1
fi

umask 0000

echo ""
echo "Zero test speed: $(dd if=/dev/zero of=/dev/null bs=1M count=1024 2>&1 | tail -n1 | awk '{print $(NF-1), $NF}')"
echo ""

printf '%-20s%12s%12s\n' "TEST" "WRITE" "READ"

for test in ${TESTS}; do 
    TEST_FILE="$TEST_FOLDER/$BS-$COUNT.iotest"
    BS=$(echo $test | cut -d ":" -f 1)
    COUNT=$(echo $test | cut -d ":" -f 2)
    if [ $(id -u) = 0 ]; then
        sync; echo 1 > /proc/sys/vm/drop_caches
        sync; echo 2 > /proc/sys/vm/drop_caches
        sync; echo 3 > /proc/sys/vm/drop_caches
    fi
    WRITE=$(dd if=/dev/zero of=$TEST_FILE bs=$BS count=$COUNT 2>&1 | tail -n1 | awk '{print $(NF-1), $NF}')
    READ=$(dd if=$TEST_FILE of=/dev/null bs=$BS count=$COUNT 2>&1 | tail -n1 | awk '{print $(NF-1), $NF}')
    printf '%-20s%12s%12s\n' "bs=$BS count=$COUNT" "$WRITE" "$READ"
    rm $TEST_FILE
done