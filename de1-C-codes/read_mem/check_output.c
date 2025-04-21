#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// Function to check if two bytes have a difference of 1, considering wrap-around
bool byte_difference_with_wrap(unsigned char higher, unsigned char lower) {
    return ((higher == lower + 1) || (higher == 0x00 && lower == 0xFF));
}
// Function to check if the bytes in a number have a difference of 1
bool check_byte_difference(unsigned int number) {
    unsigned char b1 = (number >> 24) & 0xFF;
    unsigned char b2 = (number >> 16) & 0xFF;
    unsigned char b3 = (number >> 8) & 0xFF;
    unsigned char b4 = number & 0xFF;
    return byte_difference_with_wrap(b1, b2) &&
           byte_difference_with_wrap(b2, b3) &&
           byte_difference_with_wrap(b3, b4);
}
// Function to check if the least significant byte of the current number
// has a difference of 1 with the most significant byte of the previous number
bool check_line_difference(unsigned int prev, unsigned int curr) {
    unsigned char prev_last = (prev >> 24) & 0xFF;
    unsigned char curr_first = curr & 0xFF;
    return byte_difference_with_wrap(curr_first, prev_last);
}
int main() {
    FILE *file = fopen("output.txt", "r");
    if (!file) {
        perror("Error opening file");
        return EXIT_FAILURE;
    }
    char line[256];
    unsigned int prev_number = 0;
    unsigned int curr_number;
    bool is_first = true;
    while (fgets(line, sizeof(line), file)) {
        // Check if the line contains a hexadecimal number
        if (sscanf(line, "0x%X", &curr_number) == 1) {
            // Check byte difference rule
            if (!check_byte_difference(curr_number)) {
                printf("Error: Byte difference rule failed for number 0x%X\n", curr_number);
                fclose(file);
                return EXIT_FAILURE;
            }
            // Check line difference rule if this is not the first number
            if (!is_first && !check_line_difference(prev_number, curr_number)) {
                printf("Error: Line difference rule failed between 0x%X and 0x%X\n",
                       prev_number, curr_number);
                fclose(file);
                return EXIT_FAILURE;
            }
            // Update previous number and mark as no longer first
            prev_number = curr_number;
            is_first = false;
        }
    }
    fclose(file);
    printf("All numbers passed the checks.\n");
    return EXIT_SUCCESS;
}
