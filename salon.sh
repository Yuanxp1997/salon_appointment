#!/bin/bash

PSQL="psql -t --username=freecodecamp --dbname=salon -c"


echo "Welcome to the Salon Database"
MAIN_MENU() {
    
    echo "Please select an option:"
    echo "$($PSQL 'SELECT * FROM services')" | while read SERVICE_ID BAR SERVICE; do
        echo $SERVICE_ID")" $SERVICE 
    done
    read SERVICE_ID_SELECTED
    # if service id does not exist, return to main menu
    if [[ -z "$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")" ]]; then
        echo -e "\nInvalid service id"
        MAIN_MENU
    else
        # ask for customer phone number
        echo "Please enter your phone number:"
        read CUSTOMER_PHONE
        # check if customer exists
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z "$CUSTOMER_ID" ]]; then
            echo "Whta is your name?"
            read CUSTOMER_NAME
            # create new customer
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]; then
                CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
                # ask for appointment time
                echo "When would you like to schedule your appointment?"
                read SERVICE_TIME
                # create new appointment
                INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
                if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
                    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
                    echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
                    EXIT
                else
                    echo "Failed to schedule appointment"
                    EXIT
                fi
            else
                echo "Failed to create customer"
                EXIT
            fi
        fi
    fi
}

EXIT() {
    echo "Goodbye"
    exit
}

MAIN_MENU
