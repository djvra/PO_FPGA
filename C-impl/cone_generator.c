#include <stdio.h>
#include <stdlib.h>

void calculate_apex(long long int n, long long int apex[]) {
    for (int i = 0; i < n; i++) apex[i] = i + 1;
}

void calculate_generators(long long int n, long long int generators[][100]) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            generators[i][j] = (j >= i) ? j + 1 : 0;
}

void generate_A_matrix(long long int n, long long int A[][100]) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            A[i][j] = (j == i) ? i + 1 : ((j == i - 1) ? -(i + 1) : 0);
}

void generate_b_vector(long long int n, long long int b[]) {
    b[0] = 1;
    for (int i = 1; i < n; i++) b[i] = 0;
}

void construct_V_matrix(long long int n, long long int generators[][100], long long int V[][100]) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            V[i][j] = generators[j][i];
}

long long int gcd(long long int a, long long int b) { return b == 0 ? llabs(a) : gcd(b, a % b); }

void swap_rows(long long int mat[][100], long long int row1, long long int row2, long long int n) {
    long long int temp;
    for (int i = 0; i < n; i++) {
        temp = mat[row1][i];
        mat[row1][i] = mat[row2][i];
        mat[row2][i] = temp;
    }
}

void swap_cols(long long int mat[][100], long long int col1, long long int col2, long long int n) {
    long long int temp;
    for (int i = 0; i < n; i++) {
        temp = mat[i][col1];
        mat[i][col1] = mat[i][col2];
        mat[i][col2] = temp;
    }
}

void smith_normal_form(long long int V[][100], long long int n, long long int S[][100], long long int Uinv[][100], long long int Winv[][100]) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) {
            Uinv[i][j] = (i == j);
            Winv[i][j] = (i == j);
            S[i][j] = V[i][j];
        }

    for (int k = 0; k < n; k++) {
        for (int i = k; i < n; i++)
            for (int j = k; j < n; j++)
                if (S[i][j]) {
                    swap_rows(S, k, i, n);
                    swap_rows(Uinv, k, i, n);
                    swap_cols(S, k, j, n);
                    swap_cols(Winv, k, j, n);
                    goto proceed;
                }
proceed:
        for (int i = k + 1; i < n; i++)
            while (S[i][k]) {
                long long int q = S[i][k] / S[k][k];
                for (int j = 0; j < n; j++) {
                    S[i][j] -= q * S[k][j];
                    Uinv[i][j] -= q * Uinv[k][j];
                }
                if (S[i][k]) {
                    swap_rows(S, k, i, n);
                    swap_rows(Uinv, k, i, n);
                }
            }
        for (int j = k + 1; j < n; j++)
            while (S[k][j]) {
                long long int q = S[k][j] / S[k][k];
                for (int i = 0; i < n; i++) {
                    S[i][j] -= q * S[i][k];
                    Winv[i][j] -= q * Winv[i][k];
                }
                if (S[k][j]) {
                    swap_cols(S, k, j, n);
                    swap_cols(Winv, k, j, n);
                }
            }
    }
}

void print_matrix(const char *name, long long int mat[][100], long long int n) {
    printf("%s:\n", name);
    for (int i = 0; i < n; i++) {
        printf("[");
        for (int j = 0; j < n; j++) printf("%4lld%s", mat[i][j], j < n - 1 ? "," : "");
        printf("]\n");
    }
}

int main() {
    long long int n;
    printf("Enter dimension n: "); scanf("%lld", &n);

    long long int apex[100], generators[100][100], A[100][100], b[100];
    long long int V[100][100], S[100][100], Uinv[100][100], Winv[100][100];

    generate_A_matrix(n, A);
    generate_b_vector(n, b);
    calculate_apex(n, apex);
    calculate_generators(n, generators);
    construct_V_matrix(n, generators, V);
    smith_normal_form(V, n, S, Uinv, Winv);

    print_matrix("Matrix A", A, n);
    printf("\nVector b:\n[");
    for(int i=0;i<n;i++) printf("%lld%s", b[i], i<n-1?", ":"]\n");

    printf("\nApex:\n[");
    for(int i=0;i<n;i++) printf("%lld%s", apex[i], i<n-1?", ":"]\n");

    print_matrix("\nMatrix V", V, n);
    print_matrix("\nSmith Normal Form (S)", S, n);
    print_matrix("\nMatrix Uinv", Uinv, n);
    print_matrix("\nMatrix Winv", Winv, n);

    return 0;
}
