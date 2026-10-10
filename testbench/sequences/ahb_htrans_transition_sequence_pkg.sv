package ahb_htrans_transition_sequence_pkg;

	import uvm_pkg::*;
	import ahb_base_sequence_pkg::*;
	import ahb_sequence_item_pkg::*;

	`include "uvm_macros.svh"

	class ahb_htrans_transition_sequence #(parameter ADDRWIDTH = 16) extends ahb_base_sequence;
		`uvm_object_utils(ahb_htrans_transition_sequence)

		function new(string name = "ahb_htrans_transition_sequence");
			super.new(name);
		endfunction : new

		virtual task body();
			
			ahb_sequence_item #(ADDRWIDTH) NONSEQ, SEQ, IDLE, BUSY;

			bit [31:0] current_addr;
		    bit [2:0]  current_size;
		    bit        current_write;
		    bit [3:0]  current_prot;

			`uvm_info(get_type_name(),"Starting Transition Sequence",UVM_LOW);
				
				// ============================================================
			    // 1. Start a normal transfer with NONSEQ
			    // ============================================================
			    NONSEQ = ahb_sequence_item #(ADDRWIDTH)::type_id::create("NONSEQ_1");

				start_item(NONSEQ);

				if (!(NONSEQ.randomize() with {
					HTRANS == 2'b10;
					HSEL   == 1'b1;
					})
					)
					`uvm_fatal(get_type_name(),"AHB transition nonseq randomize() failed")

				finish_item(NONSEQ);

				current_addr  = NONSEQ.HADDR;
				current_prot  = NONSEQ.HPROT;
				current_size  = NONSEQ.HSIZE;
				current_write = NONSEQ.HWRITE;

				// ============================================================
			    // 2. Continue with SEQ
			    // ============================================================

				repeat (3) begin

					SEQ = ahb_sequence_item #(ADDRWIDTH)::type_id::create("SEQ_1");

					start_item(SEQ);

					if (!(SEQ.randomize() with {
						HTRANS == 2'b11;
						HSEL   == 1'b1;
						HWRITE == current_write;
					    HSIZE  == current_size;
					    HPROT  == current_prot;
					    HADDR  == current_addr + (1 << current_size);
						})
					    )
						`uvm_fatal(get_type_name(),"AHB transition seq randomize() failed")

					finish_item(SEQ);

					current_addr  = SEQ.HADDR;
				end

				// ============================================================
			    // 3. Return to IDLE
			    // ============================================================

			    IDLE = ahb_sequence_item #(ADDRWIDTH)::type_id::create("IDLE_1");

				start_item(IDLE);

				if (!(IDLE.randomize() with {
					 HTRANS == 2'b00;
					 HSEL   == 1'b0;
				     HWRITE == 1'b0;
				     HSIZE  == 3'b000;
				     HADDR  == 32'h00000000;
					})
					)
					`uvm_fatal(get_type_name(),"AHB transition idle randomize() failed")

				finish_item(IDLE);

				// ============================================================
			    // 4. Start a new transfer with NONSEQ
			    // ============================================================

			    NONSEQ = ahb_sequence_item #(ADDRWIDTH)::type_id::create("NONSEQ_2");

				start_item(NONSEQ);

				if (!(NONSEQ.randomize() with {
					HTRANS == 2'b10;
					HSEL   == 1'b1;
					})
					)
					`uvm_fatal(get_type_name(),"AHB transition nonseq randomize() failed")

				finish_item(NONSEQ);

				current_addr  = NONSEQ.HADDR;
				current_prot  = NONSEQ.HPROT;
				current_size  = NONSEQ.HSIZE;
				current_write = NONSEQ.HWRITE;

				// ============================================================
			    // 5. Continue with SEQ
			    // ============================================================

				repeat (2) begin

					SEQ = ahb_sequence_item #(ADDRWIDTH)::type_id::create("SEQ_2");

					start_item(SEQ);

					if (!(SEQ.randomize() with {
						HTRANS == 2'b11;
						HSEL   == 1'b1;
						HWRITE == current_write;
					    HSIZE  == current_size;
					    HPROT  == current_prot;
					    HADDR  == current_addr + (1 << current_size);
						})
					    )
						`uvm_fatal(get_type_name(),"AHB transition seq randomize() failed")

					finish_item(SEQ);

					current_addr  = SEQ.HADDR;
				end

				// ============================================================
			    // 6. BUSY Cycle
			    // ============================================================
			    
			    BUSY = ahb_sequence_item #(ADDRWIDTH)::type_id::create("BUSY_1");

				start_item(BUSY);

				if (!(BUSY.randomize() with {
					HTRANS == 2'b01;
					HSEL   == 1'b1;
					})
					)
					`uvm_fatal(get_type_name(),"AHB transition busy randomize() failed")

				finish_item(BUSY);

				// ============================================================
			    // 7. SEQ after BUSY
			    // ============================================================

			    repeat (2) begin

					SEQ = ahb_sequence_item #(ADDRWIDTH)::type_id::create("SEQ_3");

					start_item(SEQ);

					if (!(SEQ.randomize() with {
						HTRANS == 2'b11;
						HSEL   == 1'b1;
						HWRITE == current_write;
					    HSIZE  == current_size;
					    HPROT  == current_prot;
					    HADDR  == current_addr + (1 << current_size);
						})
					    )
						`uvm_fatal(get_type_name(),"AHB transition seq randomize() failed")

					finish_item(SEQ);

					current_addr  = SEQ.HADDR;
				end

				// ============================================================
			    // 8. Finish with IDLE
			    // ============================================================

			    IDLE = ahb_sequence_item #(ADDRWIDTH)::type_id::create("IDLE_2");

				start_item(IDLE);

				if (!(IDLE.randomize() with {
					 HTRANS == 2'b00;
					 HSEL   == 1'b0;
				     HWRITE == 1'b0;
				     HSIZE  == 3'b000;
				     HADDR  == 32'h00000000;
					})
					)
					`uvm_fatal(get_type_name(),"AHB transition idle randomize() failed")

				finish_item(IDLE);

				`uvm_info(get_type_name(),"Finished Transition Sequence",UVM_LOW);

		endtask : body

	endclass : ahb_htrans_transition_sequence
	
endpackage : ahb_htrans_transition_sequence_pkg