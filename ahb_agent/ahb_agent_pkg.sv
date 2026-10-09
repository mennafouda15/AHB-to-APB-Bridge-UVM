package ahb_agent_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"

	import ahb_sequence_item_pkg::*;

    import ahb_monitor_pkg::*;
    
	import ahb_driver_pkg::*;

	import ahb_sequencer_pkg::*;
		
	import ahb_config_pkg::*;

	typedef ahb_sequence_item#(16) ahb_seq_item_t;
			
	class ahb_agent extends uvm_agent;

		`uvm_component_utils(ahb_agent)
		
		ahb_monitor   mon;
		ahb_driver    drv;
		ahb_sequencer seqr;

        ahb_config ahb_cfg;

		uvm_analysis_port #(ahb_seq_item_t) ahb_aport;

		function new(string name = "ahb_agent" , uvm_component parent);
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			`uvm_info(get_type_name(),"ahb_agent_build_phase",UVM_LOW);

			ahb_aport = new("ahb_aport",this);

			mon = ahb_monitor::type_id::create("mon",this);

			if (!uvm_config_db#(ahb_config)::get(this,"","ahb_cfg",ahb_cfg)) begin
				`uvm_fatal(get_type_name(),"Failed to get the configuration from database")
			end

			if (ahb_cfg.is_active == UVM_ACTIVE) begin
			drv = ahb_driver::type_id::create("drv",this);
			seqr = ahb_sequencer::type_id::create("seqr",this);
			end			
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);

			`uvm_info(get_type_name(),"ahb_agent_connect_phase",UVM_LOW);

			mon.ahb_aport.connect(ahb_aport);

			if (ahb_cfg.is_active == UVM_ACTIVE) begin
			drv.seq_item_port.connect(seqr.seq_item_export);
			end						
		endfunction : connect_phase

	endclass : ahb_agent
       
endpackage : ahb_agent_pkg