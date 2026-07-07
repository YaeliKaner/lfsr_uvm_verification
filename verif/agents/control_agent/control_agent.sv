class control_agent extends uvm_agent;
	`uvm_component_utils(control_agent)
	
	control_driver control_driver_i;
	control_sequencer control_sequencer_i;
	control_monitor control_monitor_i;
	
	function new(string name = "control_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		control_driver_i = control_driver::type_id::create("control_driver_i", this);
		control_sequencer_i = control_sequencer::type_id::create("control_sequencer_i", this);
		control_monitor_i = control_monitor::type_id::create("control_monitor_i", this);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		control_driver_i.seq_item_port.connect(control_sequencer_i.seq_item_export);
	endfunction
	
endclass