`ifndef BAUD_SETTING
`define BAUD_SETTING

typedef enum int {
    BAUD_9600 = 1667, //10^9 / 9600 -> ns /62.5 -> how many 16mhz clock cycles
    BAUD_115200 = 139,
    BAUD_460800 = 35,
    BAUD_1000000 = 16
} BAUD_CONFIG;

typedef enum logic[1:0] { 
    BAUD_SET_9600 = 2'b00,
    BAUD_SET_115200 = 2'b01,
    BAUD_SET_460800 = 2'b10,
    BAUD_SET_1000000 = 2'b11
} baud_set_t;

function integer clogb2(input integer bit_depth);
    // returns ceiling(log2(bit_depth))
    // used to calculate ARSIZE, the number byte of each beat within one burst
    begin
        for (clogb2 = 0; bit_depth > 0; clogb2 = clogb2 + 1)
            bit_depth = bit_depth >> 1;
    end
endfunction


`endif 