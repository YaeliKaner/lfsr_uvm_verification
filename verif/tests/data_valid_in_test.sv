class data_valid_in_test extends base_test;
	`uvm_component_utils(data_valid_in_test)

	function new(string name = "data_valid_in_test", uvm_component parent = null);
    super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		for (int i=0; i<4; i++) begin

    	sanity_control_seq_i.current_poly = i;

    	sanity_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);

    	data_valid_in_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
		
		end
			
		phase.drop_objection(this);
	endtask
	
endclass