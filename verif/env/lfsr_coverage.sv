`uvm_analysis_imp_decl(_control_ap)
`uvm_analysis_imp_decl(_data_ap)

class lfsr_coverage extends uvm_component;
    `uvm_component_utils(lfsr_coverage)

    // Analysis ports - receive transactions from monitors
    uvm_analysis_imp_control_ap #(control_seq_item, lfsr_coverage) control_imp;
    uvm_analysis_imp_data_ap    #(data_seq_item,    lfsr_coverage) data_imp;

    // Local copies of last received transactions
    control_seq_item control_item;
    data_seq_item    data_item;

    covergroup lfsr_cg;

        polynomial_sel: coverpoint control_item.polynomial_select {
            bins poly_000 = {3'b000};  // x^7  + x^4  + 1 - Basic scrambling
            bins poly_001 = {3'b001};  // x^15 + x^14 + 1 - Medium security
            bins poly_010 = {3'b010};  // x^23 + x^18 + 1 - Enhanced randomization
            bins poly_011 = {3'b011};  // x^31 + x^28 + 1 - High randomization
        }


        seed_load_en: coverpoint control_item.seed_load {
            bins seed_loading = {1'b1};  // seed is being loaded
            bins no_seed_load = {1'b0};  // normal operation
        }


        // bypass_enable=1 -> Bypass Mode (No Scrambling)
        // bypass_enable=0 -> Standard Scrambling
        bypass_en: coverpoint control_item.bypass_enable {
            bins bypass_on  = {1'b1};  // Bypass Mode - data_out = data_in
            bins bypass_off = {1'b0};  // Standard Scrambling Mode
        }


        data_valid: coverpoint data_item.data_valid_in {
            bins valid     = {1'b1};  // valid data on input
            bins not_valid = {1'b0};  // no valid data
        }


        ready: coverpoint data_item.ready_out {
            bins ready     = {1'b1};  // downstream ready
            bins not_ready = {1'b0};  // downstream not ready 
        }


		seed_val: coverpoint control_item.seed_value {
			   bins seed_low  = {[32'h00000000 : 32'h55555554]}; 
			   bins seed_mid  = {[32'h55555555 : 32'hAAAAAAAA]}; 
			   bins seed_high = {[32'hAAAAAAAA : 32'hFFFFFFFF]}; 
		}


        data_val: coverpoint data_item.data_in {
            bins data_zero  = {32'h00000000};                   // all zeros
            bins data_ones  = {32'hFFFFFFFF};                   // all ones
            bins data_low   = {[32'h00000001 : 32'h0000FFFF]};  // low values
            bins data_mid   = {[32'h00010000 : 32'hFFFEFFFF]};  // mid values
            bins data_high  = {[32'hFFFF0000 : 32'hFFFFFFFE]};  // high values
        }

        // cross coverage - combinations

        valid_ready_cross: cross data_valid, ready;

        seed_bypass_cross: cross seed_load_en, bypass_en;

    endgroup

    function new(string name="lfsr_coverage", uvm_component parent=null);
        super.new(name, parent);
        lfsr_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        control_imp  = new("control_imp", this);
        data_imp     = new("data_imp",    this);
        control_item = control_seq_item::type_id::create("control_item");
        data_item    = data_seq_item::type_id::create("data_item");
    endfunction

    function void write_control_ap(control_seq_item tr);
        control_item.copy(tr);
        lfsr_cg.sample();
        `uvm_info("COVERAGE",
            $sformatf("Control sampled: poly=%0b seed_load=%0b bypass=%0b seed=%0h",
                tr.polynomial_select,
                tr.seed_load,
                tr.bypass_enable,
                tr.seed_value),
            UVM_HIGH)
    endfunction


    function void write_data_ap(data_seq_item tr);
        data_item.copy(tr);
        lfsr_cg.sample();
        `uvm_info("COVERAGE",
            $sformatf("Data sampled: data_in=%0h valid_in=%0b ready_out=%0b",
                tr.data_in,
                tr.data_valid_in,
                tr.ready_out),
            UVM_HIGH)
    endfunction


    //report 
    function void report_phase(uvm_phase phase);
        `uvm_info("COVERAGE",
            $sformatf("=== LFSR Functional Coverage: %.2f%% ===",
                lfsr_cg.get_coverage()),
            UVM_LOW)
    endfunction

endclass