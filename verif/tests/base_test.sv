class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  // 1. control sequences
  sanity_control_seq    sanity_control_seq_i;
  bypass_control_seq    bypass_control_seq_i;
  seed_load_control_seq seed_load_control_seq_i;
  random_control_seq    random_control_seq_i;

  // =======================================================================
  // 2. data sequences
  sanity_data_seq       sanity_data_seq_i;
  data_valid_in_seq     data_valid_in_seq_i;
  ready_out_seq         ready_out_seq_i;
  corner_case_data_seq  corner_case_data_seq_i;
  random_data_seq       random_data_seq_i;

  lfsr_env              lfsr_env_i;


  function new(string name = "base_test", uvm_component parent = null);
     super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     
     // Environment
     lfsr_env_i = lfsr_env::type_id::create("lfsr_env_i", this);

     //  control
     sanity_control_seq_i    = sanity_control_seq::type_id::create("sanity_control_seq_i");
     bypass_control_seq_i    = bypass_control_seq::type_id::create("bypass_control_seq_i");
     seed_load_control_seq_i = seed_load_control_seq::type_id::create("seed_load_control_seq_i");
     random_control_seq_i    = random_control_seq::type_id::create("random_control_seq_i");

	//  data
     sanity_data_seq_i       = sanity_data_seq::type_id::create("sanity_data_seq_i");
     data_valid_in_seq_i     = data_valid_in_seq::type_id::create("data_valid_in_seq_i");
     ready_out_seq_i         = ready_out_seq::type_id::create("ready_out_seq_i");
     corner_case_data_seq_i  = corner_case_data_seq::type_id::create("corner_case_data_seq_i");
     random_data_seq_i       = random_data_seq::type_id::create("random_data_seq_i");

  endfunction

endclass