/*  Calculator Design  - Calculator Logic Module 
    Required to design a simple calculator with arithmetic operation such as 
    addition, multiplication and features such as clear all, memory store and recall.
    The clock frequency is 5MHz with a synchronous reset.  */

module calc_logic (
    input clock,
    input reset,
    input [4:0] keycode,
    input newkey,
    output [15:0] x_display,
    output reg ovw_out);

    // ===========================================================================
    // Interconnecting signals
    wire [15:0] inpt;
    wire op_press, num_press; 
    wire [31:0] addition_result, multiplication_result;
    reg [31:0] result;
    reg [2:0] op_out, op_in;
    reg ovw_in;
    reg [15:0] mem_in, mem_out;
    reg lim_x_display;
    
    // Output Display
    assign x_display = x_reg_out;
     
    // Addition and Multiplication  
    assign addition_result = x_reg_out + y_reg_out;
    assign multiplication_result = x_reg_out * y_reg_out;
    
    // Concatenation of two signals number
    assign inpt = {x_reg_out[11:0], keycode[3:0]};  
    
    // Defining digit and operation press 
    assign op_press = (newkey & ~keycode[4]);
    assign num_press = (newkey & keycode[4]);
    
    // ===========================================================================
    // One-hot code is assigned to different operations
    localparam [2:0]
        CA = 3'b000,
        ADD = 3'b001,
        MULTIPLY = 3'b010,
        EQUAL = 3'b011,
        MEMORY_STORE = 3'b101,
        MEMORY_RECALL = 3'b110;

    // ===========================================================================
    // Look-up table to assign different operation to localparameters depending on the keycode
    always @(keycode or op_press or op_out)
        if (op_press)
            case (keycode)	                 // multiplexer output controls type of operation 
                5'ha: op_in = ADD;			 // 1st row, 1st column indicates ADD
                5'hb: op_in = MULTIPLY;		 // 2nd row, 1st column indicates MULTIPLY
                5'hc: op_in = EQUAL;		 // 3rd row, 1st column indicates EQUAL
                5'h4: op_in = CA;			 // 3rd row, 0th column indicates CA
                5'h2: op_in = MEMORY_STORE;  // 1st row, 0th column indicates MEMORY_STORE
                5'h1: op_in = MEMORY_RECALL; // 0th row, 0th column indicates MEMORY_RECALL
                default: op_in = op_out; 	 // for any other value, 
                // the default option includes other cases. 
            endcase
        else
            op_in = op_out;

    // ===========================================================================
    //  Register x to display the calculator
    reg [15:0] x_reg_out, x_reg_in;
    //  Register y for memory  of the calculator
    reg [15:0] y_reg_out, y_reg_in;
    // Register to hold digit value (X register , Y register ) and operation (Overflow)
    
    always @(posedge clock)      // reset will be synchronous
        if (reset || op_press && op_in == CA)  // reset to zero either if reset or clear all key is pressed 
            begin
                x_reg_out <= 16'b0;        
                y_reg_out <= 16'b0;
                ovw_out <= 1'b0;
            end
        else
            begin	// otherwise input of the register is the output
                x_reg_out <= x_reg_in;          
                y_reg_out <= y_reg_in;
                ovw_out <= ovw_in;
            end

    // ===========================================================================
    // Multiplexer unit 1
    // Multiplexer to select the input of  X register
    always @(op_press or inpt or x_reg_out or num_press or op_in or mem_out or result or op_out or lim_x_display or keycode)
        if (num_press && (op_out == EQUAL || op_out == MEMORY_STORE))
            x_reg_in = {12'b0, keycode[3:0]};	// concatination of new input after the EQUAL was pressed
        else if (num_press && !lim_x_display)
            x_reg_in = inpt;	                // concatination if new input while no input overflow 
        else if (op_in == EQUAL && op_press)
            x_reg_in = result;	                // X register takes the value of result in case the EQUAl was pressed
        else if (op_in == MEMORY_RECALL && op_press)
            x_reg_in = mem_out;	                // X register takes the stored value in case MEMORY_RECALL is pressed
        else if (op_press && op_in != MEMORY_STORE)
            x_reg_in = 0;	                    // X register will be 0 in case any operation is pressed except MEMORY_STORE
        else
            x_reg_in = x_reg_out;	            // by default input of the X register is its output
       
    // ===========================================================================
    // Multiplexer unit 2
    // Multiplexer to select the input of  Y register
    always @(x_reg_out or y_reg_out or result or op_press or op_out)
        if ((op_out == ADD || op_out == MULTIPLY) && op_press)
            y_reg_in = result;    // Y register will take a value of result in case of more than 2 operands are present in calculation
        else if (op_press)
            y_reg_in = x_reg_out; // any operation press will make Y register store the output of X register
        else
            y_reg_in = y_reg_out; // by default input of the Y register is its output

    // =========================================================================== 
    // Final MUX for result (unit 3)
    // Multiplexer to select the input of result
    always @(addition_result or multiplication_result or op_out or x_reg_out or y_reg_out)
        if (op_out == ADD)
            result = addition_result;	    // result of the calculation is addition in case of ADD operator
        else if (op_out == MULTIPLY)
            result = multiplication_result;	// result of the calculation is multiplication in case of MULTIPLY operator
        else
            result = x_reg_out;	            // by default result is output of X register
 
    // ===========================================================================
    // Operation Storage (op_out) 
    always @(posedge clock) // reset will be synchronous
        if (reset || op_press && op_in == CA || num_press && op_out == EQUAL) // reset to zero either if reset, clear all key or number pressed followed by EQUAL key press
            op_out <= 3'b000;
        else
            op_out <= op_in;

    always @(posedge clock)	// reset will be synchronous
        if (reset)
            mem_out <= 16'b0;	// CA does not clear a stored value, only the reset does
        else
            mem_out <= mem_in;	// by default input of the register is the output

    // ===========================================================================
    // Memory block 
    always @(mem_out or op_press or x_reg_out or op_in)
        if (op_press && op_in == MEMORY_STORE)
            mem_in = x_reg_out;	// storing output of X register in case of MEMORY_STORE operator is pressed
        else
            mem_in = mem_out;	// by default input if the memory block is the output

    // Input overflow block (does not allow user to input more than 4 digit number)
    always @(x_reg_out or keycode or num_press)
        if (|x_reg_out[15:12] && num_press)	// in case any of the 4 MSB are one, input overflow occurs, meaning 1
            lim_x_display = 1'b1;
        else
            lim_x_display = 1'b0;	// by default input overflow is 0

    // Comparison block for result overflow (Output of the overflow is connected to the circuit board)
    always @(result or newkey or ovw_out or op_in or op_press)
        if(result >= 16'hffff && op_in == EQUAL && op_press) // if the result is greater than 16 hexadecimal bits and EQUAL was pressed - arithmetic overflow occurs
            ovw_in = 1'b1;
        else if (newkey) // any key from the keypad will set the overflow back to 0
            ovw_in = 1'b0;
        else
            ovw_in = ovw_out; // by default input of the overflow block is its output

endmodule