package apb_driver_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import apb_sequence_item_pkg::*;
    import apb_response_pkg::*;

    typedef apb_sequence_item#(16) apb_seq_item_t;

    class apb_driver extends uvm_driver #(apb_response);

        //---------------------------------------------------------
        //interface
        //---------------------------------------------------------
        
        virtual apb_if apb_intrf;

        //---------------------------------------------------------
        //uvm_factory
        //---------------------------------------------------------

        `uvm_component_utils(apb_driver)

        //---------------------------------------------------------
        //new function
        //---------------------------------------------------------

        function new(string name = "apb_driver" , uvm_component parent);
            super.new(name,parent);
        endfunction //new()

        //---------------------------------------------------------
        //build_phase
        //---------------------------------------------------------

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(),"APB_DRIVER_BUILD",UVM_LOW)
            if (!uvm_config_db #(virtual apb_if)::get(this,"","apb_vif",apb_intrf)) 
                    `uvm_fatal(get_type_name(),"Failed to get interface")
        endfunction

        //---------------------------------------------------------
        //run_phase
        //---------------------------------------------------------

        task run_phase(uvm_phase phase);
            apb_intrf.PREADY  <= 1'b0;
            apb_intrf.PSLVERR <= 1'b0;
            apb_intrf.PRDATA  <=  '0;
            forever begin
                apb_response resp;
                seq_item_port.get_next_item(resp);
                drive(resp);
                seq_item_port.item_done();
            end                             
        endtask 

        extern task drive(apb_response resp);
    endclass //apb_driver extends uvm_driver

    //---------------------------------------------------------
    //drive_task
    //---------------------------------------------------------

    task apb_driver::drive(apb_response resp);

        if (apb_intrf.apb_cb.PRESETn) begin

            @(apb_intrf.apb_cb);
            while (!(apb_intrf.apb_cb.PSEL && apb_intrf.apb_cb.PENABLE) && apb_intrf.apb_cb.PRESETn) begin
                @(apb_intrf.apb_cb);
            end //start drive at access phase

            if (resp.wait_cycles > 0 && apb_intrf.PRESETn) begin
                apb_intrf.PREADY <= 1'b0;

                repeat(resp.wait_cycles) begin
                        if (!apb_intrf.apb_cb.PRESETn)
                            break;
                        @(apb_intrf.apb_cb);

                end 
            end

            if (!apb_intrf.apb_cb.PRESETn) begin 
                apb_intrf.PREADY  <= 1'b0; 
                apb_intrf.PSLVERR <= 1'b0; 
                apb_intrf.PRDATA  <= '0; 
            end else begin
               apb_intrf.PREADY   <= 1'b1;
               apb_intrf.PRDATA   <= resp.PRDATA;
               apb_intrf.PSLVERR  <= resp.PSLVERR;
    
               @(apb_intrf.apb_cb);
               apb_intrf.PREADY   <= 1'b0;
               apb_intrf.PSLVERR  <= 1'b0; 
            end
        end
        
    endtask
endpackage