import os

def float_to_int32(val):
    # Convert a float to a signed 32-bit integer
    int32_val = int(val)
    # If the value is negative, extend the sign to 64 bits
    if int32_val < 0:
        int32_val = int32_val & 0xFFFFFFFF  # Ensure it's in 32-bit range
        return int32_val | 0xFFFFFFFF00000000  # Extend the sign to the upper 32 bits
    else:
        return int32_val & 0xFFFFFFFF  # For positive numbers, just mask to 32 bits

def process_file(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            try:
                # Convert each line to a float
                float_val = float(line.strip())
                # Convert the float to a 32-bit signed integer
                int32_val = float_to_int32(float_val)
                # Write the 32-bit integer as a 64-bit hexadecimal value with carriage return
                outfile.write(f'{int32_val:016x}\r\n')
            except ValueError as e:
                print(f"ValueError encountered: {e} in file {input_file}")

def process_directory(directory):
    # Create hex subdirectory if it doesn't exist
    hex_dir = os.path.join(directory, 'hex_yeni')
    os.makedirs(hex_dir, exist_ok=True)

    for filename in os.listdir(directory):
        # Check if the file name matches the pattern "dataX.txt"
        if filename.startswith('data') and filename.endswith('.txt'):
            input_file = os.path.join(directory, filename)
            output_file = os.path.join(hex_dir, f'{filename[:-4]}.hex')
            print(f'Processing {input_file} -> {output_file}')
            process_file(input_file, output_file)

# Example usage
process_directory('input')
