`timescale 1ns/1ps

import uvm_pkg::*;

`include "uvm_macros.svh"

import ahb2apb_pkg::*;

module tb_top #(
  parameter time HCLK_PERIOD = 10ns,
  parameter time PCLK_PERIOD = 10ns,
  parameter time PCLK_PHASE  = 0ns
);

  parameter int ADDRWIDTH = 16;

  bit HCLK = 0;
  bit PCLK = 0;

  initial begin
    forever #(HCLK_PERIOD/2) HCLK = ~HCLK;
  end

  initial begin
    #(PCLK_PHASE);
    forever #(PCLK_PERIOD/2) PCLK = ~PCLK;
  end

  // Interface instances
  ahb_if #(.ADDRWIDTH (ADDRWIDTH)) ahb_intrf(HCLK);
  apb_if #(.ADDRWIDTH (ADDRWIDTH)) apb_intrf(PCLK);

  //Resets
  initial begin
      ahb_intrf.HRESETn = 0;
      #50ns;
      ahb_intrf.HRESETn = 1;
  end

  initial begin
      apb_intrf.PRESETn = 0;
      #70ns;
      apb_intrf.PRESETn = 1;
  end

  // DUT
  cmsdk_ahb_to_apb_async #(
        .ADDRWIDTH(ADDRWIDTH)
    ) dut (

        // AHB clock/reset
        .HCLK      (ahb_intrf.HCLK),
        .HRESETn   (ahb_intrf.HRESETn),

        // AHB signals
        .HSEL      (ahb_intrf.HSEL),
        .HADDR     (ahb_intrf.HADDR),
        .HTRANS    (ahb_intrf.HTRANS),
        .HSIZE     (ahb_intrf.HSIZE),
        .HPROT     (ahb_intrf.HPROT),
        .HWRITE    (ahb_intrf.HWRITE),
        .HREADY    (ahb_intrf.HREADY),
        .HWDATA    (ahb_intrf.HWDATA),

        // AHB outputs
        .HREADYOUT (ahb_intrf.HREADYOUT),
        .HRDATA    (ahb_intrf.HRDATA),
        .HRESP     (ahb_intrf.HRESP),

        // APB clock/reset
        .PCLK      (apb_intrf.PCLK),
        .PRESETn   (apb_intrf.PRESETn),

        // APB outputs from DUT
        .PADDR     (apb_intrf.PADDR),
        .PENABLE   (apb_intrf.PENABLE),
        .PSTRB     (apb_intrf.PSTRB),
        .PPROT     (apb_intrf.PPROT),
        .PWRITE    (apb_intrf.PWRITE),
        .PWDATA    (apb_intrf.PWDATA),
        .PSEL      (apb_intrf.PSEL),

        // APB inputs to DUT
        .PRDATA    (apb_intrf.PRDATA),
        .PREADY    (apb_intrf.PREADY),
        .PSLVERR   (apb_intrf.PSLVERR),

        // Activity
        .APBACTIVE (apb_intrf.APBACTIVE)
    );

 
  // SVA checker 
  ahb2apb_assertions #(
        .ADDRWIDTH(ADDRWIDTH)
    ) sva_inst (
       .ahb_vif(ahb_intrf), .apb_vif(apb_intrf),
       .s_req_h(dut.s_req_h), .s_ack_h(dut.s_ack_h),
       .s_req_p(dut.s_req_p), .s_ack_p(dut.s_ack_p));


  initial begin
    uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif", ahb_intrf);
    uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb_intrf);
    run_test("ahb_apb_base_test");
    #1000000ns;
    $stop;
  end

  assign ahb_intrf.HREADY = ahb_intrf.HREADYOUT;

endmodule
