package ahb_unmatched_req_reset_sequence_pkg;

	import uvm_pkg::*;
	import ahb_base_sequence_pkg::*;
	import ahb_sequence_item_pkg::*;

	`include "uvm_macros.svh"

	typedef enum {RESET_AHB_ONLY, RESET_APB_GLITCH} unmatched_req_mode_e;

	class ahb_unmatched_req_reset_sequence #(parameter ADDRWIDTH = 16) extends ahb_base_sequence;
		`uvm_object_utils(ahb_unmatched_req_reset_sequence)

		virtual ahb_if ahb_vif;
		virtual apb_if apb_vif;

		unmatched_req_mode_e mode              = RESET_AHB_ONLY;
		int                  settle_cycles     = 10; // HCLK cycles to let req/ack settle after the transfer
		int                  ahb_rst_cycles    = 2;  // HCLK cycles HRESETn is held low (RESET_AHB_ONLY)

		// APBACTIVE = req_detect | curr_state[0].  With PSEL low this is the
		// "request seen but s_trans_valid_reg == 0" window (req_detect cycle,
		// then the CYC1 cycle), so >= 2 cycles means the branch was taken.

		function new(string name = "ahb_unmatched_req_reset_sequence");
			super.new(name);
		endfunction : new

		virtual task body();

			ahb_sequence_item #(ADDRWIDTH) rd_item, idle_item;

			if (!uvm_config_db#(virtual ahb_if)::get(null, "", "ahb_vif", ahb_vif))
				`uvm_fatal(get_type_name(), "Cannot get AHB virtual interface")

			if (!uvm_config_db#(virtual apb_if)::get(null, "", "apb_vif", apb_vif))
				`uvm_fatal(get_type_name(), "Cannot get APB virtual interface")

			`uvm_info(get_type_name(),$sformatf("Starting unmatched-req reset sequence, mode = %s", mode.name()), UVM_LOW)

			// known starting point: s_req_h = s_ack_h = 0 
			ahb_vif.HRESETn = 1'b0;
			apb_vif.PRESETn = 1'b0;
			repeat (2) @(posedge ahb_vif.HCLK);
			ahb_vif.HRESETn = 1'b1;
			apb_vif.PRESETn = 1'b1;
			repeat (4) @(posedge ahb_vif.HCLK);

			// exactly ONE transfer -> s_req_h toggles once (0 -> 1)
			rd_item = ahb_sequence_item #(ADDRWIDTH)::type_id::create("rd_item");
			start_item(rd_item);
			if (!rd_item.randomize() with {
					HSEL   == 1'b1;
					HTRANS == 2'b10; 
					HWRITE == 1'b0;
				})
				`uvm_fatal(get_type_name(), "read item randomize() failed")
			finish_item(rd_item);

			// IDLE item: driver keeps it on the bus until HREADY=1, i.e. until the
			// data phase (and so the whole req/ack handshake) has completed.
			idle_item = ahb_sequence_item #(ADDRWIDTH)::type_id::create("idle_item");
			start_item(idle_item);
			if (!idle_item.randomize() with {
					HSEL   == 1'b0;
					HTRANS == 2'b00;
					HWRITE == 1'b0;
				})
				`uvm_fatal(get_type_name(), "idle item randomize() failed")
			finish_item(idle_item);

			// let req/ack settle on both sides, bus idle
			repeat (settle_cycles) @(posedge ahb_vif.HCLK);

			// create the req/ack mismatch with a one-sided reset

			case (mode)

				RESET_AHB_ONLY : begin

					`uvm_info(get_type_name(), "Pulsing HRESETn only (PRESETn stays high)", UVM_MEDIUM)
					ahb_vif.HRESETn = 1'b0;
					repeat (ahb_rst_cycles) @(posedge ahb_vif.HCLK);
					ahb_vif.HRESETn = 1'b1;

				end

				RESET_APB_GLITCH : begin

					`uvm_info(get_type_name(), "Glitching PRESETn only (HRESETn stays high)", UVM_MEDIUM)
					@(posedge apb_vif.PCLK);
					apb_vif.PRESETn = 1'b0;
					#1ns; // glitch width
					apb_vif.PRESETn = 1'b1;
				end

			endcase

			// let the bridge fully recover before the next sequence
			repeat (settle_cycles) @(posedge ahb_vif.HCLK);

		endtask : body

	endclass : ahb_unmatched_req_reset_sequence

endpackage : ahb_unmatched_req_reset_sequence_pkg