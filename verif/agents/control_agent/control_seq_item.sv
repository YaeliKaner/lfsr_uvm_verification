class control_seq_item extends uvm_sequence_item;
	rand bit [2:0] polynomial_select;
	rand bit [31:0] seed_value;
	rand bit seed_load;
	rand bit bypass_enable;
	
	`uvm_object_utils_begin(control_seq_item)
		`uvm_field_int(polynomial_select,UVM_DEFAULT)
		`uvm_field_int(seed_value,UVM_DEFAULT)
		`uvm_field_int(seed_load,UVM_DEFAULT)
		`uvm_field_int(bypass_enable,UVM_DEFAULT)
	`uvm_object_utils_end	
		
	function new(string name="control_seq_item");
		super.new(name);
	endfunction
	
	constraint seed_val {seed_value != 32'b0;}
	constraint polynomial_sel {polynomial_select inside {3'b000,3'b001,3'b010,3'b011};}
	
endclass