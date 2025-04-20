import sys
import os

username = "username"

def find_consecutive_missing_lines(file1, file2, output_number, threshold=1):
    """
    Compares file1 and file2 line by line and reports if there are consecutive missing lines
    in file2 that exceed the given threshold.
    
    Args:
        file1 (str): Path to the original file.
        file2 (str): Path to the file that may have missing lines.
        threshold (int): Minimum number of consecutive missing lines to report.
    """
    with open(file1, 'r', encoding='utf-8') as f1, open(file2, 'r', encoding='utf-8') as f2:
        lines1 = f1.readlines()
        lines2 = f2.readlines()

    index1, index2 = 0, 0
    missing_lines = []

    while index1 < len(lines1):
        if index2 < len(lines2) and lines1[index1] == lines2[index2]:
            index2 += 1  # Match found, move to the next line in both files
        else:
            missing_lines.append((index1, lines1[index1].strip()))  # Record missing line
        
        index1 += 1  # Always move to the next line in file1

    # Check for consecutive missing lines
    consecutive_missing = []
    for i in range(len(missing_lines)):
        if i == 0 or missing_lines[i][0] == missing_lines[i - 1][0] + 1:
            consecutive_missing.append(missing_lines[i])
        else:
            if len(consecutive_missing) > threshold:
                print(f"Consecutive missing lines detected at output file {output_number}:")
                for idx, line in consecutive_missing:
                    print(f"Line {idx + 1}: {line}")
                print("-" * 50)
            consecutive_missing = [missing_lines[i]]

    # Check the last batch
    if len(consecutive_missing) > threshold:
        print("Consecutive missing lines detected:")
        for idx, line in consecutive_missing:
            print(f"Line {idx + 1}: {line}")
        print("-" * 50)

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
                find_consecutive_missing_lines(c_output, fpga_output, output_number, threshold=1)
                output_number += 1
            else:
                break
        
        if output_number == 0:
            print("No FPGA output files found.")
            sys.exit(1)
    except ValueError:
        print("The file number must be an integer.")
        sys.exit(1)