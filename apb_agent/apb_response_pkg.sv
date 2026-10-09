package apb_response_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class apb_response extends uvm_sequence_item;
    //---------------------------------------------------------
    //Signal Declaration
    //---------------------------------------------------------
    rand logic          [31:0] PRDATA; 
    rand logic                 PSLVERR;

    rand int                   wait_cycles;

    
    //---------------------------------------------------------
    //uvm_factory
    //---------------------------------------------------------

    `uvm_object_utils_begin(apb_response)
        `uvm_field_int(PRDATA,UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(PSLVERR,UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(wait_cycles,UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    //---------------------------------------------------------
    //constraint
    //---------------------------------------------------------

    constraint wait_c {
        wait_cycles inside {[0:5]};
    }

    constraint pslverr_c {
            PSLVERR dist { 0 := 95, 1 := 5 };
                }
 
    //---------------------------------------------------------
    //function declration
    //---------------------------------------------------------

    function string convert2string();
        return($sformatf("PRDATA = %0h PSLVERR = %0b wait_cycles = %0d ",PRDATA , PSLVERR , wait_cycles));  
    endfunction

    //---------------------------------------------------------
    //new
    //---------------------------------------------------------

    function new(string name = "apb_response");
        super.new(name);
    endfunction //new()

    endclass //apb_response extends uvm_sequence_item
endpackage