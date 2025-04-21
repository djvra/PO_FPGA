#define _POSIX_C_SOURCE 199309L
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <time.h>

#include <sys/time.h>
#include <sys/resource.h>

#include <unistd.h>
#include <time.h>
#include <limits.h>
#include <inttypes.h>
#include <float.h>

#define MAX_SIZE 1000
#define NUM_INPUTS 11

const long long MIN_39_BIT_SIGNED = -274877906944LL;  // -2^38
const long long MAX_39_BIT_SIGNED = 274877906943LL;   // 2^38 - 1

int read_file(int64_t *input_array, const char *file_path) {
    FILE *fp;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    int array_index = 0;

    fp = fopen(file_path, "r");
    if (fp == NULL) {
        printf("Couldn't find the file.\n");
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        // Stop reading if an empty line is encountered
        if (read == 1 && line[0] == '\n') {
            break;
        }

        double decimal = atof(line);
        input_array[array_index] = (int64_t)decimal;
        array_index++;

        // Stop if we reach max capacity
        if (array_index >= MAX_SIZE) {
            break;
        }
    }

    fclose(fp);
    free(line);

    return array_index;  // Return the number of elements read
}

// prints all data in the result array to a file
// lazim cunku fpga'deki veriyle karsilastiriyorum bunu
void dump_result_point_array(int64_t result_point[], int ROWS) {
    char filename[256] = "all_last_points.txt";

    FILE *fp = fopen(filename, "a");
    if (fp == NULL) {
        printf("Error opening the file %s", filename);
        return;
    }

    for (int i = 0; i < ROWS; i++) {
        fprintf(fp, "%" PRId64 " ", result_point[i]);
    }
    fprintf(fp, "\n");

    /*for(int j = 0; j < point_count; j++) {
        for (int i = 0; i < ROWS; i++) {
            fprintf(fp, "%d ", result_point[j][i]);
        }
        fprintf(fp, "\n");
    }*/

    fclose(fp);
}

