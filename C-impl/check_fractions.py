import re

def check_for_fractions(file_path):
    # Regex pattern to match floating point numbers in the file
    pattern = re.compile(r'[-+]?\d*\.\d+')

    with open(file_path, 'r') as file:
        for line in file:
            # Find all floating-point numbers in the line
            numbers = pattern.findall(line)
            for num_str in numbers:
                num = float(num_str)
                # Check if the fractional part is non-zero
                if num != int(num):
                    print(f"{num_str} has a fractional part")

# Call the function with the path to your file
check_for_fractions("output_original.txt")
