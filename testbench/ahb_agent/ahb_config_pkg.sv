package ahb_config_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"

	class ahb_config extends uvm_object;
          
                `uvm_object_utils(ahb_config)

		virtual ahb_if ahb_vif;

		uvm_active_passive_enum is_active = UVM_ACTIVE;

		function new(string name = "ahb_config");
			super.new(name);
		endfunction : new
		
	endclass : ahb_config
	
endpackage : ahb_config_pkg