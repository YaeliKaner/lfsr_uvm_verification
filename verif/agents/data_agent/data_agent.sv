class data_agent extends uvm_agent;
	`uvm_component_utils(data_agent)
	
	data_driver data_driver_i;
	data_sequencer data_sequencer_i;
	data_monitor data_monitor_i;
	
	function new(string name = "data_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		data_driver_i = data_driver::type_id::create("data_driver_i", this);
		data_sequencer_i = data_sequencer::type_id::create("data_sequencer_i", this);
		data_monitor_i = data_monitor::type_id::create("data_monitor_i", this);
	endfunction
		
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		data_driver_i.seq_item_port.connect(data_sequencer_i.seq_item_export);
	endfunction
		
endclass