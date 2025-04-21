import sys

def float_to_int64_hex(f):
    """Convert a float to a 64-bit signed integer and return as hex."""
    value = int(f)
    if value < 0:
        value = (1 << 64) + value  # Convert to two's complement
    return format(value, '016x')  # 16 hex digits for 64-bit integer

def generate_mif(input_filename, output_filename='data.mif'):
    # Read the data from the input file
    with open(input_filename, 'r') as infile:
        data = [float(line.strip()) for line in infile if line.strip()]

    depth = len(data)
    
    with open(output_filename, 'w') as f:
        # Write MIF header with comments
        f.write(f"-- Generated from input file: {input_filename}\r\n")
        f.write("-- DEPTH specifies the number of words in the memory\r\n")
        f.write("-- WIDTH specifies the number of bits in each word\r\n")
        f.write(f"DEPTH = {depth};\r\n")
        f.write("WIDTH = 64;\r\n")
        f.write("ADDRESS_RADIX = DEC;\r\n")
        f.write("DATA_RADIX = HEX;\r\n")
        f.write("CONTENT\r\n")
        f.write("BEGIN\r\n")
        
        # Write data with comments
        for address, value in enumerate(data):
            hex_value = float_to_int64_hex(value)
            f.write(f"    {address} : {hex_value};\r\n")
        
        # Write MIF footer
        f.write("END;\r\n")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generate_mif.py <input_filename>")
        sys.exit(1)
    
    input_filename = sys.argv[1]
    generate_mif(input_filename)
