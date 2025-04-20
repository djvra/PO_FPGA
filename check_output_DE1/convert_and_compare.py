import sys
import os

username = "username"

def compare_files(c_output, fpga_output):
    with open(c_output, 'r') as c_f:
        c_lines = [line.strip() for line in c_f.readlines()]
    
    with open(fpga_output, 'r') as fpga_f:
        fpga_lines = [line.strip() for line in fpga_f.readlines()]
    
    total_diff_lines = 0
    missing_lines = []
    first_diff_line = None
    first_c_line = None
    first_fpga_line = None
    
    if len(c_lines) != len(fpga_lines):
        print(f"Mismatch in line count for {fpga_output}: C output has {len(c_lines)}, FPGA output has {len(fpga_lines)}")
    
    for i, (c_line, fpga_line) in enumerate(zip(c_lines, fpga_lines)):
        if c_line != fpga_line:
            total_diff_lines += 1
            if first_diff_line is None:
                first_diff_line = i + 1
                first_c_line = c_line
                first_fpga_line = fpga_line
    
    #if len(fpga_lines) < len(c_lines):
    #    missing_lines.extend(range(len(fpga_lines) + 1, len(c_lines) + 1))
    
    print(f"Results for {fpga_output}:")
    print(f"Total differing lines: {total_diff_lines}")
    print(f"Total missing lines: {len(missing_lines)}")
    if first_diff_line is not None:
        print(f"First differing line: {first_diff_line}")
        print(f"C Output: {first_c_line}")
        print(f"FPGA Output: {first_fpga_line}")

    for i in range(1, len(missing_lines)):
        if missing_lines[i] - missing_lines[i-1] > 1:
            print("-> conditions do not met, exiting")
            exit() 

    if missing_lines:
        print("Missing line numbers:", missing_lines)
    print("---------------------------")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: convert_and_compare.py <file_number>")
        sys.exit(1)
    
    try:
        file_number = sys.argv[1]
        c_output = f"C:/Users/{username}/Desktop/check_output_DE1/{file_number}.txt"
        
        # Collect all FPGA output files with format {file_number}_{output_number}.txt
        output_dir = f"E:/output_DE1/{file_number}/"
        
        output_number = 0
        while True:
            fpga_output = os.path.join(output_dir, f"{file_number}_{output_number}.txt")
            if os.path.exists(fpga_output):
                compare_files(c_output, fpga_output)
                output_number += 1
            else:
                break
        
        if output_number == 0:
            print("No FPGA output files found.")
            sys.exit(1)
    except ValueError:
        print("The file number must be an integer.")
        sys.exit(1)
