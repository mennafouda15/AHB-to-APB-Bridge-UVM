package ahb_driver_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"

	import ahb_sequence_item_pkg::*;

	import ahb_config_pkg::*;
	
	typedef ahb_sequence_item#(16) ahb_seq_item_t;

	class ahb_driver extends uvm_driver#(ahb_seq_item_t);

		`uvm_component_utils(ahb_driver)

		virtual ahb_if ahb_vif;

		ahb_config ahb_cfg;

		function new(string name = "ahb_driver" , uvm_component parent);
			super.new(name,parent);
		endfunction : new
		
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			`uvm_info(get_type_name(),"ahb_driver_build_phase",UVM_LOW);
			if (!uvm_config_db#(ahb_config)::get(this,"","ahb_cfg",ahb_cfg)) begin
				`uvm_fatal(get_type_name(),"Failed to get the configuration from database")
			end	
		endfunction : build_phase

        function void connect_phase(uvm_phase phase);
        	super.connect_phase(phase);

        	`uvm_info(get_type_name(),"ahb_driver_connect_phase",UVM_LOW);
        	
        	ahb_vif = ahb_cfg.ahb_vif;
        endfunction : connect_phase

        task initalize_bus();
        	ahb_vif.drv_cb.HSEL   <= 1'b0;
        	ahb_vif.drv_cb.HADDR  <= 'b0; 
        	ahb_vif.drv_cb.HTRANS <= 2'b00;
        	ahb_vif.drv_cb.HSIZE  <= 3'b000;
        	ahb_vif.drv_cb.HPROT  <= 4'b0000;
            ahb_vif.drv_cb.HWRITE <= 1'b0;
            ahb_vif.drv_cb.HWDATA <= '0; 	
        endtask : initalize_bus

        task drive_addr(ahb_seq_item_t ahb_item);
        	ahb_vif.drv_cb.HSEL   <= ahb_item.HSEL;
        	ahb_vif.drv_cb.HADDR  <= ahb_item.HADDR; 
        	ahb_vif.drv_cb.HWRITE <= ahb_item.HWRITE;
        	ahb_vif.drv_cb.HTRANS <= ahb_item.HTRANS;
        	ahb_vif.drv_cb.HSIZE  <= ahb_item.HSIZE;
        	ahb_vif.drv_cb.HPROT  <= ahb_item.HPROT;  	
        endtask : drive_addr

        task drive_idle();
        	ahb_vif.drv_cb.HSEL   <= 1'b0;
        	ahb_vif.drv_cb.HTRANS <= 2'b00; 	
        endtask : drive_idle

        task run_phase(uvm_phase phase);

            ahb_seq_item_t addr_item = null;
            ahb_seq_item_t data_item = null;

            `uvm_info(get_type_name(),"ahb_driver_run_phase",UVM_LOW);

            initalize_bus();
            wait(ahb_vif.HRESETn === 1'b1);
            @(ahb_vif.drv_cb);

        	forever begin
        		if (ahb_vif.HRESETn !== 1'b1) begin
        			if (addr_item != null) begin
        				seq_item_port.item_done();
        			end

        			addr_item = null;
        			data_item = null;

        			initalize_bus();

        			wait(ahb_vif.HRESETn === 1'b1);

        			@(ahb_vif.drv_cb);

        			continue;
        		end

        		if(addr_item == null) begin
        			seq_item_port.try_next_item(addr_item);
        		end

        		if(addr_item != null) begin
        			drive_addr(addr_item);
        		end
        		else begin
        			drive_idle();
        		end
        		
        		if(data_item != null && data_item.HWRITE) begin
        			ahb_vif.drv_cb.HWDATA <= data_item.HWDATA;  			
				end 

        		@(ahb_vif.drv_cb);

        		if (ahb_vif.drv_cb.HREADY === 1'b1) begin
        			if (data_item != null) begin
        				data_item.HRDATA = ahb_vif.drv_cb.HRDATA;
        				data_item.HRESP = ahb_vif.drv_cb.HRESP;
        				data_item = null;
        			end

        			if (addr_item != null) begin
        				if (addr_item.HTRANS[1]) begin
        					data_item = addr_item;
        					data_item.wait_states = 0;
        				end

                    seq_item_port.item_done();
        			addr_item = null;
        			end
        		end

        		else if(data_item != null) begin
        			data_item.wait_states++;
        		end
        	end
        	
        endtask : run_phase

	endclass : ahb_driver
		
endpackage : ahb_driver_pkg