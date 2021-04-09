#!/bin/bash
cat *_module/* > temp
sed -i "/^.*globl.*$/d" temp
cat linalg_debug_modules_test.s > main.s
cat temp >> main.s
rm temp