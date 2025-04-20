import re
import sys

username = "username"

def intel_hex_to_decimal_2d_array(intel_hex_file):
    # Extract row and column number from the file name
    match = re.search(r'(\d+)', intel_hex_file)
    if not match:
        print("Invalid file name format. Expected format: 'RSLT<number>'.")
        return

    # Get the row/column number from the file name
    size = int(match.group(1))

    # Initialize a 2D array
    array_2d = []

    with open(intel_hex_file, 'r') as infile:
        row = []
        for line in infile:
            if line.startswith(":"):
                byte_count = int(line[1:3], 16)
                record_type = line[7:9]

                # Only process data records (type '00')
                if record_type == "00":
                    data = line[9:9 + 2 * byte_count]

                    # Convert each 2-byte hex to decimal
                    for i in range(0, len(data), 8):  # Process 32 bits (8 hex digits) at a time
                        decimal_value = int(data[i:i + 8], 16)
                        row.append(decimal_value)

                        if len(row) == size:  # Once the row reaches the specified column size
                            # Check if the row is all zeros
                            if all(value == 0 for value in row):
                                return array_2d  # Stop processing if the row is all zeros
                            array_2d.append(row)
                            row = []  # Start a new row

    return array_2d

def write_decimal_2d_array_to_file(array_2d, output_file):
    with open(output_file, 'w') as outfile:
        for row in array_2d:
            outfile.write(" ".join(map(str, row)) + "\n")

    print(f"Converted Intel HEX to a 2D decimal array and saved to {output_file} successfully.")

def compare_files(version_number, file_number):
    
    linux_file = f"C:/Users/{username}/Desktop/check_output/C_result_point_dump_{file_number}"
    windows_file = f"C:/Users/{username}/Desktop/check_output/{file_number}_DECIMAL.txt"
    
    with open(linux_file, 'r') as linux_f, open(windows_file, 'r') as windows_f:
        linux_lines = [line.strip() for line in linux_f.readlines()]
        windows_lines = [line.strip() for line in windows_f.readlines()]
    
    if len(linux_lines) != len(windows_lines):
        print("Files have different numbers of lines.")
        return False

    for i, (linux_line, windows_line) in enumerate(zip(linux_lines, windows_lines)):
        if linux_line != windows_line:
            print(f"Difference found on line {i + 1}:")
            print(f"Linux file:    {linux_line}")
            print(f"Windows file:  {windows_line}")
            return False
    
    print("Files are identical.")
    return True

if __name__ == "__main__":

    if len(sys.argv) != 2:
        print("Usage: intel_hex_to_decimal.py <version_number> <file_number>")
        sys.exit(1)

    try:
        #version_number = int(sys.argv[1])
        version_number = 13 # ise yaramiyor, ariza cikarmasin diye
        #file_number = int(sys.argv[2])
        file_number = sys.argv[1]
        intel_hex_file = f"C:/Users/{username}/Desktop/check_output/{file_number}.hex"
        output_file = f"C:/Users/{username}/Desktop/check_output/{file_number}_DECIMAL.txt"
        array_2d = intel_hex_to_decimal_2d_array(intel_hex_file)
        if array_2d:
            write_decimal_2d_array_to_file(array_2d, output_file)
        if compare_files(version_number, file_number):
            print("The files are the same.")
        else:
            print("The files are different.")
    except ValueError:
        print("The file number must be an integer.")
        sys.exit(1)
