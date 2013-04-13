#!/bin/bash

export BOAR_CACHEDIR=`mktemp --tmpdir=/tmp/ -d "boar_tests_cache_XXXXX"`
export BOAR_SERVER_CLI="`pwd`/boar"

test -e run_tests.sh || { echo "This command must be executed in the boar installation top dir"; exit 1; }
test -e cdedup.so || { echo "ERROR: dedup module unavailable"; exit 1; }

#
# Test with deduplication
#

for unittest in tests/test_*.py blobrepo/tests/test_*.py; do
    echo "Excuting $unittest (cachedir $BOAR_CACHEDIR)"
    python $unittest || { echo "Unittest $unittest failed"; exit 1; }
done


rm -r $BOAR_CACHEDIR

echo "Executing local macro tests"
BOAR_TEST_REMOTE_REPO=0 macrotests/macrotest.sh || { echo "Macrotests (local) failed"; exit 1; }
echo "Executing simulated remote macro tests"
BOAR_TEST_REMOTE_REPO=1 macrotests/macrotest.sh || { echo "Macrotests (remote) failed"; exit 1; }
echo "Executing ssh remote macro tests"
BOAR_TEST_REMOTE_REPO=2 macrotests/macrotest.sh || { echo "Macrotests (remote) failed"; exit 1; }
