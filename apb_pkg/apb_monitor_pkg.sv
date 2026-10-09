package apb_monitor_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import apb_sequence_item_pkg::*;
    import apb_response_pkg::*;
    typedef apb_sequence_item #(16) apb_seq_item_t;
    class apb_monitor extends uvm_monitor;

        //---------------------------------------------------------
        //interface
        //---------------------------------------------------------

        virtual apb_if apb_intrf;

        //---------------------------------------------------------
        //TLM_decleration
        //---------------------------------------------------------

        uvm_analysis_port #(apb_seq_item_t)  transaction_aport;
        uvm_analysis_port #(apb_seq_item_t)  request_aport;

        //---------------------------------------------------------
        //uvm_factory
        //---------------------------------------------------------
        
        `uvm_component_utils(apb_monitor)

        //---------------------------------------------------------
        //new function
        //---------------------------------------------------------

        function new(string name = "apb_monitor" , uvm_component parent);
            super.new(name,parent);
            transaction_aport = new("transaction_aport",this);
            request_aport     = new("request_aport",this);
        endfunction //new()

        //---------------------------------------------------------
        //build_phase
        //---------------------------------------------------------

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(),"abp_monitor_build_phase",UVM_LOW)
            if (!uvm_config_db #(virtual apb_if)::get(this,"","apb_vif",apb_intrf)) 
                    `uvm_fatal(get_type_name(),"Failed to get interface")
        endfunction

        //---------------------------------------------------------
        //run_phase
        //---------------------------------------------------------

        task run_phase(uvm_phase phase);
            apb_seq_item_t seq_item ;
            apb_seq_item_t transaction_item;
            int wait_count;
            `uvm_info(get_type_name(),"abp_monitor_run_phase",UVM_LOW)
            
            forever begin
                //start request at setup phase
                @(apb_intrf.apb_cb);
                if (apb_intrf.apb_cb.PSEL && !apb_intrf.apb_cb.PENABLE && apb_intrf.apb_cb.PRESETn ) begin
                    seq_item = apb_seq_item_t::type_id::create("seq_item");
                    seq_item.PADDR     = apb_intrf.apb_cb.PADDR;
                    seq_item.PENABLE   = apb_intrf.apb_cb.PENABLE;
                    seq_item.PWRITE    = apb_intrf.apb_cb.PWRITE;
                    seq_item.PSTRB     = apb_intrf.apb_cb.PSTRB;
                    seq_item.PPROT     = apb_intrf.apb_cb.PPROT;
                    seq_item.PWDATA    = apb_intrf.apb_cb.PWDATA;
                    seq_item.PSEL      = apb_intrf.apb_cb.PSEL;
                    seq_item.APBACTIVE = apb_intrf.apb_cb.APBACTIVE;
                    request_aport.write(seq_item);
                    
                    wait_count = 0;

                    forever begin

                        @(apb_intrf.apb_cb);

                        if (!apb_intrf.apb_cb.PRESETn) begin
                            // reset / inactive
                            seq_item = null;
                            break;
                        end

                        if (apb_intrf.apb_cb.PSEL && apb_intrf.apb_cb.PENABLE) begin
                        
                            if (!apb_intrf.apb_cb.PREADY) begin
                            
                                wait_count++;

                            end
                            else begin
                                transaction_item = apb_seq_item_t::type_id::create( "transaction_item");

                                transaction_item.PADDR = seq_item.PADDR;
                                transaction_item.PWRITE = seq_item.PWRITE;
                                transaction_item.PSTRB = seq_item.PSTRB;
                                transaction_item.PPROT = seq_item.PPROT;
                                transaction_item.PWDATA = seq_item.PWDATA;
                                transaction_item.PSEL = apb_intrf.apb_cb.PSEL;
                                transaction_item.PENABLE = apb_intrf.apb_cb.PENABLE;
                                transaction_item.APBACTIVE = seq_item.APBACTIVE;
                                // Transfer completed
                                transaction_item.PRDATA     = apb_intrf.apb_cb.PRDATA;
                                transaction_item.PSLVERR    = apb_intrf.apb_cb.PSLVERR;
                                transaction_item.PREADY     = apb_intrf.apb_cb.PREADY;
                                transaction_item.wait_count = wait_count;

                                transaction_aport.write(transaction_item);

                                break;
                            end
                        end
                    end
                end
            end
            
        endtask //
    endclass //apb_monitor extends 
endpackage