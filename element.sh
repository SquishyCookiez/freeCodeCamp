#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align -c"

SEARCH_ELEMENT() {
  # Check if argument is a atomic_number (INT) in elements table
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # Get atomic_number directly using argument
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")      
  # Check if argument is a symbol in elements table    
  elif [[ $1 =~ ^[A-Z][a-z]$ || $1 == [A-Z] ]]
  then   
    # Get atomic number using symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")     
  # Check if argument is name in elements table   
  elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
  then
    # Get atomic number using name
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")  
  fi  
  
  # If element not in database or does not exist
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
     # Get name and symbol from elements table  
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")     
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")

    # Get type from types table    
    TYPE=$($PSQL "SELECT type FROM properties LEFT JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
    
    # Get atomic mass from properties table
    ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  
    # Get melting point from properties table
    MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
    
    # Get boiling point from properties table
    BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")

    # Print element information
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi   
}

# Main
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  #
  SEARCH_ELEMENT $1
fi
