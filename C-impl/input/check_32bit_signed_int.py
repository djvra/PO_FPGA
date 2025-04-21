import sys

def check_32bit_signed_int(filename):
    min_int32 = -2147483648
    max_int32 = 2147483647
    
    with open(filename, 'r') as file:
        for line in file:
            try:
                num = float(line.strip())
                if num < min_int32 or num > max_int32:
                    print(f"{num} does not fit in a 32-bit signed integer")
            except ValueError:
                print(f"Invalid number: {line.strip()}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python check_32bit_signed_int.py <filename>")
        sys.exit(1)
    
    filename = sys.argv[1]
    check_32bit_signed_int(filename)
