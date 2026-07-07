package lfsr_tests_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	import control_agent_pkg::*;
    import data_agent_pkg::*;
    import lfsr_env_pkg::*;
	
	`include "base_test.sv"
	`include "sanity_test.sv"
	`include "bypass_test.sv"
	`include "seed_load_test.sv"
	`include "data_valid_in_test.sv"
	`include "ready_out_test.sv"
	`include "corner_case_data_test.sv"
	`include "random_test.sv"
	`include "regression_test.sv"
endpackage