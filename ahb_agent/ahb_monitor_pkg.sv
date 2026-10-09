package ahb_monitor_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"

	import ahb_config_pkg::*;
	
	import ahb_sequence_item_pkg::*;
	
	typedef ahb_sequence_item#(16) ahb_seq_item_t;

	class ahb_monitor extends uvm_monitor;

		`uvm_component_utils(ahb_monitor)

		virtual ahb_if ahb_vif;

		ahb_config ahb_cfg;

		uvm_analysis_port #(ahb_seq_item_t) ahb_aport;

		function new(string name = "ahb_monitor" , uvm_component parent);
			super.new(name,parent);
		 endfunction : new 

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			ahb_aport = new("ahb_aport",this);

			`uvm_info(get_type_name(),"ahb_monitor_build_phase",UVM_LOW)

			if (!uvm_config_db#(ahb_config)::get(this,"","ahb_cfg",ahb_cfg)) begin
				`uvm_fatal(get_type_name(),"Failed to get the configuration from database")
			end	
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);

			`uvm_info(get_type_name(),"ahb_monitor_connect_phase",UVM_LOW);

			ahb_vif = ahb_cfg.ahb_vif;
		endfunction : connect_phase

		task run_phase(uvm_phase phase);
			
			ahb_seq_item_t pending_item;
			ahb_seq_item_t current_item;

			int unsigned wait_states = 0;

			`uvm_info(get_type_name(),"ahb_monitor_run_phase",UVM_LOW);

			forever begin

				@(ahb_vif.mon_cb);

				if(ahb_vif.HRESETn !== 1'b1) begin
					pending_item = null;

					wait_states = 0;

					continue;	
				end

				if (pending_item != null) begin
					if (ahb_vif.mon_cb.HREADY === 1'b1) begin
						//if (pending_item.HWRITE == 1'b1) begin
							pending_item.HWDATA = ahb_vif.mon_cb.HWDATA;
						//end
						//else begin
							pending_item.HRDATA = ahb_vif.mon_cb.HRDATA;
						//end

						pending_item.HRESP = ahb_vif.mon_cb.HRESP;
						pending_item.wait_states = wait_states;

						`uvm_info(get_type_name,pending_item.convert2string(),UVM_MEDIUM)

                        ahb_aport.write(pending_item);

						pending_item = null;

						wait_states = 0;
					end
					else begin
						wait_states++;
					end
				end

				if (ahb_vif.mon_cb.HREADY === 1'b1 && ahb_vif.mon_cb.HSEL === 1'b1 && ahb_vif.mon_cb.HTRANS[1] === 1'b1) begin
					current_item = ahb_seq_item_t::type_id::create("current_item");

					current_item.HSEL   = ahb_vif.mon_cb.HSEL;
					current_item.HADDR  = ahb_vif.mon_cb.HADDR;
					current_item.HWRITE = ahb_vif.mon_cb.HWRITE;
					current_item.HTRANS = ahb_vif.mon_cb.HTRANS;
					current_item.HSIZE  = ahb_vif.mon_cb.HSIZE;
					current_item.HPROT  = ahb_vif.mon_cb.HPROT;

					pending_item = current_item ;

					wait_states = 0;
				end

			end 
			
		endtask : run_phase
	
	endclass : ahb_monitor	
	
endpackage : ahb_monitor_pkg