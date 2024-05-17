#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align --tuples-only -c"

RANDOM_NUMBER=$(($RANDOM%1000))
echo "$RANDOM_NUMBER"
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
# if username not found 
if [[ -z $USER_ID ]]
then
  #print welcome message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_RESULT=$($PSQL "INSERT INTO users (name,games_played) VALUES ('$USERNAME',0)")
# if found
else
  # get user's information
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")
  USERNAME=$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")
  # print statistics
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
NUMBER_GUESSED=1001
ATTEMPT=0
while [[ $NUMBER_GUESSED != $RANDOM_NUMBER ]]
do
  ((ATTEMPT++))
  read NUMBER_GUESSED
  # if not a number
  if [[ ! $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  # if it is a number
  else
    # if lower
    if [[ $NUMBER_GUESSED -lt $RANDOM_NUMBER ]]
    then 
      echo "It's higher than that, guess again:"
    # if higher
    elif [[ $NUMBER_GUESSED -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    # if equal
    else
      USER_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1,best_game=CASE WHEN best_game IS NULL THEN $ATTEMPT WHEN best_game > $ATTEMPT THEN $ATTEMPT ELSE BEST_GAME END WHERE name='$USERNAME'")
      echo "You guessed it in $ATTEMPT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  fi
done
