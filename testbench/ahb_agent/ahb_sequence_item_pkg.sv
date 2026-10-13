package ahb_sequence_item_pkg;

    import uvm_pkg::*;

    `include "uvm_macros.svh"

    class ahb_sequence_item #(parameter ADDRWIDTH = 16) extends uvm_sequence_item;


        function new(string name = "ahb_sequence_item");
            super.new(name);    
        endfunction : new

        // Request
        rand     logic                         HSEL   ;     
        rand     logic     [ADDRWIDTH-1:0]     HADDR  ; 
        rand     logic     [1:0]               HTRANS ;   
        rand     logic     [2:0]               HSIZE  ;   
        rand     logic     [3:0]               HPROT  ; 
        rand     logic                         HWRITE ;      
        rand     logic     [31:0]              HWDATA ; 
        
        // Response
        logic     [31:0]     HRDATA      ;    
        logic                HRESP       ;  
        int                  wait_states ;

        `uvm_object_param_utils_begin(ahb_sequence_item #(ADDRWIDTH))
            `uvm_field_int(HRESP,       UVM_ALL_ON)
            // compare HRDATA when HWRITE is low
            `uvm_field_int(HRDATA,      UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(HSEL,        UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(HADDR,       UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(HTRANS,      UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(HSIZE,       UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(HPROT,       UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(HWRITE,      UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(HWDATA,      UVM_ALL_ON | UVM_NOCOMPARE)
            `uvm_field_int(wait_states, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_object_utils_end
 

        constraint hsel_c { soft HSEL dist { 1:=90 , 0:=10}; }
        constraint htrans_c { soft HTRANS dist { 2'b10:=60 , 2'b00:=40 }; }
        constraint hwrite_c { soft HWRITE dist { 1:=70 , 0:=30 }; }
        constraint hsize_c { soft HSIZE inside {[0:2]}; }
        constraint hwdata_c { soft HWRITE == 0 -> HWDATA == '0 ; }
        constraint haddr_alignment_c {
            HSIZE == 3'b001 -> (HADDR%2 == 0) ;
            HSIZE == 3'b010 -> (HADDR%4 == 0) ; }

        virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            ahb_sequence_item #(ADDRWIDTH) rhs_;
            bit status = 1;

            if (!$cast(rhs_, rhs)) begin
                `uvm_error("do_compare", "Cast failed - unexpected object type")
                return 0;
            end

            status &= super.do_compare(rhs, comparer);

            if (rhs_.HWRITE == 1'b0) begin
                status &= comparer.compare_field("HRDATA", this.HRDATA, rhs_.HRDATA, 32);
            end

            `uvm_info("AHB_ITEM_CMP", $sformatf("\n--- AHB ITEM COMPARISON [%s] ---\n Expected: HRESP = %0b HRDATA = 0X%h\n Actual:   %s",
                                                status ? "PASS" : "FAIL",
                                                this.HRESP, this.HRDATA,
                                                rhs_.convert2string()), UVM_LOW)

            return status;
        endfunction : do_compare

        function string convert2string();
            return $sformatf("HSEL = %d || HWRITE = %d || HADDR = 0X%h || HWDATA = 0X%h || HSIZE = %b || HTRANS = %b || HPROT = %b || HRESP = %0b || HRDATA = 0X%h" , 
                HSEL , HWRITE , HADDR , HWDATA , HSIZE , HTRANS , HPROT , HRESP , HRDATA);  
        endfunction : convert2string
        
    endclass : ahb_sequence_item    
    
endpackage : ahb_sequence_item_pkg