#!/bin/bash
cat linalg_debug_modules_test.s > main.s
cat linalg_module/* debug_module/* > temp
sed -i "/^.*globl.*$/d" temp
cat temp >> main.s
rm temp