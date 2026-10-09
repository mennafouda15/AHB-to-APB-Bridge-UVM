package apb_agent_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import apb_driver_pkg::*;
    import apb_sequencer_pkg::*;
    import apb_monitor_pkg::*;
    import apb_config_pkg::*;

    import apb_sequence_item_pkg::*;
    import apb_response_pkg::*;

    typedef apb_sequence_item#(16) apb_seq_item_t;

    class apb_agent extends uvm_agent;
        uvm_analysis_port #(apb_seq_item_t) apb_aport;

        //---------------------------------------------------------
        //component_decleration
        //---------------------------------------------------------
        apb_driver    drv;
        apb_sequencer seqr;
        apb_monitor   mon;
        apb_config    apb_cfg;

        //---------------------------------------------------------
        //uvm_factory
        //---------------------------------------------------------

        `uvm_component_utils(apb_agent)

        //---------------------------------------------------------
        //new function
        //---------------------------------------------------------

        function new(string name = "apb_agent" ,uvm_component parent);
            super.new(name,parent);
            apb_aport = new("apb_aport", this);
        endfunction //new()

        //---------------------------------------------------------
        //build_phase
        //---------------------------------------------------------

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(),"abp_agent_build_phase",UVM_LOW)

            if(!uvm_config_db#(apb_config)::get(this,"","apb_cfg",apb_cfg))
	            `uvm_fatal("FATAL_OCCURRED","configuration is not getting from top")

            `uvm_info(get_type_name(),$sformatf("AGENT TYPE IS %p",apb_cfg.is_active),UVM_LOW)

            mon = apb_monitor::type_id::create("mon",this);
            uvm_config_db #(virtual apb_if)::set(this, "mon", "apb_vif", apb_cfg.apb_vif);
            if (apb_cfg.is_active == UVM_ACTIVE) begin
                drv = apb_driver::type_id::create("drv",this);
                seqr = apb_sequencer::type_id::create("seqr",this);
                uvm_config_db #(virtual apb_if)::set(this, "drv", "apb_vif", apb_cfg.apb_vif);
            end
        endfunction

        //---------------------------------------------------------
        //connect_phase
        //---------------------------------------------------------

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            `uvm_info(get_type_name(),"abp_agent_connect_phase",UVM_LOW)

            mon.transaction_aport.connect(apb_aport);
            if (apb_cfg.is_active == UVM_ACTIVE) begin
                drv.seq_item_port.connect(seqr.seq_item_export);
                mon.request_aport.connect(seqr.request_export); 
            end
        endfunction
    endclass //apb_agent extends 

endpackage