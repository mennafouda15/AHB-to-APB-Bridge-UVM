package ahb_sequencer_pkg;

    import uvm_pkg::*;

	`include "uvm_macros.svh"

	import ahb_sequence_item_pkg::*;    

	typedef ahb_sequence_item#(16) ahb_seq_item_t;

	class ahb_sequencer extends  uvm_sequencer#(ahb_seq_item_t);

		`uvm_component_utils(ahb_sequencer)

		function new(string name = "ahb_sequencer" , uvm_component parent);
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			`uvm_info(get_type_name(),"ahb_sequencer_build_phase",UVM_LOW)	
		endfunction : build_phase
		
	endclass : ahb_sequencer
	
endpackage : ahb_sequencer_pkg