
ASM_files = bmp.asm get_encodings.asm data.asm convert_bits.asm
ASM_obj = $(ASM_files:.asm=.o)

flags = -Wall -Wextra -Wpedantic -z noexecstack

all: $(ASM_obj) main.o
	g++ -g -m32 -O2 -pg $(flags) $(ASM_obj) main.o -o main -no-pie

%.o: %.asm 
	nasm -g -f elf32 -F dwarf $< -o $@

main.o: main.cpp
	g++ -g -m32 $(flags) -c main.cpp -o main.o
	
clean:
	rm -f $(ASM_obj) main.o main
