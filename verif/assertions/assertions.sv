module lfsr_assertions (

    input logic         clk,
    input logic         reset_n,

    input logic [31:0]  data_in,
    input logic [31:0]  data_out,

    input logic         data_valid_in,
    input logic         data_valid_out,

    input logic         ready_in,
    input logic         ready_out,

    input logic [2:0]   polynomial_select,

    input logic         seed_load,
    input logic [31:0]  seed_value,

    input logic [31:0]  LFSR_REG

);


// 1. Seed Value Validity
property p_seed_value_valid;
    @(posedge clk)
    seed_load |-> (seed_value != 32'd0);
endproperty

assert property (p_seed_value_valid)
else
    $error("ASSERTION FAILED: Illegal seed value (seed_value = 0)");


// 2. Seed Loading Operation
property p_seed_load;
    @(posedge clk)
    disable iff (!reset_n)
    seed_load |=> (LFSR_REG == seed_value);
endproperty

assert property (p_seed_load)
else
    $error("ASSERTION FAILED: Seed value was not loaded into LFSR");


// 3. Reset Behavior
property p_reset_behavior;
    @(posedge clk)
    !reset_n |=> (data_valid_out == 1'b0);
endproperty

assert property (p_reset_behavior)
else
    $error("ASSERTION FAILED: data_valid_out asserted during reset");


// 4. Polynomial Selection Range
property p_polynomial_select;
    @(posedge clk)
    polynomial_select inside {[3'b000:3'b011]};
endproperty

assert property (p_polynomial_select)
else
    $error("ASSERTION FAILED: Unsupported polynomial selected");


// 5. LFSR Shall Never Enter All-Zero State
property p_lfsr_not_zero;
    @(posedge clk)
    disable iff (!reset_n)
    (LFSR_REG != 32'd0);
endproperty

assert property (p_lfsr_not_zero)
else
    $error("ASSERTION FAILED: LFSR entered illegal all-zero state");

endmodule