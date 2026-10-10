`timescale 1ns/1ps
interface ahb_if #(parameter ADDRWIDTH = 16) (input bit HCLK);

    logic                         HRESETn   ; 

    // AHB MASTER to BRIDGE
    logic                         HSEL      ;
    logic     [ADDRWIDTH-1:0]     HADDR     ; 
    logic     [1:0]               HTRANS    ;
    logic     [2:0]               HSIZE     ;
    logic     [3:0]               HPROT     ;
    logic                         HWRITE    ;
    logic     [31:0]              HWDATA    ;
    logic                         HREADY    ;

    // BRIDGE to AHB MASTER
    logic                         HREADYOUT ;
    logic                         HRESP     ;
    logic     [31:0]              HRDATA    ;

    //for unmatched test to disable assertion "a_wrap_hs3_req_fall"
    logic ignore_hs3_check = 0;

    clocking drv_cb @(posedge HCLK);
        default input #1step output #1;
        output HSEL , HADDR , HTRANS , HSIZE , HPROT , HWRITE , HWDATA;
        input  HREADY , HREADYOUT , HRESP , HRDATA;
    endclocking
	
	clocking mon_cb @(posedge HCLK);
	    default input #1step;
		input HSEL , HADDR , HTRANS , HSIZE , HPROT , HWRITE , HWDATA ,
		      HREADY , HREADYOUT , HRESP , HRDATA;
	endclocking

endinterface : ahb_if