
ASM_files = get_encodings.asm data.asm convert_bits.asm bmp.asm
ASM_obj = $(ASM_files:.asm=.o)

flags =  -Wall -Wextra -Wpedantic -z noexecstack

all: $(ASM_obj) main.o
	g++ -g -m64 $(flags) $(ASM_obj) main.o -o main -no-pie

%.o: %.asm 
	nasm -g -f elf64 -F dwarf $< -o $@

main.o: main.cpp
	g++ -g -m64 $(flags) -c main.cpp -o main.o 
	
clean:
	rm -f $(ASM_obj) main.o main
