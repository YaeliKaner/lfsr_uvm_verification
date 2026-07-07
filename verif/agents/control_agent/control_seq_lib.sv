class sanity_control_seq extends uvm_sequence;
	`uvm_object_utils(sanity_control_seq)
	
	control_seq_item req;
	
	bit [31:0] saved_seed;
	rand bit [2:0] current_poly;

	function new(string name="sanity_control_seq");
		super.new(name);
	endfunction
	
	task body();
			`uvm_do_with(req, {seed_load == 1'b1; bypass_enable == 1'b0; polynomial_select == current_poly;});
			`uvm_info(get_type_name(), $sformatf("Running sanity_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)			
		
		saved_seed=req.seed_value;
		
			`uvm_do_with(req, {seed_load == 1'b0; bypass_enable == 1'b0; polynomial_select == current_poly; seed_value == saved_seed;});
			`uvm_info(get_type_name(), $sformatf("Running sanity_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)			
	endtask

endclass


//===============================//
class bypass_control_seq extends uvm_sequence;
	`uvm_object_utils(bypass_control_seq)
	
	control_seq_item req;
	
	bit [31:0] saved_seed;
	rand bit [2:0] current_poly;

	function new(string name="bypass_control_seq");
		super.new(name);
	endfunction
	
	task body();
		
			`uvm_do_with(req, {seed_load == 1'b1; bypass_enable == 1'b1; polynomial_select == current_poly;});
			`uvm_info(get_type_name(), $sformatf("Running bypass_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)			
		
		saved_seed=req.seed_value;
		
		repeat(3) begin
			`uvm_do_with(req, {seed_load == 1'b0; bypass_enable == 1'b1; polynomial_select == current_poly; seed_value == saved_seed;});
			`uvm_info(get_type_name(), $sformatf("Running bypass_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)	
		end
		repeat(5) begin
			`uvm_do_with(req, {seed_load == 1'b0; bypass_enable == 1'b0; polynomial_select == current_poly; seed_value == saved_seed;});
			`uvm_info(get_type_name(), $sformatf("Running bypass_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)		
		end
		
	endtask
	
endclass

//===============================//

class seed_load_control_seq extends uvm_sequence;
	`uvm_object_utils(seed_load_control_seq)
	
	control_seq_item req;
	bit [31:0] saved_seed;
	rand bit [2:0] current_poly;

	function new(string name="seed_load_control_seq");
		super.new(name);
	endfunction
	
	task body();
		repeat(3) begin 
			`uvm_do_with(req, {seed_load == 1'b1; bypass_enable == 1'b0; polynomial_select == current_poly;});
			`uvm_info(get_type_name(), $sformatf("Running seed_load_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)			
		end
		
		saved_seed=req.seed_value;
		
			`uvm_do_with(req, {seed_load == 1'b0; bypass_enable == 1'b0; polynomial_select == current_poly; seed_value == saved_seed;});
			`uvm_info(get_type_name(), $sformatf("Running seed_load_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)			
				
	endtask
endclass

//===============================//

class random_control_seq extends uvm_sequence;
	`uvm_object_utils(random_control_seq)
	
	control_seq_item req;
	control_seq_item saved_req;
	rand bit [2:0] current_poly;

	function new(string name="random_control_seq");
		super.new(name);
	endfunction
	
	task body();
			`uvm_do_with(req, {seed_load == 1'b1; polynomial_select == current_poly;});
			`uvm_info(get_type_name(), $sformatf("Running random_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)			
		saved_req = req;
			`uvm_do_with(req, {seed_load == 1'b0; bypass_enable == saved_req.bypass_enable;  polynomial_select == saved_req.polynomial_select; seed_value == saved_req.seed_value;});
			`uvm_info(get_type_name(), $sformatf("Running random_control_seq sequence: seed_load = %0d, seed_value = %0d, polynomial_select = %0d, bypass_enable = %0d", 
					req.seed_load, req.seed_value, req.polynomial_select, req.bypass_enable), UVM_LOW)			
				
	endtask
endclass