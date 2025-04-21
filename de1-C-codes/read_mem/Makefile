CC = gcc
CFLAGS = -Wall -Wextra -pedantic -Wunused -Wconversion -std=c99 -O3
LDFLAGS = -lrt
TARGET = read_mem
SRC = read_mem.c

CHECK_TARGET = check_output
CHECK_SRC = check_output.c

all: $(TARGET) $(CHECK_TARGET)

$(TARGET): $(SRC)
        $(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)

$(CHECK_TARGET): $(CHECK_SRC)
        $(CC) $(CFLAGS) -o $(CHECK_TARGET) $(CHECK_SRC) $(LDFLAGS)

run: $(TARGET)
        ./$(TARGET) && cat output.txt

check: $(CHECK_TARGET)
        ./$(CHECK_TARGET)

clean:
        rm -f $(TARGET)

.PHONY: all clean run
