#!/usr/bin/env bash
count=10
name_file="temp"
echo $count
while [[ $count -gt 0 ]]
do
	echo $count
	python2.7 npuzzle-gen.py -s 3 > $name_file
	time ./puzzle temp >> /dev/null
	let count=$count-1
done
rm $name_file
