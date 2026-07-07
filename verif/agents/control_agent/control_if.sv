interface control_if(input logic clk, input logic reset_n);
	
    logic [2:0]  polynomial_select;
	logic [31:0] seed_value;
	logic        seed_load;
	logic        bypass_enable;
	
endinterface