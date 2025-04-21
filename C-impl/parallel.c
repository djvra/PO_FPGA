#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <limits.h>

#define ROWS 6
#define COLUMNS 6
#define FILE_PATH "input/data6_yeni.txt"
#define MAX_SIZE 1000

/*
v1: All points are written to the same file
v2: Each 1000 points are written to the same file
v3: Each 1000 points are written to a new file
v4: Each 500 points are written to the same file
v5: Each 2000 points are written to the same file
*/

int read_file(__int128_t input_array[]){
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    int array_index = 0;

    fp = fopen(FILE_PATH, "r");
    if (fp == NULL){
        printf("Couldnt find the file.\n");
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        double decimal = atof(line);
        input_array[array_index] = (__int128_t) decimal;
        array_index++;

    }

    fclose(fp);
    if (line)
        free(line);

    return array_index;

}

/*void write_point_to_file1(int point[]){
    char *filename ;
    sprintf(filename, "C_result_%d", COLUMNS);

    // open the file for writing
    FILE *fp = fopen(filename, "a");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return -1;
    }
    // write to the text file
    for (int i = 0; i < ROWS; i++)
        fprintf(fp, "%d, ", point[i]);
    fprintf(fp, "\n");

    // close the file
    fclose(fp);

    return;
}*///Tüm pointleri bir anda aynı dosyaya yazdıran fonksiyon

char* int128_to_string(__int128_t num) {
    // Buffer large enough to hold 128-bit integer string, plus sign and null terminator
    char buffer[50];
    
    if (num == 0) {
        char *zero = calloc(2, sizeof(char));
        zero[0] = '0';
        zero[1] = '\0';
        return zero;
    }

    // Check if the number is negative
    __int128_t temp = num;
    int is_negative = 0;
    if (temp < 0) {
        is_negative = 1;
        temp = -temp;
    }

    // Write the number into buffer
    int i = sizeof(buffer) - 1;
    buffer[i] = '\0';

    // Convert the number to string
    while (temp > 0) {
        buffer[--i] = (char)((temp % 10) + '0');
        temp /= 10;
    }

    // Add negative sign if needed
    if (is_negative) {
        buffer[--i] = '-';
    }

    // Allocate memory for the final string and copy from the buffer
    char *result = calloc(sizeof(buffer) - i, sizeof(char));
    if (!result) return NULL;  // Handle memory allocation failure

    // Copy the number to the result string
    strcpy(result, &buffer[i]);

    return result;
}

void write_point_to_file(__int128_t point[][ROWS], int point_count){
    char filename[256];
    sprintf(filename, "C_result_%d", COLUMNS);

    // open the file for writing
    FILE *fp = fopen(filename, "a");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return;
    }
    // write to the text file
    for(int j = 0; j < point_count; j++){
        for (int i = 0; i < ROWS; i++) {
            char* str = int128_to_string(point[j][i]);
            fprintf(fp, "%s, ", str);
            free(str);
        }
        fprintf(fp, "\n");
    }
    

    // close the file
    fclose(fp);

    return;
} //her 500-1000 pointte aynı dosyaya yazan fonksiyon

void write_point_to_file_decimal(int result_point[][ROWS], int point_count) {
    char filename[256];
    sprintf(filename, "C_result_decimal_%d", COLUMNS);

    // open the file for writing
    FILE *fp = fopen(filename, "a");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return;
    }
    // write to the text file
    for(int j = 0; j < point_count; j++){
        for (int i = 0; i < ROWS; i++) {
            fprintf(fp, "%d ", result_point[j][i]);
        }
        fprintf(fp, "\n");
    }
    
    // close the file
    fclose(fp);

    return;
}

// prints all data in the result array to a file
// lazim cunku fpga'deki veriyle karsilastiriyorum bunu
void dump_result_point_array(int result_point[][ROWS], int point_count) {
    char filename[256];
    sprintf(filename, "C_result_point_dump_%d", COLUMNS);

    FILE *fp = fopen(filename, "w");
    if (fp == NULL) {
        printf("Error opening the file %s", filename);
        return;
    }

    for(int j = 0; j < point_count; j++) {
        for (int i = 0; i < ROWS; i++) {
            fprintf(fp, "%d ", result_point[j][i]);
        }
        fprintf(fp, "\n");
    }
    
    fclose(fp);
}

