class data_seq_item extends uvm_sequence_item;
	
	rand bit [31:0] data_in;
	rand bit data_valid_in;
	rand bit ready_out;
	
	//outputs
	bit [31:0] data_out;
	bit data_valid_out;
	bit ready_in;
	
	`uvm_object_utils_begin(data_seq_item)
		`uvm_field_int(data_in, UVM_DEFAULT)
		`uvm_field_int(data_valid_in, UVM_DEFAULT)
		`uvm_field_int(ready_out, UVM_DEFAULT)
		`uvm_field_int(data_out, UVM_DEFAULT)
		`uvm_field_int(data_valid_out, UVM_DEFAULT)
		`uvm_field_int(ready_in, UVM_DEFAULT)
	`uvm_object_utils_end
	
	function new(string name = "data_seq_item");
		super.new(name);
	endfunction
	
	    constraint handshake_dist {
		    {data_valid_in, ready_out} dist{
		        2'b11 := 70,
		        2'b01 := 10,
		        2'b10 := 10,
		        2'b00 := 10
		     };
		   }
	 
endclass