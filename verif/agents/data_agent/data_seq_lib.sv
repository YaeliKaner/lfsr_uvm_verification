class sanity_data_seq extends uvm_sequence;
	`uvm_object_utils(sanity_data_seq)
	
	data_seq_item req;
   rand int unsigned num_transactions;
      	    
	
	function new(string name="sanity_data_seq");
		super.new(name);
	endfunction
	
	 constraint c_num {num_transactions inside {[50:500]};}
	
	task body();
		 if(!this.randomize())
			`uvm_fatal(get_type_name(), "Seq randomization failed")
      	    repeat(num_transactions) begin
			`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1;});
			`uvm_info(get_type_name(), $sformatf("Running sanity_data_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
	end
	endtask
endclass

//================================//

class data_valid_in_seq extends uvm_sequence;
    `uvm_object_utils(data_valid_in_seq)

    data_seq_item req;

 function new(string name="data_valid_in_seq");
        super.new(name);
    endfunction

    task body();
	        `uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1;});
			`uvm_info(get_type_name(), $sformatf("Running data_valid_in_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
      	    
      	     //Hold data_valid_in low for several cycles to verify that
           // the DUT does not generate valid output while input data is invalid.
      	    repeat (3) begin
       		`uvm_do_with(req, {data_valid_in == 1'b0; ready_out == 1'b1;});
			`uvm_info(get_type_name(), $sformatf("Running data_valid_in_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
			end
				
		    `uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1;});
			`uvm_info(get_type_name(), $sformatf("Running data_valid_in_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)	    
    endtask
endclass

//================================//

class ready_out_seq extends uvm_sequence;
    `uvm_object_utils(ready_out_seq)

    data_seq_item req;
 

 function new(string name="ready_out_seq");
        super.new(name);
    endfunction

   task body();
      	    
       		`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1;});
			`uvm_info(get_type_name(), $sformatf("Running ready_out_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
			repeat(3) begin
			`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b0;});
			`uvm_info(get_type_name(), $sformatf("Running ready_out_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
			end	
			`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1;});
			`uvm_info(get_type_name(), $sformatf("Running ready_out_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
    endtask
endclass

//================================//

class corner_case_data_seq extends uvm_sequence;
    `uvm_object_utils(corner_case_data_seq)

    data_seq_item req;


 function new(string name="corner_case_data_seq");
        super.new(name);
    endfunction

   task body();
      	    
      	    repeat(3) begin
       		`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1; data_in == 32'h0;});
			`uvm_info(get_type_name(), $sformatf("Running corner_case_data_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
      	    end
			repeat(3) begin
			`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1; data_in == 32'hFFFFFFFF;});
			`uvm_info(get_type_name(), $sformatf("Running corner_case_data_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
			end	
			//high values
			repeat(3) begin
			`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b1;
             data_in inside { [32'hFFFF0000 : 32'hFFFFFFFE]};})
            `uvm_info(get_type_name(), $sformatf("DATA_HIGH: data_in = 0x%08h", req.data_in), UVM_LOW)
			end	
			//ready_out = 0
			repeat(3) begin
			`uvm_do_with(req, {data_valid_in == 1'b1; ready_out == 1'b0;});
            `uvm_info(get_type_name(), $sformatf("DATA_HIGH: data_in = 0x%08h", req.data_in), UVM_LOW)
			end
			repeat(3) begin
			`uvm_do_with(req, {data_valid_in == 1'b0; ready_out == 1'b0;});
            `uvm_info(get_type_name(), $sformatf("DATA_HIGH: data_in = 0x%08h", req.data_in), UVM_LOW)
			end	
    endtask
endclass

//================================//

class random_data_seq extends uvm_sequence;
    `uvm_object_utils(random_data_seq)

    data_seq_item req;
	rand int unsigned num_transactions;


 function new(string name="random_data_seq");
        super.new(name);
 endfunction
 constraint c_num { num_transactions inside {[50:500]}; }

   task body();
      	     if(!this.randomize())
            `uvm_fatal(get_type_name(), "Seq randomization failed")
      	    repeat(num_transactions) begin
       		`uvm_do(req);
			`uvm_info(get_type_name(), $sformatf("Running random_data_seq sequence: data_in = %0d, data_valid_in = %0d, ready_out = %0d",
					req.data_in, req.data_valid_in, req.ready_out), UVM_LOW)
      	    end
    endtask
endclass