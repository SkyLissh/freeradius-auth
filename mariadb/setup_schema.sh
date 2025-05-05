#!/bin/bash

# Script to create the FreeRADIUS database schema

# Database connection parameters
# These can be set as environment variables or modified directly in the script
MYSQL_HOST=${MYSQL_HOST:-"localhost"}
MYSQL_USER=${MYSQL_USER:-"radius"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"radpass"}
MYSQL_DATABASE=${MYSQL_DATABASE:-"radius"}

# Path to the schema file
SCHEMA_FILE="schema.sql"

# Check if schema file exists
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Error: Schema file '$SCHEMA_FILE' not found."
    exit 1
fi

# Create database if it doesn't exist
echo "Creating database '$MYSQL_DATABASE' if it doesn't exist..."
mariadb -h "$MYSQL_HOST" -u "$MYSQL_USER" ${MYSQL_PASSWORD:+-p"$MYSQL_PASSWORD"} -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"

if [ $? -ne 0 ]; then
    echo "Error: Failed to create database. Please check your database connection parameters."
    exit 1
fi

# Import schema
echo "Importing schema into database '$MYSQL_DATABASE'..."
mariadb -h "$MYSQL_HOST" -u "$MYSQL_USER" ${MYSQL_PASSWORD:+-p"$MYSQL_PASSWORD"} "$MYSQL_DATABASE" < "$SCHEMA_FILE"

if [ $? -eq 0 ]; then
    echo "Schema successfully imported into database '$MYSQL_DATABASE'."
else
    echo "Error: Failed to import schema. Please check your database connection parameters and schema file."
    exit 1
fi

echo "Database setup completed successfully!"
