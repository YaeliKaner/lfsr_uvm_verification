class control_sequencer extends uvm_sequencer #(control_seq_item);
	
	`uvm_component_utils(control_sequencer)
	
	function new(string name = "control_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
endclass