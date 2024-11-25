`timescale 1ns / 1ps
module TB_calc_logic;
	// Inputs to module being verified
	reg clock, reset, newkey;
	reg [4:0] keycode;
	// Outputs from module being verified
	wire ovw_out;
	wire [15:0] x_display;
	localparam
	   ADD = 5'ha, 
       MULTIPLY = 5'hb, 
       EQUAL = 5'hc,
       CA = 5'h4,
       MEMORY_STORE = 5'h2,
       MEMORY_RECALL = 5'h1;

	// Instantiate module
	calc_logic uut (
		.clock(clock),
		.reset(reset),
		.keycode(keycode),
		.newkey(newkey),
		.x_display(x_display),
		.ovw_out(ovw_out)
	);
	
	// Generate clock signal (5 MHz)
	initial
    begin
        clock  = 1'b1;
        forever
            #100 clock  = ~clock ;
    end
	
	// task assignment to perform verification plan
	task PRESS ( input [4:0] button);
        begin
            #400    // delay
            keycode = button;   // user input
            #500    // more delay
            @(posedge clock)    // at the posedge newkey becomes 1 
            newkey = 1'b1;
            @(posedge clock)    // at the next posedge newkey becomes 0
            newkey = 1'b0;
            #800    // more delay
            keycode = 5'h0;     // keycode set to 0
        end
	endtask
	
	// Procedure to implement verification plan 
	initial
	begin
        reset = 1'b0;            //initialize the inputs
        keycode = 5'b0;
        newkey = 1'b0;
        
        // Test 1 (2 + 3 + 4 = [] + 1 = [])
        #100;            // delay before reset
        reset = 1'b1;    // reset pulse of al least 1 clock cycle
        @(negedge clock);    // waiting for falling clock edge
        @(negedge clock) reset = 1'b0;   // end pulse at the 2nd falling edge
        
        #200; // delay to perform Test 1		    		     
        PRESS(5'h12); 
        PRESS(ADD);
        PRESS(5'h13);
        PRESS(ADD);
        PRESS(5'h14);
        PRESS(EQUAL);
        PRESS(ADD);
        PRESS(5'h11);
        PRESS(EQUAL);
        
        // Test 2 (2 x 2 + 3 = [] + 2 x 3 = [])
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h12);
        PRESS(MULTIPLY);
        PRESS(5'h12);
        PRESS(ADD);
        PRESS(5'h13);
        PRESS(EQUAL);
        PRESS(ADD);
        PRESS(5'h12);
        PRESS(MULTIPLY);
        PRESS(5'h13);
        PRESS(EQUAL);
        
        // Test 3 (2 + 3 = [] 7)
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;		      
        
        PRESS(5'h12);
        PRESS(ADD);
        PRESS(5'h13);
        PRESS(EQUAL);
        PRESS(5'h17);
        
        // Test 4 (2 + = [] + + = [])
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h12);
        PRESS(ADD);
        PRESS(EQUAL);
        PRESS(ADD);
        PRESS(ADD);
        PRESS(EQUAL);
        
        // Test 5 (2 x = [])
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h12);
        PRESS(MULTIPLY);
        PRESS(EQUAL);
        
        // Test 6 (12345 + 25 = [])
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h11);
        PRESS(5'h12);
        PRESS(5'h13);
        PRESS(5'h14);
        PRESS(5'h15);
        PRESS(ADD);
        PRESS(5'h12);
        PRESS(5'h15);
        PRESS(EQUAL);
        
        // Test 7 (ffff x ffff = [])
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h1f);
        PRESS(5'h1f);
        PRESS(5'h1f);
        PRESS(5'h1f);
        PRESS(MULTIPLY);
        PRESS(5'h1f);
        PRESS(5'h1f);
        PRESS(5'h1f);
        PRESS(5'h1f);
        PRESS(EQUAL);
        PRESS(5'h15);
        
        // Test 8 (2(store) + 1 = (clear all) (recall) + 2 = [])
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h12);
        PRESS(MEMORY_STORE);
        PRESS(ADD);
        PRESS(5'h11);
        PRESS(EQUAL);
        PRESS(CA);
        PRESS(MEMORY_RECALL);
        PRESS(ADD);
        PRESS(5'h12);
        PRESS(EQUAL);
        
        // Test 9 (3 + 2 = [](store) 1 (recall) + 1 = [])
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h13);
        PRESS(ADD);
        PRESS(5'h12);
        PRESS(EQUAL);
        PRESS(MEMORY_STORE);
        PRESS(5'h11);
        PRESS(MEMORY_RECALL);
        PRESS(ADD);
        PRESS(5'h11);
        PRESS(EQUAL);
                
        // Test 10 (2 + 4(store) + 5 = [](clear all) (recall))
        #200          // delay for reset for the new test
        reset = 1'b1;
        #300
        reset = 1'b0;
        
        PRESS(5'h12);
        PRESS(ADD);
        PRESS(5'h14);
        PRESS(MEMORY_STORE);
        PRESS(ADD);
        PRESS(5'h15);
        PRESS(EQUAL);
        PRESS(CA);
        PRESS(MEMORY_RECALL);	

        #600;		    		    
        $stop;
    end

endmodule