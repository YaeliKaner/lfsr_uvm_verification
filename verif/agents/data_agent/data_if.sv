interface data_if(input logic clk, input logic reset_n);
	
	//inputs
	logic [31:0] data_in;
	logic        data_valid_in;
	logic        ready_out;
	
	//outputs
	logic [31:0] data_out;
	logic        data_valid_out;
	logic        ready_in;
	
endinterface