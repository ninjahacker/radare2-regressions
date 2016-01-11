#!/bin/sh

echo "test base64"
./unit/test_base64 || return 1
echo "test list"
./unit/test_list || return 1
