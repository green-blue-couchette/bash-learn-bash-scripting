#!/bin/bash

# Author: O.A.
# Usage: $./NC_4_2_game_final.sh

# Tutorial followed: https://www.youtube.com/watch?v=Fq6gqi9Ubog&list=PLIhvC56v63IKioClkSNDjW7iz-6TFvLwS&index=4
# Introduces concepts of CONDITIONALS, NESTED CONDITIONALS, CASES

# UPDATE: Added check for user "bernard" to the 2nd attack round.
# UPDATE: Replaced DRY-breaking attack reprompt code with while-loops in both battle rounds.
# UPDATE: Added easy/medium/hard indicators for player choice screen.
# TODO: Should replace the "divine help" codes with function calls to eliminate breaking DRY principle.

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
1 - Prophet	(easy)
2 - Layman	(medium)
3 - Evil person (harder) PS: Evil people don't get far."

# Player properties:
# player: 	prophet/layman/evil-person 	# used
# personality: 	joyful/neutral/grumbler 	# unused
# strength: 	strong/mediocre/weak		# used
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
		strength="weak"
		health="weak"
		divine_help="rarely"
		;;
esac

echo ""
echo "Your player choices -----
Player: 	$player
personality: 	$personality
strength: 	$strength
health: 	$health
divine help: 	$divine_help
-------------------------"


# First beast battle (50/50 chance)
echo ""
echo "Your first beast approaches. Prepare to battle. Pick a number between 0-1! (0/1)"

beast1value=$(( $RANDOM % 2 ))
# echo "Beast value is $beast1value." #debug

# divine help START
# (Case block for divine help breaks DRY principle. I'm still learning.)
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

# execute battle 1
# "coffee" is a cheat code to win the current attack
# "bernard" is a secret user to win the entire battle at once
attacks=0 # no. of attacks executed during this battle
while true
do
	read myvalue

	if [[ $myvalue == $beast1value || $myvalue == "coffee" ]]; then
		echo "You won!"
	elif [[ $USER == "bernard" ]]; then
		echo "Hey, Bernard always wins." # Automatically win without strength-dependent reprompt.
		break
	else
		echo "You lose!"
		exit 1
	fi

	(( attacks ++ ))
	# echo "$attacks attacks so far. (debug)" # debug

	if [[ $strength == "weak" && $attacks < 2 ]]; then # Check if user is weak. If yes, reprompt for a 2nd attack!
		echo "You're weak; hit one more time. (Same number.)"
		continue # if battle is incomplete, prompt for a new attack
	fi

	# When attack is done, quit WHILE-loop
	break
done

sleep 1


# Second beast battle (1/10 chance)
echo ""
echo "Your second beast approaches. Prepare for battle. Pick a number between 0-9! (0-9)"

beast2value=$(( $RANDOM % 10 ))
# echo "Beast value is $beast2value." #debug

# divine help START
# (Case block for divine help breaks DRY principle. I'm still learning.)
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
## divine help END

# Execute battle 2
# "coffee" is a cheat code to win the current attack
# "bernard" is a secret user to win the entire battle at once
# user loses if player isn't logged in as "air" or "bernard"
attacks=0 # no. of attacks executed during this battle
while true
do
	read myvalue

	if [[ $USER == "air" ]]; then
		if [[ $myvalue == $beast2value || $myvalue == "coffee" ]]; then
			echo "You won!"
		else
			echo "You lose!"
			exit 1
		fi

		(( attacks ++ ))
		# echo "$attacks attacks so far. (debug)" # debug

		if [[ $strength == "weak" && $attacks < 2 ]]; then # Check if user is weak. If yes, reprompt for a 2nd attack!
			echo "You're weak; hit one more time. (Same number.)"
			continue # if battle is incomplete, prompt for a new attack
		fi

	elif [[ $USER == "bernard" ]]; then
		echo "Hey, Bernard always wins." # Automatically win without strength-dependent reprompt.
		break
	else
		echo "You lose! You're not \"air\"." # Do not reveal to player that "bernard" is also a possible user. (echo "You're not \"air\" or \"bernard\".")
		exit 1
	fi

	# When attack is done, quit WHILE-loop
	break
done
