#include <lcm/lcm-cpp.hpp>
#include "exlcm/example_type.hpp"
// #include "exlcm_rehash/example_type.hpp" // Use this line instead if using custom hash

int main(int argc, char** argv)
{
    lcm::LCM lcm;

    if(!lcm.good())
        return 1;

    exlcm::example_type my_data;
    // exlcm_rehash::example_type my_data; // Use this line instead if using custom hash
    
    if(argc > 1)
        my_data.str = argv[1];
    else   
        my_data.str = "Sample string";
    my_data.flag = true;
    my_data.gnash = 0xFF;
    
    my_data.i8_scalar = 8;
    my_data.i8_array[0] = 8;
    my_data.i8_array[1] = -8;

    my_data.i16_scalar = 16;
    my_data.i16_array[0] = 16;
    my_data.i16_array[1] = -16;

    my_data.i32_scalar = 32;
    my_data.i32_array[0] = 32;
    my_data.i32_array[1] = -32;

    my_data.i64_scalar = 64;
    my_data.i64_array[0] = 64;
    my_data.i64_array[1] = -64;
    
    my_data.flt_scalar = 1.234;
    my_data.flt_array[0] = 1.2;
    my_data.flt_array[1] = -1.2;        

    my_data.dbl_scalar = 1.234;
    my_data.dbl_array[0] = 1.2;
    my_data.dbl_array[1] = -1.2;
    
    my_data.variable_length_array.resize(my_data.i32_scalar);
    for(int i=0; i<my_data.i32_scalar; i++)
        my_data.variable_length_array[i] = (double) i;

    my_data.num_channels = 4;
    my_data.channels.resize(my_data.num_channels);
    for(int i=0; i<my_data.num_channels; i++) {
        my_data.channels[i].name = "test channel";
        my_data.channels[i].value = (double) i;
    }

    lcm.publish("example_topic", &my_data);

    return 0;
}
