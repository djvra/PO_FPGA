#define _XOPEN_SOURCE 500
#define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64
#include <sys/types.h>
#include <unistd.h>

#include <stdio.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>

#define READ_COUNT 500 // Number of reads
#define WORD_SIZE 4

//#define _GNU_SOURCE

int main() {
    off64_t MEMORY_ADDRESS = 0x00000000C8000000;
    const char *mem_file = "/dev/mem";
    //uint32_t values[READ_COUNT]; // Array to store the read values
    uint32_t value;
    size_t size = sizeof(uint32_t); // Size of each read (4 bytes for uint32_t)
    // Open /dev/mem
    int fd = open(mem_file, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open /dev/mem");
        return EXIT_FAILURE;
    }
    // Perform 500 reads
    for (int i = 0; i < READ_COUNT; i++) {
        // Seek to the desired address
        off64_t ret_lseek = lseek64(fd, MEMORY_ADDRESS, SEEK_SET);
        printf("ret_lseek = %llx", ret_lseek);

        /*if (lseek64(fd, MEMORY_ADDRESS, SEEK_SET) == (off64_t)-1) {
            perror("Failed to seek to address");
            close(fd);
            return EXIT_FAILURE;
        }*/
        // Read the value at the address

        //if (read(fd, &values[i], size) != size) {
        if (read(fd, &value, size) < 0) {
            //printf("%d\n", i);
            perror("Failed to read from address");
            printf("errno: %d\n", errno);
            close(fd);
            return EXIT_FAILURE;
        }
    }

    // Perform reads using pread
    /* for (int i = 0; i < READ_COUNT; ++i) {
        ssize_t result = pread64(fd, &values[i], WORD_SIZE, MEMORY_ADDRESS);
        if (result != size) {
            if (result < 0) {
                perror("Failed to read from address");
            } else {
                fprintf(stderr, "Incomplete read: expected %ld bytes, got %ld bytes\n", size, result);
            }
            close(fd);
            return EXIT_FAILURE;
        }
    } */

    close(fd);

    // Print the values to the terminal
    printf("Values read from address 0x%LX:\n", MEMORY_ADDRESS);
    /*for (int i = 0; i < READ_COUNT; i++) {
        printf("[%d] 0x%08X\n", i, values[i]);
    }*/
    printf("0x%08X\n", value);
    return EXIT_SUCCESS;
}
