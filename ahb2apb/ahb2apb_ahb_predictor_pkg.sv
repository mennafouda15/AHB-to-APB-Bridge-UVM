package ahb2apb_ahb_predictor_pkg;

    import uvm_pkg::*;

    `include "uvm_macros.svh"

    import ahb_sequence_item_pkg::*;   

    import apb_sequence_item_pkg::*;

    typedef ahb_sequence_item#(16) ahb_seq_item_t;
	typedef apb_sequence_item#(16) apb_seq_item_t;

	class ahb2apb_ahb_predictor extends uvm_subscriber #(apb_seq_item_t);
		`uvm_component_utils(ahb2apb_ahb_predictor)

		uvm_analysis_port #(ahb_seq_item_t) ahb_exp_aport;

		function new(string name = "ahb2apb_ahb_predictor", uvm_component parent = null);
			super.new(name, parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			ahb_exp_aport = new("ahb_exp_aport",this);
		endfunction : build_phase

		virtual function void write(apb_seq_item_t t);
			ahb_seq_item_t ahb_exp_seq_item;

			`uvm_info("DEBUG","Broadcast Ahb prediction using analysis port",UVM_HIGH); // check predictor is sending to the comparator

			ahb_exp_seq_item = ahb_seq_item_t::type_id::create("ahb_exp_seq_item");
			ahb_exp_out(t, ahb_exp_seq_item);
			ahb_exp_aport.write(ahb_exp_seq_item);
		endfunction : write

		// calculate expected ahb outputs
		function void ahb_exp_out(input apb_seq_item_t data_in, inout ahb_seq_item_t data_out);
			`uvm_info("DEBUG","AHB Expected Output Funtion Had Been Called",UVM_HIGH); // check predictor has called the calc function

			// HREADYOUT
			data_out.HREADYOUT = data_in.PREADY;

			// HRESP
			data_out.HRESP = data_in.PSLVERR;

			// HRDATA
			data_out.HRDATA = data_in.PRDATA;
		endfunction : ahb_exp_out

	endclass : ahb2apb_ahb_predictor
	
endpackage : ahb2apb_ahb_predictor_pkg