/*void write_point_to_file(int point[][ROWS], int point_count, int write_count){
    char *filename ;
    sprintf(filename, "C_result_%d_%d", write_count, COLUMNS);

    // open the file for writing
    FILE *fp = fopen(filename, "w");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return -1;
    }
    // write to the text file
    for(int j = 0; j < point_count; j++){
        for (int i = 0; i < ROWS; i++)
            fprintf(fp, "%d, ", point[j][i]);
        fprintf(fp, "\n");
    }
    

    // close the file
    fclose(fp);

    return;
}//her 1000 pointte yeni bir dosyaya yazdıran fonksiyon*/

void write_computational_time(double time_spent, double computational_time_taken, double io_time_taken, long long int point_count){

    char* filename = "PO_computation_times_v4.txt";
    // open the file for writing
    FILE *fp = fopen(filename, "a");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return;
    }

    fprintf(fp, "Dimension: %d\ttotal time: %lf\tcomputational time: %lf\tI/O time: %lf\tpoints:%lld\n", ROWS, time_spent, computational_time_taken, io_time_taken, point_count);

    // close the file
    fclose(fp);

    return;
}

void split_indexes(int* V_index, int* Uinv_index, int* Winv_index, int* q_index, int* s_index, int* o_index, int cone_start_index){
    *V_index = cone_start_index;
    *Uinv_index = *V_index + ROWS * COLUMNS;
    *Winv_index = *Uinv_index + ROWS * COLUMNS;
    *q_index = *Winv_index + ROWS * COLUMNS;
    *s_index = *q_index + COLUMNS; 
    *o_index = *s_index + ROWS;
}

long long int get_floor(double number){
    double number_frac = number - (long long int)number;
    if(number_frac == 0.0) return (long long int)number;
    else if(number_frac <= -0.5 || number_frac <= 0.5)
        return (long long int)number-1;
    else if(number_frac > -0.5 || number_frac > 0.5)
        return (long long int)number+1;
    else
        return (long long int)number;
}

void print_int128(__int128_t num) {
    char buffer[50];  // Buffer large enough to hold 128-bit integer string

    if (num == 0) {
        putchar('0');
        return;
    }

    // Check if the number is negative
    __int128_t temp = num;
    if (temp < 0) {
        putchar('-');
        temp = -temp;
    }

    // Write the number into buffer
    int i = sizeof(buffer) - 1;
    buffer[i] = '\0';

    // Convert the number to string
    while (temp > 0) {
        buffer[--i] = (temp % 10) + '0';
        temp /= 10;
    }

    // Print the result
    printf("%s ", &buffer[i]);
}

void check_long_long_range(__int128_t num) {
    if (num > LLONG_MAX) {
        printf("The number exceeds the maximum value for signed long long int.\n");
    } else if (num < LLONG_MIN) {
        printf("The number exceeds the minimum value for signed long long int.\n");
    } /*else {
        printf("The number is within the range of signed long long int.\n");
    }*/
}

void check_int_range(long long int num) {    
    const long long MIN_32_BIT_SIGNED = -2147483648;
    const long long MAX_32_BIT_SIGNED = 2147483647;

    if (num > MAX_32_BIT_SIGNED || num < MIN_32_BIT_SIGNED) {
        printf("The number %lld is outside the 32-bit signed integer range.\n", num);
    }
}

void check_40bit_signed_range(long long int num) {
    /*const long long MIN_40_BIT_SIGNED = -549755813888LL;  // -2^39
    const long long MAX_40_BIT_SIGNED = 549755813887LL;   // 2^39 - 1

    // Check if the number is outside the 40-bit signed integer range
    if (num > MAX_40_BIT_SIGNED || num < MIN_40_BIT_SIGNED) {
        printf("The number %lld is outside the 40-bit signed integer range.\n", num);
    } */

    const long long MIN_39_BIT_SIGNED = -274877906944LL;  // -2^38
    const long long MAX_39_BIT_SIGNED = 274877906943LL;   // 2^38 - 1

    // Check if the number is outside the 39-bit signed integer range
    if (num > MAX_39_BIT_SIGNED || num < MIN_39_BIT_SIGNED) {
        printf("The number %lld is outside the 39-bit signed integer range.\n", num);
    } 
}

