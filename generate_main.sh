#!/bin/bash
scriptdir="$(dirname "$0")"
cd "$scriptdir"

cat ./driver.s > ./main.s
cat ./*_module/* > ./temp
sed -i "/^.*globl.*$/d" ./temp
cat ./temp >> ./main.s
rm ./temp