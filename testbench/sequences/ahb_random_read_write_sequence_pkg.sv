package ahb_random_read_write_sequence_pkg;

	import uvm_pkg::*;
	import ahb_base_sequence_pkg::*;
	import ahb_sequence_item_pkg::*;

	`include "uvm_macros.svh"

	class ahb_random_read_write_sequence #(parameter ADDRWIDTH = 16) extends ahb_base_sequence;
		`uvm_object_utils(ahb_random_read_write_sequence)

		function new(string name = "ahb_random_read_write_sequence");
			super.new(name);
		endfunction : new

		virtual task body();
			
			ahb_sequence_item #(ADDRWIDTH) rw_seq, idle_seq;

			`uvm_info(get_type_name(),"Starting Random Read-Write Sequence",UVM_LOW);
			
			repeat(100) begin
				rw_seq = ahb_sequence_item #(ADDRWIDTH)::type_id::create("rw_seq");
				idle_seq = ahb_sequence_item #(ADDRWIDTH)::type_id::create("idle_seq");

				start_item(rw_seq);

				if (!(rw_seq.randomize() with {
					HTRANS == 2'b10;
					})
					)
					`uvm_fatal(get_type_name(),"AHB read-write seq randomize() failed")

				finish_item(rw_seq);

				start_item(idle_seq);

				if (!(idle_seq.randomize() with {
					HTRANS == 2'b00;
					})
					)
					`uvm_fatal(get_type_name(),"AHB idle seq randomize() failed")

				finish_item(idle_seq);
					
			end
		endtask : body

	endclass : ahb_random_read_write_sequence

endpackage : ahb_random_read_write_sequence_pkg