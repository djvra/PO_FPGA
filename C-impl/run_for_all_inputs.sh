#!/bin/bash

# Usage: ./modify_compile_run.sh

# Check if the required argument (COLUMNS value) is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <columns_value>"
    exit 1
fi

# Get the COLUMNS value from the command line argument
ROWS=$1

# Define the C file where #define ROWS, #define COLUMNS, and #define FILE_PATH are located
C_FILE="FundamentalParallelpiped_C_original.c"

# Exclude ROWS=5 and continue the script for other values
if [ "$ROWS" -eq 5 ]; then
    echo "Skipping ROWS=5"
    exit 0
fi

# Modify the C file's #define ROWS
sed -i "s/#define ROWS [0-9]*/#define ROWS $ROWS/" $C_FILE
echo "ROWS updated to $ROWS"

# Modify the C file's #define COLUMNS
sed -i "s/#define COLUMNS [0-9]*/#define COLUMNS $ROWS/" $C_FILE

# Modify the C file's #define FILE_PATH to reflect the current ROWS value
sed -i "s|#define FILE_PATH \".*\"|#define FILE_PATH \"input/data${ROWS}.txt\"|" $C_FILE

# Compile the program using the Makefile
make

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Compilation failed for ROWS=$ROWS"
    exit 1
fi

# Run the compiled program and save the output to a file
./program_original > "output/output_${ROWS}.txt"

# Check if the program executed successfully
if [ $? -ne 0 ]; then
    echo "Program execution failed for ROWS=$ROWS"
    exit 1
fi

echo "Program output for ROWS=$ROWS saved to output_${ROWS}.txt"
