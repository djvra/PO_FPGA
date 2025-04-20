import sys

username = "username"

def process_file(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            # Skip lines starting with //
            if line.strip().startswith('//'):
                continue
            # Reduce multiple whitespaces to a single space
            processed_line = ' '.join(line.split())
            # Check if the line contains only zero values
            if all(value == '0' for value in processed_line.split()):
                continue  # Skip lines with only zero values
            # Write to output file
            outfile.write(processed_line + '\n')

def compare_files(version_number, file_number):
    linux_file = f"C:/Users/{username}/Desktop/check_output/C_result_point_dump_{file_number}"
    windows_file = f"C:/Users/{username}/Desktop/mems/{file_number}.txt"

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
        print("Usage: check_output.py <version_number> <file_number>")
        sys.exit(1)

    try:
        # version_number = int(sys.argv[1])
        version_number = 13  # ise yaramiyor, ariza cikarmasin diye
        # file_number = int(sys.argv[2])
        file_number = sys.argv[1]
        mem_file = f"C:/Users/{username}/Desktop/mems/{file_number}.mem"
        output_file = f"C:/Users/{username}/Desktop/mems/{file_number}.txt"
        array_2d = process_file(mem_file, output_file)
        if compare_files(version_number, file_number):
            print("The files are the same.")
        else:
            print("The files are different.")
    except ValueError:
        print("The file number must be an integer.")
        sys.exit(1)