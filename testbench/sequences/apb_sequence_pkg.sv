package apb_sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import apb_sequence_item_pkg::*;
    import apb_response_pkg::*;
    import apb_sequencer_pkg::*;

    typedef apb_sequence_item#(16) apb_seq_item_t;

    class apb_sequence extends uvm_sequence #(apb_response);

        //---------------------------------------------------------
        //uvm_factory
        //---------------------------------------------------------

        `uvm_object_utils(apb_sequence)
        `uvm_declare_p_sequencer (apb_sequencer) 

        //---------------------------------------------------------
        //trans_decl
        //---------------------------------------------------------
        apb_seq_item_t seq_item;
        apb_response    resp;
        //---------------------------------------------------------
        //new function
        //---------------------------------------------------------

        function new(string name = "apb_sequence");
            super.new(name);
            `uvm_info(get_type_name(),"INSIDE NEW SEQUENCE CLASS",UVM_LOW)
        endfunction //new()

        //---------------------------------------------------------
        //body
        //---------------------------------------------------------

        virtual task body();
            forever begin
                p_sequencer.request_fifo.get(seq_item);
                resp = apb_response::type_id::create("resp");
                start_item(resp);
                  assert(resp.randomize()) begin
                    `uvm_info(get_type_name(),{"DATA RANDOMIZED : \n ", resp.sprint()},UVM_LOW)
                  end else begin
                    `uvm_fatal(get_type_name(),"[SEQUENCE] Randomization failed");
                  end  
                finish_item(resp);
            end
        endtask //automatic
    endclass //apb_sequence extends uvm_sequence #(apb_seq_item_t)
endpackage