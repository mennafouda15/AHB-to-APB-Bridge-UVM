module ahb2apb_assertions #(
    parameter ADDRWIDTH = 16
)(
    ahb_if ahb_vif,
    apb_if apb_vif

    // DUT-internal handshake signals 
    input logic s_req_h,
    input logic s_ack_h,
    input logic s_req_p,
    input logic s_ack_p
);

  clocking ahb_cb @(posedge ahb_vif.HCLK); endclocking;
  clocking apb_cb @(posedge apb_vif.PCLK); endclocking;

  wire apb_setup  = apb_vif.PSEL && !apb_vif.PENABLE;          // SETUP phase
  wire apb_access = apb_vif.PSEL &&  apb_vif.PENABLE;          // ACCESS phase
  wire apb_done   = apb_access && apb_vif.PREADY;              // transfer completes

  // AHB address phase accepted by the bridge (HREADY==HREADYOUT)
  wire ahb_accept = ahb_vif.HSEL && ahb_vif.HTRANS[1] && ahb_vif.HREADY;

  // Signals that must stay stable for the whole APB transfer.
  // PWDATA only matters for writes.
  property p_apb_ctrl_stable;
    $stable(apb_vif.PSEL)    &&
    $stable(apb_vif.PWRITE)  &&
    $stable(apb_vif.PADDR)   &&
    $stable(apb_vif.PSTRB)   &&
    $stable(apb_vif.PPROT)   &&
    (!apb_vif.PWRITE || $stable(apb_vif.PWDATA));
  endproperty

  // ---------------------------------------------------------------------------
  // SVA-001  APB SETUP legality
  //   A new transfer starts with PSEL=1, PENABLE=0; PENABLE never without PSEL.
  // ---------------------------------------------------------------------------
  a_sva001_setup : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      $rose(apb_vif.PSEL) |-> !apb_vif.PENABLE)
    else $error("SVA-001: PSEL rose with PENABLE=1 (no SETUP phase)");
 
  a_sva001_penable_needs_psel : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      apb_vif.PENABLE |-> apb_vif.PSEL)
    else $error("SVA-001: PENABLE asserted without PSEL");
 
  // ---------------------------------------------------------------------------
  // SVA-002  APB ACCESS legality
  //   ACCESS follows SETUP in the very next cycle, control signals unchanged.
  //   (This also guarantees PREADY during SETUP cannot complete the transfer.)
  // ---------------------------------------------------------------------------
  a_sva002_access_follows_setup : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      apb_setup |=> (apb_access and p_apb_ctrl_stable))
    else $error("SVA-002: ACCESS did not follow SETUP or control signals changed");
 
  // ---------------------------------------------------------------------------
  // SVA-003  PREADY only completes ACCESS
  //   PREADY=0 in ACCESS -> stay in ACCESS
  //   PSEL&PENABLE&PREADY -> transfer ends, PENABLE drops next cycle
  // ---------------------------------------------------------------------------
  a_sva003_stay_in_access : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      (apb_access && !apb_vif.PREADY) |=> apb_access)
    else $error("SVA-003: left ACCESS before PREADY");
 
  a_sva003_complete : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      apb_done |=> !apb_vif.PENABLE)
    else $error("SVA-003: PENABLE still high after the transfer completed");

  // --------------------------------------------------------------------------- 
  // SVA-004 : No APB transaction without a corresponding accepted AHB request. 
  // SVA-005 : No duplicate APB request for one AHB transfer.
  //The two domains use different clocks, so a single clocked property cannot relate them. 
  //Count events per domain and compare the counters.
  // ---------------------------------------------------------------------------

  int unsigned ahb_acc_cnt;     // accepted AHB transfers
  int unsigned apb_start_cnt;   // APB Setup phases seen
 
  always @(posedge ahb_vif.HCLK or negedge ahb_vif.HRESETn or negedge apb_vif.PRESETn)
    if (!ahb_vif.HRESETn || !apb_vif.PRESETn)   
        ahb_acc_cnt <= 0;
    else if (ahb_accept) 
        ahb_acc_cnt <= ahb_acc_cnt + 1;
 
  always @(posedge apb_vif.PCLK or negedge ahb_vif.HRESETn or negedge apb_vif.PRESETn)
    if (!ahb_vif.HRESETn || !apb_vif.PRESETn)         
        apb_start_cnt <= 0;
    else if (apb_setup)  
        apb_start_cnt <= apb_start_cnt + 1;
 
  // SVA-004: an APB SETUP needs a pending (accepted, not yet started) AHB request.
  // Counters are sampled pre-increment, so '<' means "one is pending".
  a_sva004_no_phantom : assert property (@(apb_cb) disable iff (!ahb_vif.HRESETn || ! apb_vif.PRESETn)
      apb_setup |-> (apb_start_cnt < ahb_acc_cnt))
    else $error("SVA-004: APB transfer without a corresponding accepted AHB request");
 
  // SVA-005: exactly one APB transfer per AHB transfer.
  // When the AHB side completes (HREADYOUT == 1) the numbers must match.
  a_sva005_one_apb_per_ahb : assert property (@(ahb_cb) disable iff (!ahb_vif.HRESETn || ! apb_vif.PRESETn)
      $rose(ahb_vif.HREADYOUT) |-> (apb_start_cnt == ahb_acc_cnt))
    else $error("SVA-005: duplicate/missing APB request for an AHB transfer (apb=%0d ahb=%0d)", apb_start_cnt, ahb_acc_cnt);

  // ---------------------------------------------------------------------------
  // SVA-006  APB stability during wait states (PREADY=0 in ACCESS phase)
  // ---------------------------------------------------------------------------
  a_sva006_stable_in_wait : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      (apb_access && !apb_vif.PREADY) |=> p_apb_ctrl_stable)
    else $error("SVA-006: APB control/address/data changed during wait state");

  // ---------------------------------------------------------------------------
  // Assertions copied from the DUT wrapper
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // WRAP-HS-1..4  Request / acknowledge handshake between HCLK and PCLK domains
  // ---------------------------------------------------------------------------
  // 1: Req may only rise when Ack is low
  a_wrap_hs1_req_rise : assert property (@(ahb_cb) disable iff (!ahb_vif.HRESETn)
      $rose(s_req_h) |-> !s_ack_h)
    else $error("WRAP-HS-1: Req rising edge while Ack is high");

  // 2: Ack may only rise when Req is high  
  a_wrap_hs2_ack_rise : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn || !ahb_vif.HRESETn)
      $rose(s_ack_p) |-> s_req_p)
    else $error("WRAP-HS-2: Ack rising edge while Req is low");

  // 3: Req may only fall when Ack is high   
  a_wrap_hs3_req_fall : assert property (@(ahb_cb) disable iff (!ahb_vif.HRESETn || !apb_vif.PRESETn || ahb_vif.ignore_hs3_check)
      $fell(s_req_h) |-> s_ack_h)
    else $error("WRAP-HS-3: Req falling edge while Ack is low");

  // 4: Ack may only fall when Req is low
  a_wrap_hs4_ack_fall : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      $fell(s_ack_p) |-> !s_req_p)
    else $error("WRAP-HS-4: Ack falling edge while Req is high");

  // ---------------------------------------------------------------------------
  // Helper state used by the data / response checks
  // ---------------------------------------------------------------------------
  // Last data returned by an APB read and last APB response (PCLK domain)
  logic [31:0] last_rd_apb_data;
  logic        last_apb_resp;

  always @(posedge apb_vif.PCLK or negedge apb_vif.PRESETn)
    if (!apb_vif.PRESETn) begin
      last_rd_apb_data <= '0;
      last_apb_resp    <= 1'b0;
    end else begin
      if (apb_vif.PREADY && apb_vif.PENABLE && apb_vif.PSEL)
        last_apb_resp    <= apb_vif.PSLVERR;
      if (apb_vif.PREADY && apb_vif.PENABLE && apb_vif.PSEL && !apb_vif.PWRITE)
        last_rd_apb_data <= apb_vif.PRDATA;
    end

  // AHB data phase tracking: a transfer is in its data phase and whether it is a write or not
  logic ahb_dp_valid;
  logic ahb_dp_write;

  always @(posedge ahb_vif.HCLK or negedge ahb_vif.HRESETn)
    if (!ahb_vif.HRESETn) begin
      ahb_dp_valid <= 1'b0;
      ahb_dp_write <= 1'b0;
    end else if (ahb_vif.HREADY) begin
      ahb_dp_valid <= ahb_vif.HSEL && ahb_vif.HTRANS[1];
      ahb_dp_write <= ahb_vif.HWRITE;
    end

  // Last accepted AHB write data (HWDATA is valid one cycle after the address phase)
  logic        wdata_sample_pending;
  logic [31:0] last_wr_ahb_data;

  always @(posedge ahb_vif.HCLK or negedge ahb_vif.HRESETn)
    if (!ahb_vif.HRESETn) begin
      wdata_sample_pending <= 1'b0;
      last_wr_ahb_data     <= '0;
    end else begin
      wdata_sample_pending <= ahb_accept && ahb_vif.HWRITE;
      if (wdata_sample_pending)
        last_wr_ahb_data   <= ahb_vif.HWDATA;
    end

  // ---------------------------------------------------------------------------
  // WRAP-RD   HRDATA must equal the last APB read data (unless error response)
  // ---------------------------------------------------------------------------
  a_wrap_read_data : assert property (@(ahb_cb) disable iff (!ahb_vif.HRESETn)
      (ahb_dp_valid && !ahb_dp_write && ahb_vif.HREADYOUT && !ahb_vif.HRESP)
        |-> (last_rd_apb_data == ahb_vif.HRDATA))
    else $error("WRAP-RD: read data mismatch HRDATA=%08h last APB PRDATA=%08h",
                ahb_vif.HRDATA, last_rd_apb_data);

  // ---------------------------------------------------------------------------
  // WRAP-RESP: HRESP must match the PSLVERR
  // ---------------------------------------------------------------------------
  a_wrap_resp : assert property (@(ahb_cb) disable iff (!ahb_vif.HRESETn)
      (ahb_dp_valid && ahb_vif.HREADYOUT) |-> (last_apb_resp == ahb_vif.HRESP))
    else $error("WRAP-RESP: HRESP=%0b but last PSLVERR=%0b", ahb_vif.HRESP, last_apb_resp);

  // ---------------------------------------------------------------------------
  // WRAP-APBACTIVE: APBACTIVE must be high before and during APB transfers
  // ---------------------------------------------------------------------------
  a_wrap_apbactive_hs : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      (s_req_p != s_ack_p) |-> apb_vif.APBACTIVE)
    else $error("WRAP-APBACTIVE: APBACTIVE low while req/ack handshake in progress");

  a_wrap_apbactive_psel : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      apb_vif.PSEL |-> apb_vif.APBACTIVE)
    else $error("WRAP-APBACTIVE: APBACTIVE low while PSEL=1");

  // ---------------------------------------------------------------------------
  // WRAP-WR: PWDATA of a write must equal the last accepted AHB write data
  //   Only checked for writes: on reads the DUT keeps driving old write data.
  // ---------------------------------------------------------------------------
  a_wrap_write_data : assert property (@(apb_cb) disable iff (!apb_vif.PRESETn)
      (apb_vif.PSEL && apb_vif.PWRITE) |-> (last_wr_ahb_data == apb_vif.PWDATA))
    else $error("WRAP-WR: PWDATA=%08h but last AHB write data=%08h",
                apb_vif.PWDATA, last_wr_ahb_data);

endmodule