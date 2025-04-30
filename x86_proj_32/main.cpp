#include <iostream>
#include <cstdint>

using namespace std;

// #define RUN_TEST

#define ANSI_RED "\x1B[0;31m"
#define ANSI_MAG "\x1B[0;35m"
#define ANSI_GRN "\x1B[0;32m"
#define ANSI_reset "\x1B[0m"

extern "C" {
    
    extern int get_encodings(unsigned char *dest_bitmap, char* data, int bar_width, int16_t x, int8_t y);
    extern void convert_bits();
    extern void bmp();
    // for unit testing 
    extern uint8_t encoded_data[512];
    extern uint8_t ones_and_zeros_data[512];
    extern uint16_t ones_and_zeros_length;
}

void print_bits(){
    cout << "ones and zeros"<< endl;

    for(size_t i = 0; i < ones_and_zeros_length; i++){
        cout << static_cast<int>(ones_and_zeros_data[i]) << " ";
    }
    cout << endl;
}
void test(unsigned char image_buf[], char data[], string numbers, string bits, int16_t x, int8_t y, int bar_width = 1){
    cout <<ANSI_MAG << "\n\nStarting testing Data: " << data << ANSI_reset << " -----------" << endl;
    
    int ret = get_encodings(image_buf, data, bar_width, x, y);

    if(ret == 0){
        cout << ANSI_GRN <<"Success" << ANSI_reset << endl;
    }
    else if(ret == 1){
        cout << ANSI_RED<< "INVALID DATA has non-numeric values" << ANSI_reset << endl;
    }
    else if(ret == 2){
        cout << ANSI_RED << "Error opening file" << ANSI_reset  << endl;
    }
    else if(ret == 3){
        cout << ANSI_RED << "Error saving file" << ANSI_reset  << endl;
    }
    else if(ret == 4){
        cout << ANSI_RED << "ERROR: barcode does not fit in bitmap of given size" << ANSI_reset  << endl;
    }
    else if(ret == 5){
        cout << ANSI_RED << "Error: No data provided" << ANSI_reset  << endl;
    }
    else if(ret == 6){
        cout << ANSI_RED << "Error: data has odd lenght digits" << ANSI_reset  << endl;
    }
    for(size_t i = 0; i < numbers.size(); i++){
        int digit = numbers[i] - '0';
        if(encoded_data[i] !=digit){
            // cout << "failed: ENCODING index " << dec << i << ": expected " << digit << ", got " << static_cast<int>(encoded_data[i]) << "\n";
            // cout << ANSI_RED << "FAILED: encoded data" << ANSI_reset;
            break;
        }
    }

    cout << "\n";
    for(size_t i = 0; i < ones_and_zeros_length; i++){
        if(static_cast<int>(ones_and_zeros_data[i]) != (bits[i] - '0')){
            // cout << "failed: BITS index " <<  i << ": expected " << bits[i] << ", got " << static_cast<int>(ones_and_zeros_data[i]) << "\n";
            // cout << ANSI_RED << "FAILED: ones and zeros" << ANSI_reset;
            break;
        }
    }
    
    cout <<ANSI_MAG << "DONE testing Data: " << data << ANSI_reset << " -----------\n" << endl;
}

void print_encoding(){
    cout << "encoding "<< endl;
    for(size_t i=0; i<size(encoded_data); i++){
        if(encoded_data[i]){
            cout << hex << static_cast<int>(encoded_data[i]) << " ";
        }
    }
    cout << endl;
}


int main() {

    unsigned char image_buf[90122];
    char data[] = "101112";
    int ret = get_encodings(image_buf, data, 2,5,5);

#ifdef RUN_TEST
        cout << ANSI_GRN << "\n\nTESTING...." << ANSI_reset << "\n\n\n" ;
        
        { // testing for correctness of encoded data 
            unsigned char image_buf[90122];
            char data[] = "345456";
            string numbers = "2112321311233111233311211212232331112";
            string bits = "11010011100100010110001110101100011100010110100100110001100011101011";
            test(image_buf, data, numbers, bits, 0, 0);
        }
        {
            unsigned char image_buf[90122];
            char data[] = "40545445";
            string numbers = "2112322311133111233111231131231112422331112";
            string bits = "1101001110011000101000111010110001110101100010111011000101001111001100011101011";

            test(image_buf, data, numbers, bits, 0, 0);

        }


        {  // odd length data
            unsigned char image_buf[90122];
            char data[] = "8458491";
            string numbers = "";
            string bits = "";
            test(image_buf, data, numbers, bits, 0, 0);

        }

         {  // odd length data
            unsigned char image_buf[90122];
            char data[] = "8";
            test(image_buf, data, "", "", 0, 0);

        }
         {   // non-numeric
            unsigned char image_buf[90122];
            char data[] = "34a675";
            test(image_buf, data, "", "", 0, 0);

        }
         {   // non-numeric
            unsigned char image_buf[90122];
            char data[] = ";*()";
            test(image_buf, data, "", "", 0, 0);

        }
         {   // non-numeric
            unsigned char image_buf[90122];
            char data[] = "adsf";
            test(image_buf, data, "", "", 0, 0);

        }
         {  // error for space in between data
            unsigned char image_buf[90122];
            char data[] = "235 466";
            test(image_buf, data, "", "", 0, 0);

        }
        {  // error for empty data
            unsigned char image_buf[90122];
            char data[] = " ";
            test(image_buf, data, "", "", 0, 0);

        }

        { // testing for barcode does not fit in bitmap of given size
            unsigned char image_buf[90122];
            char data[] = "20102010";
            test(image_buf, data, "", "", 550, 0, 1);

        }
        {   unsigned char image_buf[90122];
            char data[] = "20152015";
            test(image_buf, data, "", "", 550, 0, 10);

        }
        
        // testing for long data
        {
            unsigned char image_buf[90122];
            char data[] = "345463462645634623644556685673346467842474322342343453464534232324234234";
            test(image_buf, data, "", "", 0, 0);
        }
#endif

    return 0;
}
