interface apb_if #(parameter ADDRWIDTH = 16) (input bit PCLK);
    //---------------------------------------------------------
    //Signal Declaration
    //---------------------------------------------------------
    logic                 PRESETn;
    logic          [31:0] PRDATA; 
    logic                 PREADY;
    logic                 PSLVERR;
    logic [ADDRWIDTH-1:0] PADDR;   
    logic                 PENABLE; 
    logic                 PWRITE;  
    logic           [3:0] PSTRB;   
    logic           [2:0] PPROT;   
    logic          [31:0] PWDATA;  
    logic                 PSEL;    
    logic                 APBACTIVE;

  
    //---------------------------------------------------------
    // Clocking Block
    //---------------------------------------------------------
    clocking apb_cb @(posedge PCLK);

        // Signals sampled by the testbench
        input #1step PRESETn;
        input #1step PADDR;
        input #1step PENABLE;
        input #1step PWRITE;
        input #1step PSTRB;
        input #1step PPROT;
        input #1step PWDATA;
        input #1step PSEL;
        input #1step APBACTIVE;

        input #1step PREADY;
        input #1step PRDATA;
        input #1step PSLVERR;

    endclocking

    //---------------------------------------------------------
    //Modport Declaration
    //---------------------------------------------------------
    modport DUT (
        input  PCLK,PRESETn,PRDATA,PREADY,PSLVERR,
        output PADDR,PENABLE,PWRITE,PSTRB,PPROT,PWDATA,PSEL,APBACTIVE
    );

    modport TB (
        input  PCLK,PADDR,PENABLE,PWRITE,PSTRB,PPROT,PWDATA,PSEL,APBACTIVE,
        output PRESETn,PRDATA,PREADY,PSLVERR
    );
endinterface