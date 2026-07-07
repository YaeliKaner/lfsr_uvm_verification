class corner_case_data_test extends base_test;
	`uvm_component_utils(corner_case_data_test)
	
	corner_case_data_seq corner_case_data_seq_i;
	sanity_control_seq sanity_control_seq_i;
	
	function new(string name = "corner_case_data_test", uvm_component parent = null);
    super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		sanity_control_seq_i = sanity_control_seq::type_id::create("sanity_control_seq_i");
		corner_case_data_seq_i    = corner_case_data_seq::type_id::create("corner_case_data_seq_i");

		phase.raise_objection(this);
		
		for (int i=0; i<4; i++) begin
	  
	    	sanity_control_seq_i.current_poly = i;
	
	    	sanity_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
	
	    	corner_case_data_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
		
		end
			
		phase.drop_objection(this);
	endtask
	
endclass