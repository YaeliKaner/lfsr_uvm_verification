class bypass_test extends base_test;
	`uvm_component_utils(bypass_test)

	function new(string name = "bypass_test", uvm_component parent = null);
    super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		
		for (int i = 0; i < 4; i++) begin 
			bypass_control_seq_i.current_poly = i; 
			fork
			bypass_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
			sanity_data_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);		
			data_valid_in_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
			join
		end	
		phase.drop_objection(this);
	endtask
	
endclass