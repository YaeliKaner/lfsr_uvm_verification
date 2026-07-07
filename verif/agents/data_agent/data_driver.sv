class data_driver extends uvm_driver #(data_seq_item);
  
  `uvm_component_utils(data_driver)
  
  virtual data_if data_vif;
  
  function new(string name = "data_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual data_if)::get(this, "", "data_vif", data_vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".data_vif"})
    else
      `uvm_info("Build_phase", "data_vif set", UVM_LOW)
  endfunction
        
  task run_phase(uvm_phase phase);
	 fork
        begin
            forever begin
                if(!data_vif.reset_n)
                    reset_drive_data();
                @(negedge data_vif.reset_n);
                reset_drive_data();
            end
        end
	  begin
    forever begin   
      seq_item_port.get_next_item(req);
	     wait(data_vif.reset_n == 1);    
	    drive_data();
      seq_item_port.item_done();
    end  
    end
	   join

  endtask
    
    task drive_data();
	    @(posedge data_vif.clk iff data_vif.ready_in)
	   		data_vif.data_in <= req.data_in;
			data_vif.data_valid_in <= req.data_valid_in;
			data_vif.ready_out <= req.ready_out;
    endtask

  	task reset_drive_data();
	   		data_vif.data_in <= 32'b0;
			data_vif.data_valid_in <=  1'b0;
			data_vif.ready_out <= 1'b0;
  	endtask
endclass