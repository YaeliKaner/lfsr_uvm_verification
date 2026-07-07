`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class lfsr_scoreboard extends uvm_component;
    `uvm_component_utils(lfsr_scoreboard)

    uvm_analysis_imp_expected #(data_seq_item, lfsr_scoreboard) expected_imp;
    uvm_analysis_imp_actual #(data_seq_item, lfsr_scoreboard) actual_imp;

    data_seq_item exp_q[$];
    data_seq_item act_q[$];

    data_seq_item expected_data;
    data_seq_item actual_data;
	
	int expected_counter;
    int actual_counter;

    function new(string name = "lfsr_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        expected_imp = new("expected_imp", this);
        actual_imp   = new("actual_imp", this);
    endfunction

function void write_expected(data_seq_item tr);

    data_seq_item tmp;

    tmp = data_seq_item::type_id::create("tmp");
    tmp.copy(tr);

    exp_q.push_back(tmp);
	expected_counter++;

    if(act_q.size()>0 && exp_q.size()>0)
        compare();

endfunction

function void write_actual(data_seq_item tr);

    data_seq_item tmp;

    tmp = data_seq_item::type_id::create("tmp");
    tmp.copy(tr);
    act_q.push_back(tmp);
	actual_counter++;

    if(act_q.size()>0 && exp_q.size()>0)
        compare();

endfunction

    function void compare();
	        while(act_q.size()>0 && exp_q.size()>0) begin

            expected_data = exp_q.pop_front();
            actual_data   = act_q.pop_front();

            if (expected_data.data_valid_out != actual_data.data_valid_out)
    			`uvm_error("SB_VALID_MISMATCH",
        				  $sformatf("Expected valid=%0b Actual valid=%0b",
                  expected_data.data_valid_out,
                  actual_data.data_valid_out));
		    	
            if(expected_data.data_out == actual_data.data_out)
                `uvm_info("SB_MATCH",
                          $sformatf("MATCH! Expected: %0h, Got: %0h",
                                    expected_data.data_out,
                                    actual_data.data_out),
                          			UVM_LOW)
            else
                `uvm_error("SB_MISMATCH",
                           $sformatf("MISMATCH! Expected: %0h, Got: %0h",
                                     expected_data.data_out,
                                     actual_data.data_out))
        	end
    endfunction
    
    function void check_phase(uvm_phase phase);
	    super.check_phase(phase);
	   if(expected_counter != actual_counter) begin
   			`uvm_error("SB_MISMATCH_COUNTER",
                           $sformatf("MISMATCH_COUNTER! expected_counter: %0d, actual_counter: %0d",
                                     expected_counter,
                                     actual_counter))
	   end
    endfunction
endclass