package ahb2apb_environment_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	import ahb_agent_pkg::*;

	import apb_agent_pkg::*;

	import ahb2apb_scoreboard_pkg::*;
	import ahb2apb_coverage_pkg::*;

	class ahb2apb_environment extends uvm_env;
		`uvm_component_utils(ahb2apb_environment)

		ahb_agent ahb_agt;
		apb_agent apb_agt;

		ahb2apb_scoreboard sb;

		ahb2apb_coverage cov;

		function new(string name = "ahb2apb_environment", uvm_component parent = null);
			super.new(name, parent);	
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);

	        ahb_agt = ahb_agent::type_id::create("ahb_agt", this);
	        apb_agt = apb_agent::type_id::create("apb_agt", this);

	        sb = ahb2apb_scoreboard::type_id::create("sb", this);

	        cov = ahb2apb_coverage::type_id::create("cov", this);

		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);

			// connect agent monitor to scoreboard
			ahb_agt.ahb_aport.connect(sb.ahb_aexport);
			apb_agt.apb_aport.connect(sb.apb_aexport);

			// connect agent monitor to coverage
			ahb_agt.ahb_aport.connect(cov.ahb_imp);
			apb_agt.apb_aport.connect(cov.apb_imp);
			apb_agt.mon.request_aport.connect(cov.apb_req_imp);
		endfunction : connect_phase

	endclass : ahb2apb_environment
	
endpackage : ahb2apb_environment_pkg