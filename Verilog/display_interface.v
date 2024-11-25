 /* Display Interface Design - Displace Interface 
     Required to design an interface module that is going to take clock 5MHz,
     reset, value and dots as inputs and output the segment and digit. */ 
     
module Design_Interface (
    input clock, 
    input reset, 
    input [15:0] value, 
    input [3:0] dots, 
    output [7:0] segment, 
    output reg [3:0] selector, // outputs 4 bits of input value
    output reg [7:0] digit);
    
    // === Defining wires to connect the blocks === //
    
    // Breaking the input into 4 groups of 4 bits that are going to be input sequentially
    wire [3:0] v0 = value[3:0]; 
    wire [3:0] v1 = value[7:4]; 
    wire [3:0] v2 = value[11:8]; 
    wire [3:0] v3 = value[15:12]; 
        
    // Breaking dots into 1 bit elements
    wire d0 = dots[0]; 
    wire d1 = dots[1]; 
    wire d2 = dots[2]; 
    wire d3 = dots[3]; 
        
    // Output wires from the blocks
    wire [1:0] check; // sends a signal to switch between one of the four groups of 4 bits, dots and digits
    wire check_10; // output from 10-bit counter that triggers 2 bit counter
    reg pointer; // used to produce which dot is turned on
    wire [6:0] LUT_out; // produced 7-bit output on display
        
    // ===== Internal hardware ======== // 
    
    // Instantiation of 2-bit and 10-bit counters 
    bit_10_counter counter_10 (.clk_10(clock), .rst_10(reset), .out_10(check_10)); 
    two_bit_counter counter (.clk(check_10) , .rst(reset) ,.out(check)); 

    // ===== Block A ======== // 
    // Multiplexer that is going to change between the digits being used 
    always @(check)
        case (check) // Initialing the values for one hot code positions
            2'b00:
                digit = 8'b11111110;
            2'b01:
                digit = 8'b11111101;
            2'b10:
                digit = 8'b11111011;
            default:
                digit = 8'b11110111; 
        endcase
            
    // ===== Block B ======== // 
    // Multiplexer that is going to switch between each of the group of 4 bits of the input
    always @(v0 or v1 or v2 or v3 or check)
        //$display("Time: %t, Selector: %h, Check: &h", $time, selector, check);
            if (check == 2'b00)
                selector = v0; 
            else if (check == 2'b01)
                selector = v1; 
            else if (check == 2'b10)
                selector = v2; 
            else
                selector = v3;

    // ===== Block C ======== // 
    // Multiplexer that is going to switch between the digits of 4-bit dot input
    always @(d0 or d1 or d2 or d3 or check)
        if (check == 2'b00)
            pointer = d0;
        else if (check == 2'b01)
            pointer = d1; 
        else if (check == 2'b10)
            pointer = d2; 
        else
            pointer = d3;
            
    // ===== Block D ======== // 
    // Instantiating hex2seg display 
    hex2seg hexa_display (.number(selector), .pattern(LUT_out));
    // Concatenating output of the LUT and dot 
    assign segment = {LUT_out, ~pointer};

endmodule