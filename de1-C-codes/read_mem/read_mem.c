
#define _POSIX_C_SOURCE 199309L  // Needed for nanosleep()

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>
#include <signal.h>
#include <string.h>

#define NUMBER_OF_WORDS 2079991

#define HW_REG_BASE 0xC8000000 // FPGA On-Chip Memory start address
#define HW_REG_SPAN 0x00000030 // Read 48 bytes

#define PIO_BASE_ADDR 0x00000000  // Base address of PIO
#define PIO_SPAN 0x0000000C  // 12 words

enum { NS_PER_SECOND = 1000000000 };

unsigned long ctr = 0;
uint32_t words_per_point;

void sub_timespec(struct timespec t1, struct timespec t2, struct timespec *td) {
    td->tv_nsec = t2.tv_nsec - t1.tv_nsec;
    td->tv_sec  = t2.tv_sec - t1.tv_sec;
    if (td->tv_sec > 0 && td->tv_nsec < 0) {
        td->tv_nsec += NS_PER_SECOND;
        td->tv_sec--;
    } else if (td->tv_sec < 0 && td->tv_nsec > 0) {
        td->tv_nsec -= NS_PER_SECOND;
        td->tv_sec++;
    }
}

const char *filename = "output.txt";
volatile bool keep_running = true;

void handle_sigint(int sig) {
    keep_running = false;
}

void write_to_file(uint32_t* arr, int dimension, int n, FILE* output_file) {

        /*FILE *output_file = fopen(filename, "a");
        if (!output_file) {
                perror("Error opening file for writing");
        //munmap(virtual_base, HW_REG_SPAN);
        //close(fd);
        //return 1;
                exit(1);
        }*/
        printf("Writing to file...\n");
    //int i = 1;
        //int d = 0;
        uint8_t bytes[12] = {0};
    //uint8_t last_byte = 255;
        uint32_t word0 = 0;
        uint32_t word1 = 0;
        uint32_t word2 = 0;

    //while (arr[i] != 0x00000000 && arr[i] != 0xFFFFFFFF) {
        for (int i = 1; i < n; i += words_per_point) {
                word0 = arr[i];
                word1 = arr[i+1];
                word2 = arr[i+2];

                bytes[0] = (word0 & 0xFF);          // Least significant byte
                bytes[1] = (word0 >> 8) & 0xFF;    // Second byte
                bytes[2] = (word0 >> 16) & 0xFF;   // Third byte
                bytes[3] = (word0 >> 24) & 0xFF;   // Most

                bytes[4] = (word1 & 0xFF);          // Least significant byte
                bytes[5] = (word1 >> 8) & 0xFF;    // Second byte
                bytes[6] = (word1 >> 16) & 0xFF;   // Third byte
                bytes[7] = (word1 >> 24) & 0xFF;

                bytes[8] = (word2 & 0xFF);          // Least significant byte
                bytes[9] = (word2 >> 8) & 0xFF;    // Second byte
                bytes[10] = (word2 >> 16) & 0xFF;   // Third byte
                bytes[11] = (word2 >> 24) & 0xFF;

                fprintf(output_file, "%" PRIu8, bytes[0]);
                for (int j = 1; j < dimension; ++j) {
                        fprintf(output_file, " %" PRIu8, bytes[j]);
                }
                fprintf(output_file, "\n");
                /*for (int j = 0; j < 4; ++j) {
                ++d;
                if (d == dimension) {
                    fprintf(output_file, "%" PRIu8 "\n", bytes[j]);
                    d = 0;
                    break;
                } else {
                    fprintf(output_file, "%" PRIu8 " ", bytes[j]);
                }*/
            //printf("d: %d ", d);
        }
//      fclose(output_file);
        printf("Write complete.\n");
} // end of the functoion

