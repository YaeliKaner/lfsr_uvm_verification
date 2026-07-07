`timescale 1ns/1ps
module lfsr(
	
	//data inputs
	input clk,
	input reset_n,
	input [31:0] data_in,
	input data_valid_in,
	input ready_out,
	
	//control inputs
	input [2:0] polynomial_select, 
	input [31:0] seed_value,
	input seed_load,
	input bypass_enable,

	//outputs
	output reg [31:0] data_out,
	output reg data_valid_out,
	output reg ready_in );
	
	reg [31:0] LFSR_REG;
	reg feedback;
	reg [31:0] polynomial_mask;
	
	always @(*) begin
		if(reset_n) begin
	   case(polynomial_select)
	        3'b000: polynomial_mask = (32'b1<<7) | (32'b1<<4) | 32'b1;
	        3'b001: polynomial_mask = (32'b1<<15) | (32'b1<<14) | 32'b1;
	        3'b010: polynomial_mask = (32'b1<<23) | (32'b1<<18) | 32'b1;
	        3'b011: polynomial_mask = (32'b1<<31) | (32'b1<<28) | 32'b1;
		   default: polynomial_mask = 32'b0;
	   endcase
	   feedback = ^(LFSR_REG & polynomial_mask);
		end
		else begin
			polynomial_mask = 32'b0;
			feedback = 1'b0;
		end
		
	   
	end
	
	always @(posedge clk or negedge reset_n) begin		
		if(!reset_n) begin
			LFSR_REG <= 32'b0; 	
			data_out <= 32'b0;
			data_valid_out <= 1'b0;
			ready_in <= 1'b0;
			
		end
		else begin
			ready_in <= 1'b1;

			if(!data_valid_in || !ready_out) begin
					data_out <= 32'b0;
					data_valid_out <= 1'b0;
				if(seed_load)
			    	LFSR_REG <= seed_value;
			end
			else begin
			if(seed_load)
			    	LFSR_REG <= seed_value; 
			else
				LFSR_REG <= {LFSR_REG[30:0], feedback};
		
				if (!bypass_enable) begin
					data_valid_out <= 1'b1;
					data_out <= data_in ^ LFSR_REG;	
				end
				else begin
			    data_valid_out <= 1'b1;
				data_out <= data_in;
				end
			end
		end
		end
endmodule