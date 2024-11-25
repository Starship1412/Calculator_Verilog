/* 2-bit counter to move slowly throught the 4 states. 
   Output is 2 bit binary.*/
   
module two_bit_counter (clk, rst, out);
    
    // Input ports
    input clk, rst;
    reg [1:0] counter, next;
    
    // Output ports
    output [1:0] out;
    
    always @(posedge clk or posedge rst)
        if (rst)
            counter <= 2'b0;
        else
            counter <= next;
    
    always @(counter)
        next = 1'b1 + counter;   // Increment
    
    assign out = counter;    // 2-bit output
    
endmodule