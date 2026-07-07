`uvm_analysis_imp_decl(_data)
`uvm_analysis_imp_decl(_control)

class lfsr_reference_model extends uvm_component;
    `uvm_component_utils(lfsr_reference_model)

    uvm_analysis_imp_data    #(data_seq_item, lfsr_reference_model) data_in_imp;
    uvm_analysis_imp_control #(control_seq_item, lfsr_reference_model) control_in_imp;
    uvm_analysis_port        #(data_seq_item) expected_ap;

    control_seq_item control_item;
    data_seq_item    active_data_in;

    logic [31:0] polynomial_mask;
    logic [31:0] LFSR_REG_REF; 
    logic        feedback;
    bit          control_valid;

    virtual data_if data_vif;

    function new(string name="lfsr_reference_model", uvm_component parent=null);
        super.new(name, parent);
        data_in_imp    = new("data_in_imp", this);
        control_in_imp = new("control_in_imp", this);
        expected_ap    = new("expected_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual data_if)::get(this, "*", "data_vif", data_vif))
            `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name()})
    endfunction


    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        wait(data_vif.reset_n == 0);
        LFSR_REG_REF   = '0;
        control_valid  = 0;
        control_item   = null;
        active_data_in = null;
        wait(data_vif.reset_n == 1);
    endtask


    task run_phase(uvm_phase phase);
        forever begin
            @(posedge data_vif.clk);
           	   #1;
            if (control_valid) begin
                if (active_data_in != null)
                    calc_expected();
                else if (control_item.seed_load)
                    LFSR_REG_REF = control_item.seed_value;
            end
        end
    endtask

    function void write_control(control_seq_item tr);
        if (control_item == null)
            control_item = control_seq_item::type_id::create("control_item");
        control_item.copy(tr);
        `uvm_info("CTRL_RX",
            $sformatf("seed_load=%0b seed=%h poly=%0d",
                tr.seed_load,
                tr.seed_value,
                tr.polynomial_select), UVM_LOW)
        control_valid = 1;
    endfunction

    function void write_data(data_seq_item tr);
        active_data_in = data_seq_item::type_id::create("active_data_in");
        active_data_in.copy(tr);
        `uvm_info("DATA_RX",
            $sformatf("data=%h", tr.data_in),
            UVM_LOW)
    endfunction

    function void calc_expected();
        data_seq_item expected_item;
        expected_item = data_seq_item::type_id::create("expected_item");
        expected_item.copy(active_data_in);

        case (control_item.polynomial_select)
            3'b000: polynomial_mask = 32'h00000091;
            3'b001: polynomial_mask = 32'h0000C001;
            3'b010: polynomial_mask = 32'h00840001;
            3'b011: polynomial_mask = 32'h90000001;
            default: polynomial_mask = 32'h0;
        endcase

        feedback = ^(LFSR_REG_REF & polynomial_mask);

        if (active_data_in.data_valid_in && active_data_in.ready_out) begin
            expected_item.data_valid_out = 1'b1;

            if (control_item.bypass_enable)
                expected_item.data_out = active_data_in.data_in;
            else
                expected_item.data_out = active_data_in.data_in ^ LFSR_REG_REF; // OLD LFSR

            `uvm_info("REF_DEBUG",
                $sformatf("data_in=%0h lfsr=%0h bypass=%0b seed_load=%0b result=%0h",
                    active_data_in.data_in,
                    LFSR_REG_REF,
                    control_item.bypass_enable,
                    control_item.seed_load,
                    expected_item.data_out),
                UVM_LOW)

            if (control_item.seed_load)
                LFSR_REG_REF = control_item.seed_value;
            else
                LFSR_REG_REF = {LFSR_REG_REF[30:0], feedback};

        end else begin
	        expected_item.data_out = 32'b0;
            expected_item.data_valid_out = 1'b0;

            if (control_item.seed_load)
                LFSR_REG_REF = control_item.seed_value;
        	end
		expected_ap.write(expected_item);
    endfunction
endclass