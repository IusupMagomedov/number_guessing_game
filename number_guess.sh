#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
MAIN_MENU() {
  echo "Enter your username:"
  read USER_NAME
  if [[ $USER_NAME =~ ^[a-zA-Z0-9_]{0,22}$ ]]
  then
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USER_NAME'")
    # echo "User ID after requesting: $USER_ID"
    if [[ -z $USER_ID ]]
    then
      echo "Welcome, $USER_NAME! It looks like this is your first time here."
      GAMES_PLAYED=0
      BEST_GAME=1000
      INSERTED_USER=$($PSQL "INSERT INTO users (user_name, games_played, best_game) VALUES ('$USER_NAME', $GAMES_PLAYED, $BEST_GAME)")
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USER_NAME'")
    else
      GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
      BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = '$USER_ID'")
      echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi
    GENERATED_NUMBER=$(($RANDOM * 1000 / 32767 ))
    # echo "Firstly generated number: $GENERATED_NUMBER"
    GUESS_UNSUCCESS=1
    NUMBER_OF_GUESSES=0
    while (( $GUESS_UNSUCCESS ))
    do
      echo "Guess the secret number between 1 and 1000:"
      read TRY_NUMBER
      NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES+1 ))
      RE='^[0-9]+$'
      if [[ $TRY_NUMBER =~ $RE ]]
      then
        if [[ $TRY_NUMBER == $GENERATED_NUMBER ]]
        then
          # user guessed number
          GUESS_UNSUCCESS=0
          # echo "Number of guesses before condition: $NUMBER_OF_GUESSES"
          # echo "Number of guesses in best game before condition: $BEST_GAME"
          # if [[ $BEST_GAME < $NUMBER_OF_GUESSES ]]
          if [ $BEST_GAME -gt $NUMBER_OF_GUESSES ]
          then
            BEST_GAME=$NUMBER_OF_GUESSES
            # echo "Reach the BEST_GAME updating" 
          fi
          GAMES_PLAYED=$(( GAMES_PLAYED+1 ))
          # echo "Number of guesses before updating: $NUMBER_OF_GUESSES"
          # echo "Number of guesses in best game before updating: $BEST_GAME"
          FINISH_UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED,  best_game = $BEST_GAME WHERE user_id = $USER_ID")
          echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GENERATED_NUMBER. Nice job!"
        else
          if [ $GENERATED_NUMBER -gt $TRY_NUMBER ]
          then 
            echo "It's lower than that, guess again:"
          else 
            echo "It's higher than that, guess again:"
          fi
        fi
      else 
      echo "That is not an integer, guess again:"
      fi
    done
  else 
    echo "Please enter a valid username. Just 22 characters."
    MAIN_MENU
  fi
}


MAIN_MENU
