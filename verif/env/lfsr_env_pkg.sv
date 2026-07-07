package lfsr_env_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	
	import control_agent_pkg::*;
	import data_agent_pkg::*;
	`include "lfsr_coverage.sv"
	`include "lfsr_reference_model.sv"
	`include "lfsr_scoreboard.sv"
	`include "lfsr_env.sv"
endpackage
