/* 10-bit counter module that is used to slow down the value change,
   since the clock has a high frequency. The output is one bit and 
   used to trigger 2 bit counter to count and control the display interface.
   Output is the left most binary digit, and it is assigned to have this value, 
   thus the output is used as the slowed down clock that is going to be used for 
   2-bit counter.*/ 

module bit_10_counter (clk_10, rst_10, out_10); 

    // Input ports
    input clk_10, rst_10;
    reg [9:0] counter_10, next;
    
    // Output port
    output out_10;
    
    always @(posedge clk_10 or posedge rst_10)
        if (rst_10)
            counter_10 <= 10'b0;
        else
            counter_10 <= next;
    
    always @(counter_10)
        next = 1'b1 + counter_10; // Increment
    
    assign out_10 = counter_10[9]; // Output is 1-bit the left most binary digit

endmodule