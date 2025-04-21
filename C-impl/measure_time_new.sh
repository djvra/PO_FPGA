#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Usage: $0 <program_name> <dimension> <file_name> [runs]"
    exit 1
fi

program="./$1"
dimension="$2"
file_name="$3"
runs=${4:-100}   # Get the number of runs from the command line, default is 100

# Initialize sum variables
total_cpu_time=0
total_time=0
total_vol_ctx_switches=0
total_invol_ctx_switches=0
total_page_reclaims=0
total_page_faults=0
total_swaps=0
total_blk_in_ops=0
total_blk_out_ops=0
total_ipc_sent=0
total_ipc_received=0
total_signals=0
total_point_count=0

for i in $(seq 1 $runs); do
    sudo sync
    sudo sysctl vm.drop_caches=3 >/dev/null # Clear caches before each run
    output=$($program "$dimension" "$file_name")

    # Extract values from output
    cpu_time=$(echo "$output" | awk '/CPU time:/ {print $3}')
    total_exec_time=$(echo "$output" | awk '/Total time:/ {print $3}')
    vol_ctx_switches=$(echo "$output" | awk '/Voluntary Context Switches:/ {print $4}')
    invol_ctx_switches=$(echo "$output" | awk '/Involuntary Context Switches:/ {print $4}')
    page_reclaims=$(echo "$output" | awk '/Page Reclaims Soft Page Faults:/ {print $6}')
    page_faults=$(echo "$output" | awk '/Page Faults Hard Page Faults:/ {print $6}')
    swaps=$(echo "$output" | awk '/Swaps:/ {print $2}')
    blk_in_ops=$(echo "$output" | awk '/Block Input Operations:/ {print$4}')
    blk_out_ops=$(echo "$output" | awk '/Block Output Operations:/ {print $4}')
    ipc_sent=$(echo "$output" | awk '/IPC Messages Sent:/ {print $4}')
    ipc_received=$(echo "$output" | awk '/IPC Messages Received:/ {print $4}')
    signals=$(echo "$output" | awk '/Signals Received:/ {print $3}')
    point_count=$(echo "$output" | awk '/total point count:/ {print $4}')

    # Accumulate values
    total_cpu_time=$(echo "$total_cpu_time + $cpu_time" | bc)
    total_time=$(echo "$total_time + $total_exec_time" | bc)
    total_vol_ctx_switches=$(echo "$total_vol_ctx_switches + $vol_ctx_switches" | bc)
    total_invol_ctx_switches=$(echo "$total_invol_ctx_switches + $invol_ctx_switches" | bc)
    total_page_reclaims=$(echo "$total_page_reclaims + $page_reclaims" | bc)
    total_page_faults=$(echo "$total_page_faults + $page_faults" | bc)
    total_swaps=$(echo "$total_swaps + $swaps" | bc)
    total_blk_in_ops=$(echo "$total_blk_in_ops + $blk_in_ops" | bc)
    total_blk_out_ops=$(echo "$total_blk_out_ops + $blk_out_ops" | bc)
    total_ipc_sent=$(echo "$total_ipc_sent + $ipc_sent" | bc)
    total_ipc_received=$(echo "$total_ipc_received + $ipc_received" | bc)
    total_signals=$(echo "$total_signals + $signals" | bc)
    total_point_count=$(echo "$total_point_count + $point_count" | bc)

    echo "CPU Time: $cpu_time, Total Time: $total_exec_time, VCS: $vol_ctx_switches, PR: $page_reclaims"
    #echo "Run $i complete."
done

# Compute Averages
average_cpu_time=$(echo "scale=6; $total_cpu_time / $runs" | bc)
average_time=$(echo "scale=6; $total_time / $runs" | bc)
average_vol_ctx_switches=$(echo "scale=6; $total_vol_ctx_switches / $runs" | bc)
average_invol_ctx_switches=$(echo "scale=6; $total_invol_ctx_switches / $runs" | bc)
average_page_reclaims=$(echo "scale=6; $total_page_reclaims / $runs" | bc)
average_page_faults=$(echo "scale=6; $total_page_faults / $runs" | bc)
average_swaps=$(echo "scale=6; $total_swaps / $runs" | bc)
average_blk_in_ops=$(echo "scale=6; $total_blk_in_ops / $runs" | bc)
average_blk_out_ops=$(echo "scale=6; $total_blk_out_ops / $runs" | bc)
average_ipc_sent=$(echo "scale=6; $total_ipc_sent / $runs" | bc)
average_ipc_received=$(echo "scale=6; $total_ipc_received / $runs" | bc)
average_signals=$(echo "scale=6; $total_signals / $runs" | bc)
average_point_count=$(echo "scale=6; $total_point_count / $runs" | bc)

# Print Results
echo "===== Average Metrics Over $runs Runs ====="
echo "Average CPU Time: $average_cpu_time sec"
echo "Average Total Time: $average_time sec"
echo "Average Voluntary Context Switches: $average_vol_ctx_switches"
echo "Average Involuntary Context Switches: $average_invol_ctx_switches"
echo "Average Page Reclaims (Soft Page Faults): $average_page_reclaims"
echo "Average Page Faults (Hard Page Faults): $average_page_faults"
echo "Average Swaps: $average_swaps"
echo "Average Block Input Operations: $average_blk_in_ops"
echo "Average Block Output Operations: $average_blk_out_ops"
echo "Average IPC Messages Sent: $average_ipc_sent"
echo "Average IPC Messages Received: $average_ipc_received"
echo "Average Signals Received: $average_signals"
echo "Average Total Point Count: $average_point_count"

