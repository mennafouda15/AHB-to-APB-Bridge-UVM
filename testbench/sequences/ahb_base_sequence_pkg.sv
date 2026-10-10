package ahb_base_sequence_pkg;

	import uvm_pkg::*;
	import ahb_sequence_item_pkg::*;

	`include "uvm_macros.svh"

	class ahb_base_sequence #(parameter ADDRWIDTH = 16) extends uvm_sequence #(ahb_sequence_item);;
		`uvm_object_utils(ahb_base_sequence)

		function new(string name = "ahb_base_sequence");
			super.new(name);
		endfunction : new

	endclass : ahb_base_sequence
	
endpackage : ahb_base_sequence_pkg