#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <program_name>"
    exit 1
fi

program="./$1"  # Get the program name from command-line

# Initialize accumulators
total_time=0
total_voluntary=0
total_involuntary=0
total_major_faults=0
total_cpu=0  # New: CPU usage accumulator

for i in {1..100}; do
    sudo sysctl vm.drop_caches=3 >/dev/null  # Clear cache before each run
    
    output=$(sudo /usr/bin/time --verbose $program 2>&1)  # Run the program and capture stderr

    # Extract 'Total time' from program output
    time_value=$(echo "$output" | grep -oP "Total time: \K[0-9]+\.[0-9]+")

    # Extract performance metrics
    voluntary=$(echo "$output" | grep "Voluntary context switches:" | awk '{print $NF}')
    involuntary=$(echo "$output" | grep "Involuntary context switches:" | awk '{print $NF}')
    major_faults=$(echo "$output" | grep "Major (requiring I/O) page faults:" | awk '{print $NF}')
    cpu_percent=$(echo "$output" | grep "Percent of CPU this job got:" | awk '{print $NF}' | tr -d '%')
    
    # Ensure values are numeric, default to 0 if empty
    [[ "$time_value" =~ ^[0-9]+\.[0-9]+$ ]] || time_value=0
    [[ "$voluntary" =~ ^[0-9]+$ ]] || voluntary=0
    [[ "$involuntary" =~ ^[0-9]+$ ]] || involuntary=0
    [[ "$major_faults" =~ ^[0-9]+$ ]] || major_faults=0
    [[ "$cpu_percent" =~ ^[0-9]+(\.[0-9]+)?$ ]] || cpu_percent=0  # Support decimals

    # Sum values
    total_time=$(echo "$total_time + $time_value" | bc)
    total_voluntary=$((total_voluntary + voluntary))
    total_involuntary=$((total_involuntary + involuntary))
    total_major_faults=$((total_major_faults + major_faults))
    total_cpu=$(echo "$total_cpu + $cpu_percent" | bc)  # Sum CPU percentage
    
    echo "Run $i: Time=${time_value}s, CPU=${cpu_percent}%, Voluntary=$voluntary, Involuntary=$involuntary, Major Faults=$major_faults"
done

# Compute averages
avg_time=$(echo "scale=6; $total_time / 100" | bc)

avg_cpu=$(echo "scale=2; $total_cpu / 100" | bc)  # Average CPU usage
avg_voluntary=$(echo "scale=2; $total_voluntary / 100" | bc)
avg_involuntary=$(echo "scale=2; $total_involuntary / 100" | bc)
avg_major_faults=$(echo "scale=2; $total_major_faults / 100" | bc)

echo "-----------------------------"
echo "Average Execution Time: ${avg_time}s"
echo "Average CPU Usage: ${avg_cpu}%"
echo "Average Voluntary Context Switches: $avg_voluntary"
echo "Average Involuntary Context Switches: $avg_involuntary"
echo "Average Major Page Faults: $avg_major_faults"
