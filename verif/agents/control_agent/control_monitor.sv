class control_monitor extends uvm_monitor;
	
	`uvm_component_utils(control_monitor)
	
	virtual control_if control_vif;
	
	uvm_analysis_port #(control_seq_item) control_ap;
	
	control_seq_item control_item;
	
	function new(string name = "control_monitor", uvm_component parent = null);
		super.new(name, parent);
		control_ap = new("control_ap", this);
	endfunction
	
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual control_if)::get(this, "", "control_vif", control_vif))
			`uvm_fatal("NO_VIF", {"virtual interface must be set for: ",get_full_name(),".control_vif"})
		else
			`uvm_info("Build_phase", "control_vif set", UVM_LOW)
	endfunction
	
	
	task run_phase(uvm_phase phase);
		forever begin
			@(posedge control_vif.clk);
			if(control_vif.reset_n != 0) begin 
				control_item = control_seq_item::type_id::create("control_item", this);
				control_item.polynomial_select = control_vif.polynomial_select;
				control_item.seed_value= control_vif.seed_value;
				control_item.seed_load = control_vif.seed_load;
				control_item.bypass_enable = control_vif.bypass_enable;
				control_ap.write(control_item);		
			end
		end
	endtask
endclass