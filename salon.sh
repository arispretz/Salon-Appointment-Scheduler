#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

# Menu
MAIN_MENU () {
# If function called with error message
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

  # Get services 
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # Read services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  # Display services
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # Read service selected
  read SERVICE_ID_SELECTED
  # If not a valid service
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
  # Send to main menu
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
  # Check service
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # If service not found
    if [[ -z $SERVICE_NAME ]] 
    then
  # Send to main menu
      MAIN_MENU "\nI could not find that service. What would you like today?"
    else
      CUSTOMER_INFO "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
    fi
  fi  
}
   # Get customer info
CUSTOMER_INFO () {
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME=$2
   # Ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
   # Get customer name 
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
   # If customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
   # Ask for customer name 
    echo -e "\nI don't have a record of that phone number, what's your name?"
    read CUSTOMER_NAME
   # Add new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
   # Get customer_id 
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
   # Ask for service time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME, $CUSTOMER_NAME? | sed -E 's/^ +| +$//g')"
  read SERVICE_TIME
  # Add appointment
  ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VAlUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  # If appointment wasn't succesful
  if [[ $ADD_APPOINTMENT_RESULT != "INSERT 0 1" ]] 
  then
   # Send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
   # Print success message
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
  fi
}

MAIN_MENU "Welcome to Beauty Salon. How may I help you?"
