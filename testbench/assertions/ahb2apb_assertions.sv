module ahb2apb_assertions #(
    parameter ADDRWIDTH = 16
)(
    ahb_if ahb_vif,
    apb_if apb_vif
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

endmodule