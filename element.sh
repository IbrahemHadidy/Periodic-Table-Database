#!/bin/bash

# Function to execute psql with predefined options
periodic_table_psql() {
  psql --username=freecodecamp --dbname=periodic_table -t --no-align -c "$@"
}

# Function to print element details
print_element_details() {
  echo "The element with atomic number $1 is $2 ($3). It's a $4, with a mass of $5 amu. $2 has a melting point of $6 celsius and a boiling point of $7 celsius."
}

# Function to print error message
print_error_message() {
  echo "I could not find that element in the database."
}

# Function to check if element exists in database
element_exists() {
  query_result=$(periodic_table_psql "$1")
  [ -n "$query_result" ]
}

# Function to get element details by atomic number
get_element_by_atomic_number() {
  atomic_number=$1
  # Query the database for element details based on atomic number
  result=$(periodic_table_psql "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number WHERE elements.atomic_number = $atomic_number")
  if [ -n "$result" ]; then
    IFS='|' read -r name symbol type atomic_mass melting_point boiling_point <<< "$result"
    print_element_details "$atomic_number" "$name" "$symbol" "$type" "$atomic_mass" "$melting_point" "$boiling_point"
  else
    print_error_message
  fi
}

# Function to get element details by symbol
get_element_by_symbol() {
  symbol=$1
  # Query the database for element details based on symbol
  atomic_number=$(periodic_table_psql "SELECT atomic_number FROM elements WHERE symbol = '$symbol'")
  result=$(periodic_table_psql "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number WHERE elements.symbol = '$symbol'")
  if [ -n "$result" ]; then
    IFS='|' read -r name symbol type atomic_mass melting_point boiling_point <<< "$result"
    print_element_details "$atomic_number" "$name" "$symbol" "$type" "$atomic_mass" "$melting_point" "$boiling_point"
  else
    print_error_message
  fi
}

# Function to get element details by name
get_element_by_name() {
  name=$1
  # Query the database for element details based on name
  atomic_number=$(periodic_table_psql "SELECT atomic_number FROM elements WHERE name = '$name'")
  result=$(periodic_table_psql "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number WHERE elements.name = '$name'")
  if [ -n "$result" ]; then
    IFS='|' read -r name symbol type atomic_mass melting_point boiling_point <<< "$result"
    print_element_details "$atomic_number" "$name" "$symbol" "$type" "$atomic_mass" "$melting_point" "$boiling_point"
  else
    print_error_message
  fi
}

# Main script
if [ $# -eq 0 ]; then
  echo "Please provide an element as an argument."
else
  case "$1" in
    [0-9]*) # Input is atomic number
      get_element_by_atomic_number "$1"
      ;;
    [A-Z]) # Input is symbol
      get_element_by_symbol "$1"
      ;;
    [A-Z][a-z]) # Input is symbol
      get_element_by_symbol "$1"
      ;;
    *) # Input is name
      get_element_by_name "$1"
      ;;
  esac
fi