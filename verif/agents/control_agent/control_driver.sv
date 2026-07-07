class control_driver extends uvm_driver#(control_seq_item);
	`uvm_component_utils(control_driver)
	
	virtual control_if control_vif;
	
	function new(string name="control_driver", uvm_component parent=null);
	   super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual control_if)::get(this,"*","control_vif",control_vif))
		begin
			`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".control_vif"});
		end
		else begin
	    `uvm_info("Build_phase", "data_vif set", UVM_LOW)
	    end
	endfunction

task run_phase(uvm_phase phase);

    fork
        begin
            forever begin
                if(!control_vif.reset_n)
                    reset_drive_control();

                @(negedge control_vif.reset_n);
                reset_drive_control();
            end
        end

        begin
            forever begin
	            wait(control_vif.reset_n == 1);
                seq_item_port.get_next_item(req);
                drive_control();
                seq_item_port.item_done();
            end
        end
    join
endtask


  	task drive_control();
	  	@(posedge control_vif.clk)
	  	control_vif.polynomial_select<=req.polynomial_select;
	  	control_vif.seed_value<=req.seed_value;
	  	control_vif.seed_load<=req.seed_load;
	  	control_vif.bypass_enable<=req.bypass_enable;
  	endtask
  	
  	  task reset_drive_control();
	  	control_vif.polynomial_select <= 3'b0;
	  	control_vif.seed_value <= 32'b0;
	  	control_vif.seed_load <= 1'b0;
	  	control_vif.bypass_enable <= 1'b0;
  	endtask

endclass