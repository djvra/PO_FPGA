
# Read first line of space-separated numbers and calculate average
"""
numbers = list(map(float, input("Enter numbers (space-separated): ").split()))
average1 = sum(numbers) / len(numbers)
print(f"Average: {average1:.6f}")
"""

# Read second line of space-separated hex numbers and calculate average
hex_numbers = list(map(lambda x: int(x, 16), input("Enter hex numbers (space-separated): ").split()))
average2 = sum(hex_numbers) / len(hex_numbers)
average2 = (average2*(1/(100*1000000)))
print(f"Average of hex numbers: {average2:.6f}")
