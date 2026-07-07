class regression_test extends base_test;

  `uvm_component_utils(regression_test)

  function new(string name = "regression_test", uvm_component parent = null);
     super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
     super.build_phase(phase); 
  endfunction    

  task run_phase(uvm_phase phase);

     phase.raise_objection(this);
 
   //1. sanity_test
    `uvm_info("REGRESSION", "Running Sanity test", UVM_LOW)

		for (int i = 0; i < 4; i++) begin 		
			sanity_control_seq_i.current_poly = i; 
			sanity_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
			sanity_data_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
		end	


     // 2.bypass mode
     `uvm_info("REGRESSION", "Running Bypass Mode test", UVM_LOW)

     for (int i = 0; i < 4; i++) begin 
         bypass_control_seq_i.current_poly = i; 
         fork
             bypass_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
             sanity_data_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
         join
     end	


     // 3. corner_case_data
     `uvm_info("REGRESSION", "Running Corner-Case Data test", UVM_LOW)

     for (int i = 0; i < 4; i++) begin
         sanity_control_seq_i.current_poly = i;
         sanity_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
         corner_case_data_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
     end


     // 4. data valid in
     `uvm_info("REGRESSION", "Running Data Valid In test", UVM_LOW)

     for (int i = 0; i < 4; i++) begin
         sanity_control_seq_i.current_poly = i;
         sanity_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
         data_valid_in_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
     end


     // 5.Random
     `uvm_info("REGRESSION", "Running Random Control and Data", UVM_LOW)
	fork
     random_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
     random_data_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
	join


     // 6.seed load
     `uvm_info("REGRESSION", "Running Seed Loading test", UVM_LOW)

	   for (int i = 0; i < 4; i++) begin
		    seed_load_control_seq_i.current_poly = i;
            seed_load_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
            sanity_data_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);
		end

     
       //7. ready_out
     `uvm_info("REGRESSION", "Running ready out test", UVM_LOW)

		for (int i = 0; i < 4; i++) begin
			sanity_control_seq_i.current_poly = i;

			sanity_control_seq_i.start(lfsr_env_i.control_agent_i.control_sequencer_i);
			ready_out_seq_i.start(lfsr_env_i.data_agent_i.data_sequencer_i);		
		end
     
     phase.drop_objection(this);

  endtask
  
endclass