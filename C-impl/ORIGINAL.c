#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define ROWS 9
#define COLUMNS 9
#define FILE_PATH "input/data9_yeni.txt"
#define MAX_SIZE 1000

/*
v1: All points are written to the same file
v2: Each 1000 points are written to the same file
v3: Each 1000 points are written to a new file
v4: Each 500 points are written to the same file
v5: Each 2000 points are written to the same file
*/

int read_file(double input_array[]){
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    size_t read;
    int array_index = 0;

    fp = fopen(FILE_PATH, "r");
    if (fp == NULL){
        printf("Couldnt find the file.\n");
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        double decimal = atof(line);
        input_array[array_index] = decimal;
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

void write_point_to_file(int point[][ROWS], int point_count){
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
    for(int j = 0; j < point_count; j++){
        for (int i = 0; i < ROWS; i++)
            fprintf(fp, "%d, ", point[j][i]);
        fprintf(fp, "\n");
    }
    

    // close the file
    fclose(fp);

    return;
} //her 500-1000 pointte aynı dosyaya yazan fonksiyon

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

void write_computational_time(double time_spent, double computational_time_taken, double io_time_taken, int point_count){

    char* filename = "PO_computation_times_v4.txt";
    // open the file for writing
    FILE *fp = fopen(filename, "a");
    if (fp == NULL)
    {
        printf("Error opening the file %s", filename);
        return -1;
    }

    fprintf(fp, "Dimension: %d\ttotal time: %lf\tcomputational time: %lf\tI/O time: %lf\tpoints:%d\n", ROWS, time_spent, computational_time_taken, io_time_taken, point_count);

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

int get_floor(double number){
    double number_frac = number - (int)number;
    if(number_frac == 0.0) return (int)number;
    else if(number_frac <= -0.5 || number_frac <= 0.5)
        return (int)number-1;
    else if(number_frac > -0.5 || number_frac > 0.5)
        return (int)number+1;
    else
        return (int)number;
}



int main(void)
{
    //Decide how many elements need to read
    int each_cone_size = 3*ROWS*COLUMNS + COLUMNS + ROWS + COLUMNS;
    //initialize the input array to read 3 matrices and 3 vectors
    double input_array[MAX_SIZE];

    //Read file
    int input_array_size = read_file(input_array);
    int number_of_cone = input_array_size / each_cone_size;
    int cone_start_index = 0;

    //Split indexes: The file contains V, Uinv, Winv, q, s respectively. Use an only one matrix for the inputs and act them like a memory. 
    //Memorize the start indexes of the matrices and the vectors in the input array.
    int V_index, Uinv_index, Winv_index, q_index, s_index, o_index;
    int point_count = 0;
    long long int total_point_count = 0;
    double computational_time_taken = 0;
    double io_time_taken = 0;
    double total_time_taken = 0;
    int write_count = 1;
    clock_t begin_total = clock();

    int result_point[500][ROWS] = {0};

    for(int each_cone = 0; each_cone < number_of_cone; each_cone++){
        clock_t begin_compute = clock();
        split_indexes(&V_index, &Uinv_index, &Winv_index, &q_index, &s_index, &o_index, cone_start_index);
        //printf("%d\t%d\t%d\t%d\t%d\t%d\n", V_index, Uinv_index, Winv_index, q_index, s_index, o_index);

        double prime_diagonals[ROWS];
        double q_summand[ROWS] = {0};
        int v_inner[ROWS] = {0};
        double q_hat[ROWS] = {0};
        double q_trans[ROWS] = {0};
        int q_int[ROWS] = {0};
        

        int last_diagonal = input_array[s_index + COLUMNS - 1];
        

        for(int i = 0 ; i < ROWS ; i++){
            prime_diagonals[i] = last_diagonal / input_array[s_index+i];
            q_summand[i] = last_diagonal * input_array[q_index + i];
            for(int j = 0 ; j < COLUMNS ; j++){
                q_hat[i] = q_hat[i] + input_array[Uinv_index + i * ROWS + j] * input_array[q_index + j];
                input_array[Winv_index + j * COLUMNS + i] = input_array[Winv_index + j * COLUMNS + i] * prime_diagonals[i];
            }
        }
  
        
    
        for(int i = 0 ; i < ROWS ; i++){
            for(int j = 0 ; j < COLUMNS ; j++){
                q_trans[i] = q_trans[i] + -1 * input_array[Winv_index + i * ROWS + j] * q_hat[j];
                q_int[i] = get_floor(q_trans[i]);
            }    
        }
        
        double io_time_temp = 0;
        while (1)
        {
            
            
            int inner_Res[ROWS]={0};
            for(int i = 0 ; i < ROWS ; i++){
                inner_Res[i] = q_int[i];
                for(int j = 0 ; j < COLUMNS ; j++){
                    inner_Res[i]  = inner_Res[i]  + input_array[Winv_index + i * ROWS + j] * v_inner[j];
                }
            
                inner_Res[i]  = inner_Res[i]  % last_diagonal;
            
                if(inner_Res[i]  < 0) inner_Res[i]  = inner_Res[i]  + last_diagonal;

                if(inner_Res[i] == 0 && input_array[o_index+i] == 1) {
                    inner_Res[i] = last_diagonal;
                }
                
            }

            /*for (int i = 0; i < ROWS; i++){
                printf("inner_Res[%d]: %d\n", i, inner_Res[i]);
            }*/

            for(int i = 0 ; i < ROWS ; i++){
                int outer = 0;
                for(int j = 0 ; j < COLUMNS ; j++){
                    outer = outer + input_array[V_index + i * ROWS + j] * inner_Res[j];
                }
                result_point[point_count][i] = (outer + q_summand[i]) / last_diagonal;
                printf("%d ", result_point[point_count][i]);
            }
            printf("\n");
            
            if(point_count == 499){
                clock_t begin_io = clock();
                //write_point_to_file(result_point, point_count);
                clock_t end_io = clock();
                io_time_taken += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
                io_time_temp += (double)(end_io - begin_io) / CLOCKS_PER_SEC;
                write_count += 1;
            }
            
            
            int i = ROWS-1;
            while(i >= 0){
                //printf("i: %d\n", i);
                //printf("%d < %d\n", v_inner[i], (int) input_array[s_index+i]-1);
                
                if(v_inner[i] < input_array[s_index+i]-1){
                    
                    v_inner[i] = v_inner[i] + 1;
                    break;
                }
                v_inner[i] = 0;
                i-=1;
            }

            if(i == -1) break;
            point_count += 1;
            total_point_count += 1;
            if(point_count == 500)
                point_count = 0;

        }
        if(point_count > 0 && point_count < 499){
            clock_t begin_io = clock();
            //write_point_to_file(result_point, point_count);
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

    printf("total_point_count: %lld\n", total_point_count);

    exit(EXIT_SUCCESS);

}

    

    
    
    
    
    

    
 

    

    

    