void split_indexes(int* V_index, int* Uinv_index, int* Winv_index, int* q_index, int* s_index, int* o_index, int cone_start_index, int ROWS, int COLUMNS){
    *V_index = cone_start_index;
    *Uinv_index = *V_index + ROWS * COLUMNS;
    *Winv_index = *Uinv_index + ROWS * COLUMNS;
    *q_index = *Winv_index + ROWS * COLUMNS;
    *s_index = *q_index + COLUMNS;
    *o_index = *s_index + ROWS;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <ROWS> <file_path>\n", argv[0]);
        return 1;
    }

    int ROWS = atoi(argv[1]);
    int COLUMNS = ROWS;
    const char *file_path = argv[2];

    if (ROWS <= 0) {
        printf("Invalid size: %d\n", ROWS);
        return 1;
    }

    struct timespec start, end, elapsed;
    elapsed.tv_nsec = 0;
    elapsed.tv_sec = 0;
    clock_gettime(CLOCK_MONOTONIC, &start);

    /*
    struct tms start, end;
    clock_t start_time, end_time;
    long ticks_per_second = sysconf(_SC_CLK_TCK);
    start_time = times(&start);  // Record start time
    */

    struct timespec cpu_start, cpu_end, cpu_elapsed;
    cpu_elapsed.tv_nsec = 0;
    cpu_elapsed.tv_sec = 0;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &cpu_start);

    struct rusage usage_start, usage_end;
    getrusage(RUSAGE_SELF, &usage_start); // Start time

    // 8 bytes
    //printf("Size of long long int: %zu bytes\n", sizeof(long long int));

    //Decide how many elements need to read
    int each_cone_size = 3*ROWS*COLUMNS + COLUMNS + ROWS + COLUMNS;
    //printf("each_cone_size: %d\n", each_cone_size);
    //initialize the input array to read 3 matrices and 3 vectors

    //Read file
    int64_t *input_array = malloc(MAX_SIZE * sizeof(int64_t));
    if (input_array == NULL) {
        printf("Memory allocation failed.\n");
        return 1;
    }

    int input_array_size = read_file(input_array, file_path);
    //printf("input_array_size: %d\n", input_array_size);

    int number_of_cone = input_array_size / each_cone_size;
    //printf("number_of_cone: %d\n\n", number_of_cone);
    int cone_start_index = 0;

    //Split indexes: The file contains V, Uinv, Winv, q, s respectively. Use an only one matrix for the inputs and act them like a memory.
    //Memorize the start indexes of the matrices and the vectors in the input array.
    int V_index, Uinv_index, Winv_index, q_index, s_index, o_index;
    int point_count = 0;
    long long int total_point_count = 0;

    int64_t result_point[NUM_INPUTS] = {0};

    for(int each_cone = 0; each_cone < number_of_cone; each_cone++){
        split_indexes(&V_index, &Uinv_index, &Winv_index, &q_index, &s_index, &o_index, cone_start_index, ROWS, COLUMNS);
        //printf("%d\t%d\t%d\t%d\t%d\t%d\n", V_index, Uinv_index, Winv_index, q_index, s_index, o_index);

        int64_t prime_diagonals[NUM_INPUTS];
        int64_t q_summand[NUM_INPUTS] = {0};
        int64_t v_inner[NUM_INPUTS] = {0};
        int64_t q_hat[NUM_INPUTS] = {0};
        int64_t q_trans[NUM_INPUTS] = {0};
        int64_t q_int[NUM_INPUTS] = {0};

        int64_t last_diagonal = input_array[s_index + COLUMNS - 1];
        //printf("last_diagonal: %ld\n", last_diagonal);

        for(int i = 0 ; i < ROWS ; i++) {
            prime_diagonals[i] = last_diagonal / input_array[s_index+i];
            q_summand[i] = last_diagonal * input_array[q_index + i];
            for(int j = 0 ; j < COLUMNS ; j++){
                q_hat[i] = q_hat[i] + input_array[Uinv_index + i * ROWS + j] * input_array[q_index + j];
                input_array[Winv_index + j * COLUMNS + i] = input_array[Winv_index + j * COLUMNS + i] * prime_diagonals[i];
            }
        }

        /*for (int i = 0; i < ROWS; ++i) {
            printf("prime_diagonals[%d] = %ld\n", i, prime_diagonals[i]);
        }

        for (int i = 0; i < ROWS; ++i) {
            printf("q_summand[%d] = %ld\n", i, q_summand[i]);
        }

        for (int i = 0; i < ROWS; ++i) {
            printf("q_hat[%d] = %ld\n", i, q_hat[i]);
        }*/

        int temp_index = Winv_index;
        for(int i = 0 ; i < ROWS ; i++) {
            for(int j = 0 ; j < COLUMNS ; j++) {
                q_trans[i] = q_trans[i] + -1 * input_array[temp_index] * q_hat[j];
                ++temp_index;
                q_int[i] = q_trans[i];
            }
        }

        /*for (int i = 0 ; i < ROWS ; ++i) {
            printf("q_trans[%d] = %ld\n", i, q_trans[i]);
        }

        for (int i = 0 ; i < ROWS ; ++i) {
            printf("q_int[%d] = %ld\n", i, q_int[i]);
        }*/

        while (1) {
            int64_t inner_Res[NUM_INPUTS]={0};
            for(int i = 0 ; i < ROWS ; i++) {
                inner_Res[i] = q_int[i];

                for(int j = 0 ; j < COLUMNS ; j++){
                    inner_Res[i] = inner_Res[i]  + input_array[Winv_index + i * ROWS + j] * v_inner[j];
                }

                inner_Res[i] = inner_Res[i] % last_diagonal;

                if(inner_Res[i] < 0) {
                    inner_Res[i] = inner_Res[i] + last_diagonal;
                }
            }

            for(int i = 0 ; i < ROWS ; i++){
                int64_t outer = 0;
                for(int j = 0 ; j < COLUMNS ; j++){
                    outer = outer + input_array[V_index + i * ROWS + j] * inner_Res[j];
                }
                //result_point[point_count][i] = (outer + q_summand[i]) / last_diagonal;
                result_point[i] = (outer + q_summand[i]) / last_diagonal;
                printf("%u ", result_point[i]);
            }
            printf("\n");

            point_count += 1;
            total_point_count += 1;

            int i = ROWS-1;
            while(i >= 0) {
                if(v_inner[i] < input_array[s_index+i]-1) {
                    v_inner[i] = v_inner[i] + 1;
                    break;
                }
                v_inner[i] = 0;
                i-=1;
            }

            if(i == -1) {
                break;
            }

        } // end of while

        cone_start_index += each_cone_size;
    } // end of for

    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &cpu_end);
    cpu_elapsed.tv_sec += (cpu_end.tv_sec - cpu_start.tv_sec);
    cpu_elapsed.tv_nsec += (cpu_end.tv_nsec - cpu_start.tv_nsec);
    printf("CPU time: %lf\n", (double) cpu_elapsed.tv_sec + (double) cpu_elapsed.tv_nsec / 1e9);

    clock_gettime(CLOCK_MONOTONIC, &end);
    elapsed.tv_sec += (end.tv_sec - start.tv_sec);
    elapsed.tv_nsec += (end.tv_nsec - start.tv_nsec);
    printf("Total time: %lf\n", (double) elapsed.tv_sec + (double) elapsed.tv_nsec / 1e9);

    getrusage(RUSAGE_SELF, &usage_end); // End time

    // Compute elapsed user and system time in seconds
    /*double user_time = (usage_end.ru_utime.tv_sec - usage_start.ru_utime.tv_sec) +
                       (usage_end.ru_utime.tv_usec - usage_start.ru_utime.tv_usec) / 1e6;

    double system_time = (usage_end.ru_stime.tv_sec - usage_start.ru_stime.tv_sec) +
                         (usage_end.ru_stime.tv_usec - usage_start.ru_stime.tv_usec) / 1e6;

    // Print resource usage statistics
    printf("User CPU Time: %.6f sec\n", user_time);
    printf("System CPU Time: %.6f sec\n", system_time);*/
    printf("Voluntary Context Switches: %ld\n", usage_end.ru_nvcsw - usage_start.ru_nvcsw);
    printf("Involuntary Context Switches: %ld\n", usage_end.ru_nivcsw - usage_start.ru_nivcsw);
    printf("Page Reclaims Soft Page Faults: %ld\n", usage_end.ru_minflt - usage_start.ru_minflt);
    printf("Page Faults Hard Page Faults: %ld\n", usage_end.ru_majflt - usage_start.ru_majflt);
    printf("Swaps: %ld\n", usage_end.ru_nswap - usage_start.ru_nswap);
    printf("Block Input Operations: %ld\n", usage_end.ru_inblock - usage_start.ru_inblock);
    printf("Block Output Operations: %ld\n", usage_end.ru_oublock - usage_start.ru_oublock);
    printf("IPC Messages Sent: %ld\n", usage_end.ru_msgsnd - usage_start.ru_msgsnd);
    printf("IPC Messages Received: %ld\n", usage_end.ru_msgrcv - usage_start.ru_msgrcv);
    printf("Signals Received: %ld\n", usage_end.ru_nsignals - usage_start.ru_nsignals);
    //end_time = times(&end);  // Record end time

    // Calculate elapsed times in seconds
    /*double user_time = ((double) (end.tms_utime - start.tms_utime) / (double) ticks_per_second);
    double system_time = ((double) (end.tms_stime - start.tms_stime) / (double) ticks_per_second);
    double elapsed_real_time = ((double) (end_time - start_time) / (double) ticks_per_second);

    printf("User time: %.6lf sec\n", user_time);
    printf("System time: %.6lf sec\n", system_time);
    printf("Elapsed real time: %.6lf sec\n", elapsed_real_time);
*/
    printf("total point count: %lld\n", total_point_count);

    dump_result_point_array(result_point, ROWS);

    free(input_array);

    return 0;
}
