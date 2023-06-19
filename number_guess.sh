#!/bin/bash
# ~~ number_guess.sh ~~

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# ~~ USERNAME ~~
# Ask the user for a username
echo "Enter your username:"
read USERNAME

# Search if username in number_guess database
USER_ID_RESULT=$($PSQL "SELECT user_id FROM usernames WHERE username='$USERNAME'")

# If username does not exist
if [[ -z $USER_ID_RESULT ]]
then
  # Insert username into usernames table
  INSERT_USERNAME=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
  USER_ID_RESULT=$($PSQL "SELECT user_id FROM usernames WHERE username='$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else 
  # Get COUNT of games played and min number_of_guesses
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID_RESULT")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID_RESULT")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
 
# ~~ Game Variables ~~
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

# ~~ MAIN GAME LOOP ~~
NUMBER_GUESS() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi  

  # Get user guess and check if valid
  read USER_GUESS
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    # Send to main game loop
    NUMBER_GUESS "That is not an integer, guess again:"
  else   
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))  

    # Check user guess
    if [[ $USER_GUESS -ne $SECRET_NUMBER ]]
    then     
      # If user guess is higher than secret number
      if [[ $USER_GUESS -gt $SECRET_NUMBER ]]
      then        
        NUMBER_GUESS "It's lower than that, guess again:"
      # Else if user guess is lower than secret number
      else      
        NUMBER_GUESS "It's higher than that, guess again:" 
      fi 
    # User guessed correctly
    else    
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"    

      # Insert game into games table
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(number_of_guesses, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID_RESULT)")
    fi  
  fi
}

# Begin game and ask user for a number between 1 and 1000
NUMBER_GUESS "Guess the secret number between 1 and 1000:"
