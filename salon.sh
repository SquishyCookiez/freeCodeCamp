#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?\n" 

  # Display available services
  DISPLAY_SERVICES
  read SERVICE_ID_SELECTED
 
  # If service selected does not exist
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_ID ]]
  then
    # Send to main menu
    MAIN_MENU "Please enter a valid option." 
  else
    # Get customer info
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # If customer does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Get customer name
      echo -e "\nThere is no record for that phone number. What is your name?"
      read CUSTOMER_NAME

      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Format output
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
    SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
    SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed 's/ |/"/')  

    # Get customer appointment time   
    echo -e "\nWhat time would you like your $SERVICE_INFO_FORMATTED, $CUSTOMER_NAME_FORMATTED"
    read SERVICE_TIME

    # Add appointment 
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
 
    echo -e "\nI have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

DISPLAY_SERVICES() {
  # Get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_Id, name FROM services ORDER BY service_id")

  # Display available services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU