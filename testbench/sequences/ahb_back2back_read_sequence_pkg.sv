package ahb_back2back_read_sequence_pkg;

	import uvm_pkg::*;
	import ahb_base_sequence_pkg::*;
	import ahb_sequence_item_pkg::*;

	`include "uvm_macros.svh"

	class ahb_back2back_read_sequence #(parameter ADDRWIDTH = 16) extends ahb_base_sequence;
		`uvm_object_utils(ahb_back2back_read_sequence)

		function new(string name = "ahb_back2back_read_sequence");
			super.new(name);
		endfunction : new

		virtual task body();
			
			ahb_sequence_item #(ADDRWIDTH) read_seq;

			`uvm_info(get_type_name(),"Starting B2B Read Sequence",UVM_LOW);
			
			repeat(100) begin
				read_seq = ahb_sequence_item #(ADDRWIDTH)::type_id::create("read_seq");

				start_item(read_seq);

				if (!(read_seq.randomize() with {
					HWRITE == 0;
					HTRANS == 2'b10;
					})
					)
					`uvm_fatal(get_type_name(),"AHB B2B read seq randomize() failed")

				finish_item(read_seq);

			end
		endtask : body

	endclass : ahb_back2back_read_sequence
	
endpackage : ahb_back2back_read_sequence_pkg