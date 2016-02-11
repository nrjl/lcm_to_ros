#include <lcm/lcm-cpp.hpp>
#include "example_t.hpp"

int main(int argc, char** argv)
{
    lcm::LCM lcm;

    if(!lcm.good())
        return 1;

    exlcm::example_t my_data;
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

    my_data.str = "Sample string";
    my_data.flag = true;

    lcm.publish("example_t", &my_data);

    return 0;
}
