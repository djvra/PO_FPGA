# yeni ve eski datalarin sonuclarini kontrol et

with open('C_result_point_dump_6', 'r') as f1, open('aaaaaa', 'r') as f2:
    lines1 = [list(map(int, line.strip().split())) for line in f1.readlines()]
    lines2 = [list(map(int, line.strip().split())) for line in f2.readlines()]

    # Create a set of the lines in file1
    lines1_set = set(map(tuple, lines1))

    # Check if the lines in file2 exist in file1
    for line in lines2:
        if tuple(line) not in lines1_set:
            print(f"Line {' '.join(map(str, line))} does not exist in file1.")
