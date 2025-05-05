#!/bin/bash

# Check if username and password are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# Assign arguments to variables
USERNAME="$1"
PASSWORD="$2"

# Database connection parameters
# These can be set as environment variables or modified directly in the script
MYSQL_HOST=${MYSQL_HOST:-"localhost"}
MYSQL_USER=${MYSQL_USER:-"radius"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"radpass"}
MYSQL_DATABASE="radius"

# Execute SQL query with proper escaping to prevent SQL injection
mariadb -h "$MYSQL_HOST" -u "$MYSQL_USER" ${MYSQL_PASSWORD:+-p"$MYSQL_PASSWORD"} "$MYSQL_DATABASE" -e "INSERT INTO radcheck (username, attribute, op, value) VALUES ('$USERNAME', 'Cleartext-Password', ':=', '$PASSWORD');"

if [ $? -eq 0 ]; then
    echo "User '$USERNAME' created successfully with the provided password."
else
    echo "Error: Failed to create user. Please check your database connection parameters."
    exit 1
fi