void check_short_int_range(long long int num) {
    const long long MIN_16_BIT_SIGNED = -32768;
    const long long MAX_16_BIT_SIGNED = 32767;

    if (num > MAX_16_BIT_SIGNED || num < MIN_16_BIT_SIGNED) {
        printf("The number %lld is outside the 16-bit signed short integer range.\n", num);
    }
}



int main(void)
{
    // 8 bytes
    //printf("Size of long long int: %zu bytes\n", sizeof(long long int));

    //Decide how many elements need to read
    int each_cone_size = 3*ROWS*COLUMNS + COLUMNS + ROWS + COLUMNS;
    //printf("each_cone_size: %d\n", each_cone_size);
    //initialize the input array to read 3 matrices and 3 vectors
    __int128_t input_array[MAX_SIZE];

    //Read file
    int input_array_size = read_file(input_array);
    //printf("input_array_size: %d\n", input_array_size);
    int number_of_cone = input_array_size / each_cone_size;
    //printf("number_of_cone: %d\n\n", number_of_cone);
    int cone_start_index = 0;

    //Split indexes: The file contains V, Uinv, Winv, q, s respectively. Use an only one matrix for the inputs and act them like a memory. 
    //Memorize the start indexes of the matrices and the vectors in the input array.
    int V_index, Uinv_index, Winv_index, q_index, s_index, o_index;
    int point_count = 0;
    long long int total_point_count = 0;
    double computational_time_taken = 0;
    double io_time_taken = 0;
    //double total_time_taken = 0;
    int write_count = 1;
    clock_t begin_total = clock();

    //__int128_t result_point[500][ROWS] = {0};
    int result_point[1000][ROWS] = {0};

    for(int each_cone = 0; each_cone < number_of_cone; each_cone++){
        clock_t begin_compute = clock();
        split_indexes(&V_index, &Uinv_index, &Winv_index, &q_index, &s_index, &o_index, cone_start_index);
        //printf("%d\t%d\t%d\t%d\t%d\t%d\n", V_index, Uinv_index, Winv_index, q_index, s_index, o_index);

        __int128_t prime_diagonals[ROWS];
        __int128_t q_summand[ROWS] = {0};
        __int128_t v_inner[ROWS] = {0};
        __int128_t q_hat[ROWS] = {0};
        __int128_t q_trans[ROWS] = {0};
        __int128_t q_int[ROWS] = {0};
        

        __int128_t last_diagonal = input_array[s_index + COLUMNS - 1];
        //printf("last_diagonal: %Lf\n\n", last_diagonal);
        /*printf("last_diagonal: ");
        print_int128(last_diagonal);
        printf("\n");*/
        
        for(int i = 0 ; i < ROWS ; i++){
            //check_int_range((long long int) last_diagonal);
            //check_int_range((long long int) input_array[s_index+i]);
            check_40bit_signed_range((long long int) last_diagonal);
            check_40bit_signed_range((long long int) input_array[s_index+i]);

            //check_short_int_range((long long int) last_diagonal);
            prime_diagonals[i] = last_diagonal / input_array[s_index+i];
            //printf("prime_diagonals[%d]: %lf\n", i, prime_diagonals[i]);

            q_summand[i] = last_diagonal * input_array[q_index + i];
            //printf("q_summand[%d]: %lf\n", i, q_summand[i]);
            for(int j = 0 ; j < COLUMNS ; j++){
                q_hat[i] = q_hat[i] + input_array[Uinv_index + i * ROWS + j] * input_array[q_index + j];
                //printf("q_hat[%d]: %lf\n", i, q_hat[i]);
                //printf("Uinv_index + i * ROWS + j: %d\n", Uinv_index + i * ROWS + j);
                /*printf("q_hat[%d] = ", i);
                print_int128(q_hat[i]);
                printf("\n");*/

                input_array[Winv_index + j * COLUMNS + i] = input_array[Winv_index + j * COLUMNS + i] * prime_diagonals[i];
                //printf("input_array[%d]: %lf\n", Winv_index + j * COLUMNS + i, input_array[Winv_index + j * COLUMNS + i]);            
            }
        }

        for (int i = 0; i < ROWS; ++i) {
            printf("prime_diagonals[%d] = ", i);
            print_int128(prime_diagonals[i]);
            printf("\n");
        }

        for (int i = 0; i < ROWS; ++i) {
            printf("q_summand[%d] = ", i);
            print_int128(q_summand[i]);
            printf("\n");
        }

        /*for (int i = 0; i < input_array_size; ++i) {
            printf("input_array[%d] = ", i);
            print_int128(input_array[i]);
            printf("\n");
        }*/
  
        
       int temp_index = Winv_index;
        for(int i = 0 ; i < ROWS ; i++){
            for(int j = 0 ; j < COLUMNS ; j++){
                //q_trans[i] = q_trans[i] + -1 * input_array[Winv_index + i * ROWS + j] * q_hat[j];
                q_trans[i] = q_trans[i] + -1 * input_array[temp_index] * q_hat[j];
                /*printf("input_array[%d]: ", temp_index);
                print_int128(input_array[temp_index]);
                printf("\n");*/

                //check_long_long_range(q_trans[i]);

                printf("q_trans[%d] = ", i);
                print_int128(q_trans[i]);
                printf("\n");
                //printf("q_trans[%d]: %Lf\n", i, q_trans[i]);
                /*printf("q_trans[%d] = ", i);
                print_int128(q_trans[i]);
                printf("\n");*/

                ++temp_index;
                
                q_int[i] = q_trans[i];
                //check_long_long_range(q_int[i]);
                //q_int[i] = get_floor(q_trans[i]);
                //printf("q_int[%d]: %lld\n", i, q_int[i]);
            }    
        }

        /*for (int i = 0 ; i < ROWS ; ++i) {
            printf("q_trans[%d] = ", i);
            print_int128(q_trans[i]);
            printf("\n");
        }*/

        long long int zeroth_if = 0;
        long long int first_if = 0;
        long long int second_if = 0;
        
        double io_time_temp = 0;
        while (1)
        {
            __int128_t inner_Res[ROWS]={0};
            for(int i = 0 ; i < ROWS ; i++){
                inner_Res[i] = q_int[i];
                //check_long_long_range(q_int[i]);
                for(int j = 0 ; j < COLUMNS ; j++){
                    //check_long_long_range(q_int[i]);
                    //printf("Winv_index + i * ROWS + j: %d\n", Winv_index + i * ROWS + j);

                    /*print_int128(inner_Res[i]  + input_array[Winv_index + i * ROWS + j] * v_inner[j]);
                    printf(" = ");
                    print_int128(inner_Res[i]);
                    printf(" + ");
                    printf("%d * ", input_array[Winv_index + i * ROWS + j]);
                    print_int128(v_inner[j]);
                    printf("\n");*/

                    inner_Res[i]  = inner_Res[i]  + input_array[Winv_index + i * ROWS + j] * v_inner[j];
                }

                /*printf("inner res after inner for loop: ");
                print_int128(inner_Res[i]);
                printf("\n");*/

                /*printf(" -> inner_Res[%d]: ", i);
                print_int128(inner_Res[i]);
                printf("\n");*/

                /*if (inner_Res[i] < 0) {
                    printf("inner_Res is less than 0\n");
                }*/
                

                //check_long_long_range(inner_Res[i]);
                //long long int test_var_1 = inner_Res[i];
                //check_int_range(test_var_1);
                //check_40bit_signed_range(test_var_1);
                inner_Res[i]  = inner_Res[i]  % last_diagonal;
                //inner_Res[i]  = fmodl(inner_Res[i], last_diagonal);
                //inner_Res[i] = trunc(fmodl(inner_Res[i], last_diagonal));
                //printf("inner_Res[%d]: %Lf\n", i, inner_Res[i]);
                /*printf("inner_Res[%d]: ", i);
                print_int128(inner_Res[i]);
                printf("\n");*/

                ++zeroth_if;
                
                if(inner_Res[i]  < 0) {
                    inner_Res[i]  = inner_Res[i]  + last_diagonal;
                    /*++first_if;
                    printf("first if\n");*/
                } 
                       
                if(inner_Res[i] == 0 && input_array[o_index+i] == 1) {
                    inner_Res[i] = last_diagonal;
                    /*++second_if;
                    printf("second if\n");*/
                }

                

                /*printf("inner_Res[%d]: ", i);
                print_int128(inner_Res[i]);
                printf("\n");*/
            }
            
            //printf("first_if: %lld\tsecond_if: %lld\n", first_if, second_if);
            
            /*for (int i = 0; i < ROWS; ++i) {
                printf("inner_Res[%d] = ", i);
                print_int128(inner_Res[i]);
                printf("\n");
            }*/

            int temp_V_index = V_index;
            __int128_t outer_array[ROWS] = {0};
            int k = 0;

            for(int j = 0 ; j < COLUMNS ; j++){
                outer_array[j] = (input_array[temp_V_index] * inner_Res[k]) + (input_array[temp_V_index+1] * inner_Res[k+1])
                            + (input_array[temp_V_index+2] * inner_Res[k+2]) + (input_array[temp_V_index+3] * inner_Res[k+3]);

                temp_V_index += ROWS;
            }

            for(int i = 0 ; i < ROWS ; i++){
                result_point[point_count][i] = (outer_array[i] + q_summand[i]) / last_diagonal;

                if (result_point[point_count][i] >= 128) {
                    printf("%d is geq 128\n", result_point[point_count][i]);
                }

                printf("%d ", result_point[point_count][i]);
            }
            printf("\n");

            /*if(point_count == 499){
                clock_t begin_io = clock();
                write_point_to_file(result_point, point_count);
                clock_t end_io = clock();
                io_time_taken += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
                io_time_temp += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
                write_count += 1;
            }*/

           point_count += 1;
           total_point_count += 1;

           if(point_count == 1000){
                clock_t begin_io = clock();
                //write_point_to_file(result_point, point_count);
                //write_point_to_file_decimal(result_point, point_count);
                clock_t end_io = clock();
                io_time_taken += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
                io_time_temp += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
                write_count += 1;
                point_count = 0;
            }

            int i = ROWS-1;
            while(i >= 0) {
                if(v_inner[i] < input_array[s_index+i]-1) {
                    v_inner[i] = v_inner[i] + 1;
                    break;
                }
                v_inner[i] = 0;
                i-=1;
            }

            /*if(point_count == 1000)
                point_count = 0;*/

            if(i == -1) {
                //dump_result_point_array(result_point, 1000);
                break;
            }
            
        } // end of while

        //printf("zeroth_if: %lld, first_if: %lld\tsecond_if: %lld\n", zeroth_if, first_if, second_if);

        //dump_result_point_array(result_point, 1000);

        if(point_count > 0 && point_count < 999){
            clock_t begin_io = clock();
            //write_point_to_file(result_point, point_count);
            //write_point_to_file_decimal(result_point, point_count);
            clock_t end_io = clock();
            io_time_taken += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
            io_time_temp += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
        }
        cone_start_index += each_cone_size;
        computational_time_taken += (double)(clock() - begin_compute) / CLOCKS_PER_SEC - io_time_temp;
    
    }
    
        
    
    clock_t end_total = clock();
    double time_spent = (double)(end_total - begin_total) / CLOCKS_PER_SEC;
    write_computational_time(time_spent, computational_time_taken, io_time_taken, total_point_count);

    printf("total point count: %lld\n", total_point_count);

    exit(EXIT_SUCCESS);

}

/*
int index = 0;
for(int i = 0 ; i < ROWS ; i++){
    __int128_t outer = 0;
    for(int j = 0 ; j < COLUMNS ; j++) {
        // index = V_index + i * ROWS + j
        outer = outer + input_array[index] * inner_Res[j];
        ++index;
    }
    result_point[point_count][i] = (outer + q_summand[i]) / last_diagonal;
} 
*/


/*
__int128_t inner_Res[ROWS] = {0};
for(int i = 0 ; i < ROWS ; i++) {
    inner_Res[i] = q_int[i];
    for(int j = 0 ; j < COLUMNS ; j++){
        // Winv_index + i * ROWS + j
        inner_Res[i]  = inner_Res[i]  + input_array[index] * v_inner[j];
    }
        inner_Res[i]  = inner_Res[i]  % last_diagonal;
                
        if(inner_Res[i]  < 0) {
            inner_Res[i]  = inner_Res[i]  + last_diagonal;
        } 
                       
        if(inner_Res[i] == 0 && input_array[o_index+i] == 1) {
            inner_Res[i] = last_diagonal;
        }
}
*/