int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Usage: ./read_mem <dimension>\n");
        exit(1);
    }

    char* a = argv[1];
    int dimension = atoi(a);
    if (dimension < 2 || dimension > 11) {
        printf("Dimension value must be in the range [2,11].\n");
        return 1;
    } else {
        printf("Dimension is %d.\n", dimension);
    }

    if (remove(filename) == 0) {
        printf("File '%s' removed successfully.\n", filename);
    } else {
        printf("File '%s' does not exist or cannot be removed.\n", filename);
    }

        if (dimension < 5) {
                words_per_point = 1;
        } else if (dimension < 9) {
                words_per_point = 2;
        } else {
                words_per_point = 3;
        }

    /*char format[256] = "";
    for (int i = 0; i < dimension; i++) {
        sprintf(format + strlen(format), "%%d%s", (i == dimension - 1) ? "\n" : " ");
    }*/

    int fd;
    void* virtual_base;
    volatile uint32_t* pio_input;

    signal(SIGINT, handle_sigint);

    // Open /dev/mem to access physical memory
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("Error opening /dev/mem");
        return 1;
    }

    printf("Mapping memory...\n");

    // Map the Avalon memory space into user space
    virtual_base = mmap(NULL, HW_REG_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, HW_REG_BASE);
    if (virtual_base == MAP_FAILED) {
        perror("Error mapping memory");
        close(fd);
        return 1;
    }

    printf("Memory mapped.\n");

    printf("Virtual Base Address: %p\n", virtual_base);

    // Access the memory region
    pio_input = (volatile uint32_t *)(virtual_base);

    FILE *output_file = fopen(filename, "a");
    if (!output_file) {
        perror("Error opening file for writing");
        munmap(virtual_base, HW_REG_SPAN);
        close(fd);
        return 1;
    }

        //uint32_t arr[NUMBER_OF_WORDS] = {0};
        uint32_t arr[2000] = {0};
        volatile uint32_t* word0 = (pio_input); // Read 32-bit word
        volatile uint32_t* word1 = (pio_input + 4);
        //volatile uint32_t* word2 = (pio_input + 2);
        //volatile uint32_t* word3 = (pio_input + 3);

        arr[0] = 0;
        arr[1] = 0;

        uint32_t temp_word0 = 0;
        uint32_t old_word = 0;
        //uint32_t temp_word3 = 0;
        uint32_t i = 1;
        *word1 = 0;

        uint64_t word_ctr = 0;

        struct timespec start, end, elapsed;
        elapsed.tv_nsec = 0;
        elapsed.tv_sec = 0;

        clock_gettime(CLOCK_MONOTONIC, &start);

        while (keep_running) {
                /*if (i == NUMBER_OF_WORDS) {
                        printf("arr is full: %d\n", i);
                        clock_gettime(CLOCK_MONOTONIC, &start);
                        write_to_file(arr, dimension, i, output_file);
                        clock_gettime(CLOCK_MONOTONIC, &end);
                        elapsed.tv_sec += (end.tv_sec - start.tv_sec);
                        elapsed.tv_nsec += (end.tv_nsec - start.tv_nsec);
                        arr[i] = 0x00000000;
                        i = 1;
                }*/

                temp_word0 = *(word0);

                if (temp_word0 == 0xFFFFFFFF) {
                        *word1 = 1;
                        *word1 = 0;
                        /*printf("0xFFFFFFFF received i: %d\n", i);
                        arr[i] = 0xFFFFFFFF;
                        clock_gettime(CLOCK_MONOTONIC, &start);
                        write_to_file(arr, dimension, i, output_file);
                        clock_gettime(CLOCK_MONOTONIC, &end);
                        elapsed.tv_sec += (end.tv_sec - start.tv_sec);
                        elapsed.tv_nsec += (end.tv_nsec - start.tv_nsec);
                        printf("Write time: %lf\n", elapsed.tv_sec + elapsed.tv_nsec / 1e9);
                        exit(0);*/
                        break;
                }

                else if (temp_word0 != 0x00000000 /*&& temp_word0 != old_word*/ /*&& temp_word0 != arr[i-1]*/) {
                //if (temp_word3 == 0xFCFCFCFC || temp_word3 != 0) {
                        //arr[i] = temp_word0;
                        *word1 = 1;
                        //old_word = temp_word0;
                        //arr[i] = temp_word0;
                        *word1 = 0;
                        //printf("%x ", temp_word0);
                        ++word_ctr;
                        //i+=1;
                        //if (i == 2000) break;
                }

                //arr[i]   = temp_word0;
                // *(word3) = 0x00000000;
                //arr[i+1] = *(word3);
                //arr[i+1] = *(word1);
                //arr[i+2] = *(word2);
                //arr[i+3] = *(word3);
                //i+=2;
        }

        clock_gettime(CLOCK_MONOTONIC, &end);
        elapsed.tv_sec += (end.tv_sec - start.tv_sec);
        elapsed.tv_nsec += (end.tv_nsec - start.tv_nsec);
        //elapsed /= 100000000.0;
        printf("Write time: %lf\n", elapsed.tv_sec + elapsed.tv_nsec / 1e9);

        //printf("ctr: %ld\n", ctr);

    // Clean up and close

        //for (i = 0; i < 2000; ++i) printf("%d: %x\n", i, arr[i]);

        printf("word count: %" PRIu64 "\npoint count: %" PRIu64 "\n", word_ctr, word_ctr/words_per_point);

        fclose(output_file);

        if (munmap(virtual_base, HW_REG_SPAN) != 0) {
                printf("ERROR: Failed to munmap\n");
        } else {
                printf("Memory unmapped.\n");
        }

        close(fd);

        return 0;
}
