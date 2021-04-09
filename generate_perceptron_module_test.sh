#!/bin/bash
cat *_module/* > temp
sed -i "/^.*globl.*$/d" temp
cat perceptron_module_test.s > main.s
cat temp >> main.s
rm temp