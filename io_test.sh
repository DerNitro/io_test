#!/bin/bash

SECONDS=0

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

printf '%-20s%12s%10s%12s%10s\n' "TEST" "WRITE" "SEC" "READ" "SEC"

for test in ${TESTS}; do 
    if [ $(id -u) = 0 ]; then
        sync; echo 1 > /proc/sys/vm/drop_caches
        sync; echo 2 > /proc/sys/vm/drop_caches
        sync; echo 3 > /proc/sys/vm/drop_caches
    fi
    TEST_FILE="$TEST_FOLDER/$BS-$COUNT.iotest"
    BS=$(echo $test | cut -d ":" -f 1)
    COUNT=$(echo $test | cut -d ":" -f 2)
    WRITE=$(dd if=/dev/zero of=$TEST_FILE bs=$BS count=$COUNT 2>&1 | tail -n1 | awk '{print $(NF-1), $NF, $(NF-3)}')
    WRITE=($WRITE)
    READ=$(dd if=$TEST_FILE of=/dev/null bs=$BS count=$COUNT 2>&1 | tail -n1 | awk '{print $(NF-1), $NF, $(NF-3)}')
    READ=($READ)
    printf '%-20s%12s%10.3f%12s%10.3f\n' "bs=$BS count=$COUNT" "${WRITE[0]} ${WRITE[1]}" "${WRITE[2]}" "${READ[0]} ${READ[1]}" "${READ[2]}"
    rm $TEST_FILE
done

echo ""
echo "Script complete $SECONDS seconds."
echo ""
