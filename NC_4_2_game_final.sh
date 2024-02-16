#!/bin/bash

# Author: O.A.

# Usage: ./NC_4_2_game_final.sh

# Introduces concepts of CONDITIONALS, NESTED CONDITIONALS, CASES

# - CONDITIONALS (aka. "if" statements)
# if [[ some condition ]]; then
# 	(some code)
# elif [[ some condition ]]; then
#	(some code)
# else
#	(some code)
# fi
# NOTE: MAKE SURE TO KEEP THE BLANK SPACE BETWEEN "some condition" and the closing "]]".


# - CONDITIONALS ("case" statements)
# read some_variable (supposing that some_variable takes only numeric values)
# case $somevariable in
# 1)
#	(do something)
#	;;
# 2)
#	(do something)
#	;;
# 3)
#	(do something)
#	;;
# esac

echo "Welcome! Choose your player personality (1-3):
1 - Prophet
2 - Layman
3 - Evil person. PS: Evil people don't get far."

# Player properties:
# player: 	prophet/layman/evil-person 	# used
# personality: 	joyful/neutral/grumbler 	# unused
# strength: 	strong/mediocre/weak		# unused
# health: 	good/so-and-so/weak		# unused
# divine_help:	always/sometimes/rarely 	# used

read player_choice

case $player_choice in
	1)
		player="Prophet"
		personality="joyful"
		strength="mediocre"
		health="good"
		divine_help="always"
		;;

	2)
		player="Layman"
		personality="neutral"
		strength="mediocre"
		health="so-and-so"
		divine_help="sometimes"
		;;

	3)
		player="Evil person"
		personality="grumbler"
		strength="mediocre"
		health="weak"
		divine_help="rarely"
		;;
esac

echo ""
echo "Your player choices ---
Player: 	$player,
personality: 	$personality,
strength: 	$strength,
health: 	$health,
divine help: 	$divine_help"

# First beast battle (50/50 chance)
echo ""
echo "Your first beast approaches. Prepare to battle. Pick a number between 0-1! (0/1)"

beast1value=$(( $RANDOM % 2 ))
# echo "Beast value is $beastvalue." #debug

# divine help START
case $divine_help in
	"always")
		echo "Divine help: Choose $beast1value!"
		echo "You're always blessed with divine help!"
		;;

	"sometimes")
		# calculate divine help (50% chance)
		# if yes, echo it.
		if [[ $(( $RANDOM % 10 )) > 4 ]]; then
			echo "Divine help: Choose $beast1value!"
			echo "SOMETIMES you get divine help. You just don't know where it comes from."
		fi
		;;

	"rarely")
		# calculate divine help (10% chance)
		# if yes, echo it
		if [[ $(( $RANDOM % 10 )) > 8 ]]; then
			echo "Divine help: Choose $beast1value!"
			echo "You RARELY get divine help, but you're so glad when you do."
		fi
		;;
esac
# divine help END

read myvalue

# execute attack
if [[ $myvalue == $beast1value || $myvalue == "coffee" ]]; then
	echo "You won!"
elif [[ $USER="bernard" ]]; then
	echo "Hey, Bernard always wins."
else
	echo "You lose!"
	exit 1
fi

echo ""
sleep 1


# Second beast battle (1/10 chance)
echo "Your second beast approaches. Prepare for battle. Pick a number between 0-9! (0-9)"

beast2value=$(( $RANDOM % 10 ))
# echo "Beast 2 value is $beast2value." #debug

# divine help START
case $divine_help in
	"always")
		echo "Divine help: Choose $beast2value!"
		echo "You're always blessed with divine help!"
		;;

	"sometimes")
		# calculate divine help (50% chance)
		# if yes, echo it.
		if [[ $(( $RANDOM % 10 )) > 4 ]]; then
			echo "Divine help: Choose $beast2value!"
			echo "SOMETIMES you get divine help. You just don't know where it comes from."
		fi
		;;

	"rarely")
		# calculate divine help (10% chance)
		# if yes, echo it
		if [[ $(( $RANDOM % 10 )) > 8 ]]; then
			echo "Divine help: Choose $beast2value!"
			echo "You RARELY get divine help, but you're so glad when you do."
		fi
		;;
esac
# divine help END

read myvalue

# execute attack
# "coffee" is a cheat code
if [[ $myvalue == $beast2value || $myvalue == "coffee" ]]; then
	if [[ $USER == "air" ]]; then
		echo "You won!"
	else
		echo "You lose! You're not \"air\"."	# not an elegant way to program this loss.
		exit 1
	fi
else
	echo "You lose!"
	exit 1
fi

