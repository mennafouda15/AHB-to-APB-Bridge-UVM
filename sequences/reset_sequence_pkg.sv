package reset_sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class reset_sequence extends uvm_sequence;
    
        `uvm_object_utils(reset_sequence)
    
        virtual ahb_if ahb_vif;
        virtual apb_if apb_vif;
    
        function new(string name = "reset_sequence");
            super.new(name);
        endfunction
    
        task body();
    
            if (!uvm_config_db#(virtual ahb_if)::get(null, "", "ahb_vif", ahb_vif))
                `uvm_fatal("RESET", "Cannot get AHB virtual interface");
    
            if (!uvm_config_db#(virtual apb_if)::get(null, "", "apb_vif", apb_vif))
                `uvm_fatal("RESET", "Cannot get APB virtual interface");
    
        endtask
    
    
        task ahb_reset(int unsigned cycles = 2);
    
            `uvm_info("RESET", "Starting AHB reset", UVM_MEDIUM)
    
            ahb_vif.HRESETn = 0;
    
            repeat(cycles)
                @(posedge ahb_vif.HCLK);
    
            ahb_vif.HRESETn = 1;
    
            `uvm_info("RESET", "AHB reset released", UVM_MEDIUM)
    
        endtask
    
    
        task apb_reset(int unsigned cycles = 2);
    
            `uvm_info("RESET", "Starting APB reset", UVM_MEDIUM)
    
            apb_vif.PRESETn = 0;
    
            repeat(cycles)
                @(posedge apb_vif.PCLK);
    
            apb_vif.PRESETn = 1;
    
            `uvm_info("RESET", "APB reset released", UVM_MEDIUM)
    
        endtask
    
    
        task both_reset(int unsigned cycles = 2);
    
            `uvm_info("RESET", "Starting both resets", UVM_MEDIUM)
    
            ahb_vif.HRESETn = 0;
            apb_vif.PRESETn = 0;
    
            repeat(cycles)
                @(posedge ahb_vif.HCLK);
    
            ahb_vif.HRESETn = 1;
    
            repeat(cycles)
                @(posedge apb_vif.PCLK);
    
            apb_vif.PRESETn = 1;
    
            `uvm_info("RESET", "Both resets released", UVM_MEDIUM)
    
        endtask
    
    endclass

endpackage