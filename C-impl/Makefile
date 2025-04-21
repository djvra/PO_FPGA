# Names of the executables
EXEC1 = program
EXEC2 = program_original
EXEC3 = de1

# Names of the C source files
SRC1 = FundamentalParallelepiped_C.c
SRC2 = FundamentalParallelepiped_C_original.c
SRC3 = de1.c

# Compiler
CC = gcc

# Compiler flags
CFLAGS = -Wall -Wextra -Wconversion -g -fsanitize=undefined

# Linker flags (to link with libasan)
LDFLAGS = -fsanitize=undefined -lm

# Build both executables
all: $(EXEC1) $(EXEC2) $(EXEC3)

$(EXEC1): $(SRC1)
	$(CC) $(CFLAGS) -o $(EXEC1) $(SRC1) $(LDFLAGS)

$(EXEC2): $(SRC2)
	$(CC) $(CFLAGS) -o $(EXEC2) $(SRC2) $(LDFLAGS)

$(EXEC3): $(SRC3)
	$(CC) $(CFLAGS) -o $(EXEC3) $(SRC3) $(LDFLAGS)

# Run the executables to check for segmentation faults and memory errors
check1: $(EXEC1)
	./$(EXEC1)

check2: $(EXEC2)
	./$(EXEC2)

check3: $(EXEC3)
	./$(EXEC3)

# Clean up the build
clean:
	rm -f $(EXEC1) $(EXEC2) $(EXEC3)

.PHONY: all check1 check2 clean
