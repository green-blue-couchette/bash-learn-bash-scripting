#!/bin/bash

# Author: O.A.

# Usage: $./NC_3_3_getrichquick_final.sh

# Uses concept of VARIABLES, SYSTEM/ENVIRONMENT VARIABLES (including in the ~/.bashrc file), COMMANDS (arithmetic expressions)

# - Commands (arithmetic expressions)
# echo $((1+2))
# Will print 3

# - The ~/.bashrc file
# Added export twitter="Elon Musk"
# This lets us use $twitter in this script.


echo "Hello, what is your name?"
read name

echo "How old are you?"
read age

echo "Hello, $name. You are $age years old!"
echo ""

echo "Calculating..."
echo "----------"
sleep 0.5
echo "**--------"
sleep 0.5
echo "****------"
sleep 0.5
echo "******----"
sleep 0.5
echo "********--"
sleep 0.5
echo "**********"

getrich=$(( $age + ($RANDOM + 10) ))

echo "You will get rich at $(( $age + ($RANDOM % 10) ))."

echo "(I love $myHeart.)"
 
