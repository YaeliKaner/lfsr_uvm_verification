class lfsr_env extends uvm_env;
	`uvm_component_utils(lfsr_env)
	
	control_agent control_agent_i;
	data_agent data_agent_i;
	lfsr_scoreboard lfsr_scoreboard_i;
	lfsr_reference_model lfsr_reference_model_i;
	lfsr_coverage lfsr_coverage_i;
	
	function new(string name = "lfsr_env", uvm_component parent = null);
		super.new(name, parent);
	endfunction

    function void build_phase(uvm_phase phase);
	    super.build_phase(phase);
	    control_agent_i = control_agent::type_id::create("control_agent_i", this);
	    data_agent_i = data_agent::type_id::create("data_agent_i", this);
	    lfsr_scoreboard_i = lfsr_scoreboard::type_id::create("lfsr_scoreboard_i", this);
	    lfsr_reference_model_i = lfsr_reference_model::type_id::create("lfsr_reference_model_i", this);
	    lfsr_coverage_i = lfsr_coverage::type_id::create("lfsr_coverage_i", this);
    endfunction
    
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		control_agent_i.control_monitor_i.control_ap.connect(lfsr_reference_model_i.control_in_imp);
		data_agent_i.data_monitor_i.data_in_ap.connect(lfsr_reference_model_i.data_in_imp);
		data_agent_i.data_monitor_i.data_out_ap.connect(lfsr_scoreboard_i.actual_imp);
		lfsr_reference_model_i.expected_ap.connect(lfsr_scoreboard_i.expected_imp);
		control_agent_i.control_monitor_i.control_ap.connect(lfsr_coverage_i.control_imp);
		data_agent_i.data_monitor_i.data_in_ap.connect(lfsr_coverage_i.data_imp);
		
	endfunction
endclass

