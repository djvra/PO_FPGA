#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#define ROWS 3
#define COLUMNS 3


void read_file(int input_array[]){
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    int array_index = 0;

    fp = fopen("/input/data3.txt", "r");
    if (fp == NULL){
        printf("Couldnt find the file.\n");
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        int decimal = atoi(line);
        input_array[array_index] = decimal;
        printf("%d\n", decimal);
        array_index++;

    }

    fclose(fp);
    if (line)
        free(line);



}

void split_indexes(int* V_index, int* Uinv_index, int* Winv_index, int* q_index, int* s_index){
    *V_index = 0;
    *Uinv_index = ROWS * COLUMNS;
    *Winv_index = *Uinv_index + ROWS * COLUMNS;
    *q_index = *Winv_index + ROWS * COLUMNS;
    *s_index = *q_index + COLUMNS; 
}



int main(void)
{
    //Decide how many elements need to read
    int input_array_size = 3*ROWS*COLUMNS + COLUMNS + ROWS;
    //initialize the input array to read 3 matrices and 2 vectors
    int input_array[input_array_size];
    //Read file
    read_file(input_array);

    //Split indexes: The file contains V, Uinv, Winv, q, s respectively. Use an only one matrix for the inputs and act them like a memory. 
    //Memorize the start indexes of the matrices and the vectors in the input array.
    int V_index, Uinv_index, Winv_index, q_index, s_index;
    split_indexes(&V_index, &Uinv_index, &Winv_index, &q_index, &s_index);
    //printf("%d\t%d\t%d\t%d\t%d\n", V_index, Uinv_index, Winv_index, q_index, s_index);

    /*for(int i = 0; i < ROWS; i++){
        for(int j = 0; j < COLUMNS; j++){
            printf("Winv[%d][%d]: %d\n", i,j, input_array[Winv_index + i * ROWS + j]);
        }
    }

    for(int i = 0; i < ROWS; i++){
        for(int j = 0; j < COLUMNS; j++){
            printf("Uinv[%d][%d]: %d\n", i,j, input_array[Uinv_index + i * ROWS + j]);
        }
    }

    for(int i = 0; i < ROWS; i++){
        for(int j = 0; j < COLUMNS; j++){
            printf("V[%d][%d]: %d\n", i,j, input_array[V_index + i * ROWS + j]);
        }
    }*/

    int last_diagonal = input_array[s_index + COLUMNS - 1];
    int point_count = 0;
    int prime_diagonals[ROWS];
    int q_summand[ROWS] = {0};
    int v_inner[ROWS] = {0};
    int q_hat[ROWS] = {0};
    int q_int[ROWS] = {0};
    int result[3][ROWS] = {0};


    for(int i = 0 ; i < ROWS ; i++){
        prime_diagonals[i] = last_diagonal / input_array[s_index+i];
        q_summand[i] = last_diagonal * input_array[q_index + i];
        for(int j = 0 ; j < COLUMNS ; j++){
            q_hat[i] = q_hat[i] + input_array[Uinv_index + i * ROWS + j] * input_array[q_index + j];
            input_array[Winv_index + j * COLUMNS + i] = input_array[Winv_index + j * COLUMNS + i] * prime_diagonals[i];

        }    

    }

    /*for(int i = 0; i < ROWS; i++){
        for(int j = 0; j < COLUMNS; j++){
            printf("Wprime[%d][%d]: %d\n", i,j, input_array[Winv_index + i * ROWS + j]);
        }
    }    */

    for(int i = 0 ; i < ROWS ; i++){
        for(int j = 0 ; j < COLUMNS ; j++){
            q_int[i] = q_int[i] + input_array[Winv_index + i * ROWS + j] * -q_hat[j];
        }    
    }

    /*for(int i = 0 ; i < ROWS ; i++){
        printf("prime_diagonals[%d] = %d\n", i, prime_diagonals[i]);
        printf("q_summand[%d] = %d\n", i, q_summand[i]);
        printf("q_hat[%d] = %d\n", i, q_hat[i]);
        printf("q_int[%d] = %d\n", i, q_int[i]);
    }*/

    
    while (1)
    {
        for(int i = 0 ; i < ROWS ; i++){
            printf("vinner[%d] = %d\n", i, v_inner[i]);
        }
        
        int inner_Res[ROWS]={0};
        for(int i = 0 ; i < ROWS ; i++){
            inner_Res[i] = q_int[i];
            for(int j = 0 ; j < COLUMNS ; j++){
                inner_Res[i]  = inner_Res[i]  + input_array[Winv_index + i * ROWS + j] * v_inner[j];
                printf("------------------\n");
                printf("%d * %d\n",input_array[Winv_index + i * ROWS + j],v_inner[j]);
                printf("------------------\n");
            }
            
            inner_Res[i]  = inner_Res[i]  % last_diagonal;
            
            if(inner_Res[i]  < 0) inner_Res[i]  = inner_Res[i]  + last_diagonal;
        }
        for(int i = 0 ; i < ROWS ; i++){
            printf("innerRes[%d] = %d\n", i, inner_Res[i]);
        }
        int outer_Res[ROWS]={0};
        for(int i = 0 ; i < ROWS ; i++){
            int outer = 0;
            for(int j = 0 ; j < COLUMNS ; j++){
                outer = outer + input_array[V_index + i * ROWS + j] * inner_Res[j];
            }
            outer_Res[i] = outer;
            result[point_count][i] = (outer + q_summand[i]) / last_diagonal;
        }
        for(int i = 0 ; i < ROWS ; i++){
            printf("outerRes[%d] = %d\n", i, outer_Res[i]);
        }
        printf("bitti\n");
        int j = ROWS-1;
        while(j >= 0){
            if(v_inner[j] < input_array[s_index+j]-1){
                v_inner[j] = v_inner[j] + 1;
                printf("girdi\n");
                break;
            }
            else{
                v_inner[j] = 0;

            }
            j-=1;
        }

        if(j == -1) break;
        point_count += 1;

    }
    for(int i = 0; i <= point_count; i++){
        for(int j = 0 ; j < ROWS ; j++){
            printf("result[%d][%d] = %d\n", i, j, result[i][j]);
        }
    }

    exit(EXIT_SUCCESS);
}