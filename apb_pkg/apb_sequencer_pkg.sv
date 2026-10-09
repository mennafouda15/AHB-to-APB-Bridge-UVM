package apb_sequencer_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import apb_sequence_item_pkg::*;
    import apb_response_pkg::*;

    typedef apb_sequence_item #(16) apb_seq_item_t;


    class apb_sequencer extends uvm_sequencer #(apb_response);

        //---------------------------------------------------------
        //uvm_factory
        //---------------------------------------------------------

        `uvm_component_utils(apb_sequencer)

        //---------------------------------------------------------
        //TLM_decleration
        //---------------------------------------------------------

        uvm_analysis_export   #(apb_seq_item_t) request_export;    
        uvm_tlm_analysis_fifo #(apb_seq_item_t) request_fifo;
        
        //---------------------------------------------------------
        //new function
        //---------------------------------------------------------

        function new(string name ="apb_sequencer",uvm_component parent);
            super.new(name,parent);
            request_fifo = new("request_fifo", this);    
            request_export = new("request_export", this);
        endfunction //new()

        //---------------------------------------------------------
        //connect_phase
        //---------------------------------------------------------

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            `uvm_info(get_type_name(),"abp_sequencer_connect_phase",UVM_LOW)
            request_export.connect(request_fifo.analysis_export); 
        endfunction
    endclass //apb_sequencer extends uvm_sequencer #(apb_seq_item_t)
endpackage