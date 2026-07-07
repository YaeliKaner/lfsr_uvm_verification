`timescale 1ns/1ps
module tb_top;
	import uvm_pkg::*;
	import lfsr_tb_pkg::*;
	`include "uvm_macros.svh"
	
	bit clk;
    bit reset_n;
	
	control_if control_vif(clk, reset_n);
	data_if data_vif(clk, reset_n);

	lfsr dut(
		.clk(data_vif.clk),
		.reset_n(data_vif.reset_n),
		.data_in(data_vif.data_in),
		.data_valid_in(data_vif.data_valid_in),
		.ready_out(data_vif.ready_out),
		
		//control inputs
		.polynomial_select(control_vif.polynomial_select), 
		.seed_value(control_vif.seed_value),
		.seed_load(control_vif.seed_load),
		.bypass_enable(control_vif.bypass_enable),

		//outputs
		.data_out(data_vif.data_out),
		.data_valid_out(data_vif.data_valid_out),
		.ready_in(data_vif.ready_in) );

	always #4.167 clk = ~clk;
	
	initial begin
		clk = 0;
        reset_n = 0; 

		#4.167;
		reset_n = 1; 
		
	end
	
	initial begin
		uvm_config_db #(virtual control_if)::set(null, "*", "control_vif", control_vif);
	    uvm_config_db #(virtual data_if)::set(null, "*", "data_vif", data_vif);
		run_test("regression_test");
	end
	
	initial begin
		$dumpfile("dump.vcd");
        $dumpvars(0, tb_top); 	 
    end
	
endmodule