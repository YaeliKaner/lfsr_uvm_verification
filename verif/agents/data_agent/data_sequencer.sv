class data_sequencer extends uvm_sequencer#(data_seq_item);
  `uvm_component_utils(data_sequencer)
  
  function new(string name="data_sequencer", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
endclass