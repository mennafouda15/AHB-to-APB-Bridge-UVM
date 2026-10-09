package ahb2apb_scoreboard_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"

	import ahb_sequence_item_pkg::*;  

	import apb_sequence_item_pkg::*;

	import ahb2apb_comparator_pkg::*;

	import ahb2apb_ahb_predictor_pkg::*;
	
	import ahb2apb_apb_predictor_pkg::*;

	typedef ahb_sequence_item #(16) ahb_seq_item_t;
    typedef apb_sequence_item #(16) apb_seq_item_t;

	class ahb2apb_scoreboard extends uvm_scoreboard;
	
		`uvm_component_utils(ahb2apb_scoreboard)

		uvm_analysis_export #(ahb_seq_item_t) ahb_aexport; // from ahb agent
		uvm_analysis_export #(apb_seq_item_t) apb_aexport; // from apb agent

		ahb2apb_comparator cmp;

		ahb2apb_ahb_predictor ahb_prd;
		ahb2apb_apb_predictor apb_prd;

		function new(string name = "ahb2apb_scoreboard", uvm_component parent = null);
			super.new(name, parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			ahb_aexport = new("ahb_aexport", this);
			apb_aexport = new("apb_aexport", this);

			ahb_prd = ahb2apb_ahb_predictor::type_id::create("ahb_prd", this);
			apb_prd = ahb2apb_apb_predictor::type_id::create("apb_prd", this);

			cmp = ahb2apb_comparator::type_id::create("cmp", this);
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
			// connect seq_items to predictors
			apb_aexport.connect(ahb_prd.analysis_export);
			ahb_aexport.connect(apb_prd.analysis_export);

			// connect seq_items (actual) to comparator
			ahb_aexport.connect(cmp.ahb_act_aexport);
			apb_aexport.connect(cmp.apb_act_aexport);

			// connect predictors to comparator
			ahb_prd.ahb_exp_aport.connect(cmp.ahb_exp_aexport);
			apb_prd.apb_exp_aport.connect(cmp.apb_exp_aexport);
		endfunction : connect_phase

	endclass : ahb2apb_scoreboard
	
endpackage : ahb2apb_scoreboard_pkg

