package apb_sequence_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class apb_sequence_item #(parameter int ADDRWIDTH = 16) extends uvm_sequence_item;

    //---------------------------------------------------------
    //Signal Declaration
    //---------------------------------------------------------
         logic [ADDRWIDTH-1:0] PADDR;   
         logic                 PENABLE; 
         logic                 PWRITE;  
         logic           [3:0] PSTRB;   
         logic           [2:0] PPROT;   
         logic          [31:0] PWDATA;  
         logic                 PSEL;    
         logic                 APBACTIVE;
         logic          [31:0] PRDATA; 
         logic                 PSLVERR;
         logic                 PREADY;
         int                 wait_count;

    //---------------------------------------------------------
    //uvm_factory
    //---------------------------------------------------------

    `uvm_object_param_utils_begin(apb_sequence_item #(ADDRWIDTH))
        `uvm_field_int(PENABLE, UVM_NOCOMPARE)
        `uvm_field_int(PWRITE,UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(PSTRB,UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_int(PRDATA,UVM_DEFAULT | UVM_NOCOMPARE )
        `uvm_field_int(PSLVERR,UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(PREADY,UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_int(PPROT,UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(PSEL,UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(APBACTIVE, UVM_NOCOMPARE)

        `uvm_field_int(PADDR,UVM_ALL_ON )
        `uvm_field_int(PWDATA,UVM_DEFAULT | UVM_NOCOMPARE )
        `uvm_field_int(wait_count,UVM_NOCOMPARE )
        
    `uvm_object_utils_end

    //---------------------------------------------------------
    //function declration
    //---------------------------------------------------------

    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        apb_sequence_item#() rhs_;
        bit status = 1;

        // Cast the right-hand side object to the correct type
        if (!$cast(rhs_, rhs)) begin
            `uvm_error("do_compare", "Cast failed - unexpected object type")
            return 0;
        end

        // Compare all base class and UVM_DEFAULT fields (like PADDR, PWRITE)
        status &= super.do_compare(rhs, comparer);

        // Conditionally compare PWDATA only during Write operations
        if (this.PWRITE == 1'b1) begin
            status &= comparer.compare_field("PWDATA", this.PWDATA, rhs_.PWDATA, 32);
        end
// Print comparison results directly to the transcript
    `uvm_info("APB_ITEM_CMP", $sformatf("\n--- APB ITEM COMPARISON [%s] ---\n Expected: %s\n Actual:   %s",  status ? "PASS" : "FAIL",
                                        this.convert2string(),
                                        rhs_.convert2string()), UVM_LOW)

    return status;

    endfunction

    function string convert2string();
        return($sformatf(" PADDR = %0h  PENABLE = %0b  PWRITE = %0b PSTRB = %4b PPROT = %3b PWDATA = %0h PSEL = %0b APBACTIVE = %0b",
                           PADDR , PENABLE , PWRITE , PSTRB , PPROT , PWDATA , PSEL , APBACTIVE));  
    endfunction

    function new(string name = "apb_sequence_item");
        super.new(name);
    endfunction //new()

    endclass //sequence_item extends uvm_sequence_item
endpackage