class data_monitor extends uvm_monitor;
  `uvm_component_utils(data_monitor)
  
  virtual data_if data_vif;
  
  uvm_analysis_port #(data_seq_item) data_in_ap;
  uvm_analysis_port #(data_seq_item) data_out_ap;
  
  data_seq_item data_in_item;
  data_seq_item data_out_item;
  
  function new(string name="data_monitor", uvm_component parent=null);
    super.new(name, parent);
    data_in_ap=new("data_in_ap",this);
    data_out_ap=new("data_out_ap",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual data_if)::get(this,"*","data_vif",data_vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for:",get_full_name(),".data_vif"})
    else
      `uvm_info("Build_phase", "data_vif set", UVM_LOW)
  endfunction

	task run_phase(uvm_phase phase);
	        fork
	            data_in();
		      
	            data_out();
	        join
	endtask
    
    task data_in();
        forever begin
            @(posedge data_vif.clk);
            if(data_vif.reset_n) begin
                    data_in_item = data_seq_item::type_id::create("data_in_item", this);
                    
                    data_in_item.data_in       = data_vif.data_in;
                    data_in_item.ready_out     = data_vif.ready_out;
                    data_in_item.data_valid_in = data_vif.data_valid_in; 

                    data_in_ap.write(data_in_item);
            end
        end
    endtask
    
    task data_out();
        forever begin
            @(posedge data_vif.clk);
	        #1;           
            if(data_vif.reset_n) begin
                    data_out_item = data_seq_item::type_id::create("data_out_item", this);
                    
                    data_out_item.data_out       = data_vif.data_out;
                    data_out_item.data_valid_out = data_vif.data_valid_out;
                    data_out_item.ready_in       = data_vif.ready_in;
                    
                    data_out_ap.write(data_out_item);
           end
        end
    endtask
endclass