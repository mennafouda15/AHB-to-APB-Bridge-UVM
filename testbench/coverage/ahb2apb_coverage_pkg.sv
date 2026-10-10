package ahb2apb_coverage_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import ahb_sequence_item_pkg::*;
    import apb_sequence_item_pkg::*;

    typedef ahb_sequence_item #(16) ahb_seq_item_t;
    typedef apb_sequence_item #(16) apb_seq_item_t;

    // Analysis implementation macros must be at package scope.
    `uvm_analysis_imp_decl(_ahb)
    `uvm_analysis_imp_decl(_apb)
    `uvm_analysis_imp_decl(_apb_req)


    class ahb2apb_coverage extends uvm_component;

        `uvm_component_utils(ahb2apb_coverage)

        // Transaction handles
        ahb_seq_item_t ahb_item;
        apb_seq_item_t apb_item;
        apb_seq_item_t apb_req_item;

        // Queues for completed transactions
        ahb_seq_item_t ahb_fifo[$];
        apb_seq_item_t apb_fifo[$];

        // Analysis implementations
        uvm_analysis_imp_ahb #(
            ahb_seq_item_t, ahb2apb_coverage
        ) ahb_imp;

        uvm_analysis_imp_apb #(
            apb_seq_item_t, ahb2apb_coverage
        ) apb_imp;

        uvm_analysis_imp_apb_req #(
            apb_seq_item_t, ahb2apb_coverage
        ) apb_req_imp;


        //=====================================================
        // CG-001 + CG-002: Transfer type
        //=====================================================
        covergroup cg_transfer_type;
            option.per_instance = 1;

            cp_hwrite: coverpoint ahb_item.HWRITE {
                bins READ  = {1'b0};
                bins WRITE = {1'b1};
            }

            cp_htrans: coverpoint ahb_item.HTRANS {
                // The AHB monitor publishes only selected,
                // completed NONSEQ/SEQ transfers.
                bins NONSEQ = {2'b10};
                bins SEQ    = {2'b11};
            }
        endgroup : cg_transfer_type


        //=====================================================
        // CG-003: Transfer size
        //=====================================================
        covergroup cg_transfer_size;
            option.per_instance = 1;

            cp_hsize: coverpoint ahb_item.HSIZE {
                bins BYTE     = {3'b000};
                bins HALFWORD = {3'b001};
                bins WORD     = {3'b010};
            }
        endgroup :  cg_transfer_size


        //=====================================================
        // CG-004: Address region
        //=====================================================
        covergroup cg_address;
            option.per_instance = 1;

            cp_address_region: coverpoint ahb_item.HADDR {
                bins LOW  = {[16'h0000:16'h5555]};
                bins MID  = {[16'h5556:16'hAAAA]};
                bins HIGH = {[16'hAAAB:16'hFFFF]};
            }
        endgroup:   cg_address


        //=====================================================
        // CG-005: APB strobe
        //=====================================================
        covergroup cg_strobe;
            option.per_instance = 1;

            cp_pstrb: coverpoint apb_item.PSTRB {
                bins NO_STROBE    = {4'b0000};
                bins BYTE0        = {4'b0001};
                bins BYTE1        = {4'b0010};
                bins BYTE2        = {4'b0100};
                bins BYTE3        = {4'b1000};
                bins HALFWORD_LOW = {4'b0011};
                bins HALFWORD_HIGH = {4'b1100};
                bins FULL_WORD    = {4'b1111};
            }
        endgroup : cg_strobe


        //=====================================================
        // CG-006 + CG-007: APB completion and response
        //=====================================================
        covergroup cg_apb_response;
            option.per_instance = 1;

            // Completed APB transactions have PREADY == 1.
            cp_pready: coverpoint apb_item.PREADY {
                bins COMPLETE = {1'b1};
            }

            cp_pslverr: coverpoint apb_item.PSLVERR {
                bins OKAY  = {1'b0};
                bins ERROR = {1'b1};
            }
        endgroup : cg_apb_response


        //=====================================================
        // CG-008: APB wait count per completed transfer
        //=====================================================
        covergroup cg_transfer_latency;
            option.per_instance = 1;

            cp_wait_cycles: coverpoint apb_item.wait_count {
                bins NO_WAIT      = {1};
                bins ONE_WAIT     = {2};
                bins TWO_TO_THREE = {[3:4]};
                bins FOUR_PLUS    = {[5:$]};
            }
        endgroup : cg_transfer_latency


        //=====================================================
        // CG-009: AHB protection
        //=====================================================
        covergroup cg_protection;
            option.per_instance = 1;

            cp_hprot: coverpoint ahb_item.HPROT[1:0] {
                bins HPROT_0 = {2'b00};
                bins HPROT_1 = {2'b01};
                bins HPROT_2 = {2'b10};
                bins HPROT_3 = {2'b11};
            }
        endgroup : cg_protection


        //=====================================================
        // CG-010: Read/Write x Transfer Size
        // AHB-only cross
        //=====================================================
        covergroup cg_read_write_size;
            option.per_instance = 1;

            cp_rw: coverpoint ahb_item.HWRITE {
                bins READ  = {1'b0};
                bins WRITE = {1'b1};
            }

            cp_size: coverpoint ahb_item.HSIZE {
                bins BYTE     = {3'b000};
                bins HALFWORD = {3'b001};
                bins WORD     = {3'b010};
            }

            cross cp_rw, cp_size;
        endgroup : cg_read_write_size


        //=====================================================
        // CG-011: Read/Write x APB response
        // Samples a matched AHB/APB pair
        //=====================================================
        covergroup cg_read_write_response;
            option.per_instance = 1;

            cp_rw: coverpoint ahb_item.HWRITE {
                bins READ  = {1'b0};
                bins WRITE = {1'b1};
            }

            cp_response: coverpoint apb_item.PSLVERR {
                bins OKAY  = {1'b0};
                bins ERROR = {1'b1};
            }

            cross cp_rw, cp_response;
        endgroup :  cg_read_write_response

        //=====================================================
        // CG-013: Read/Write x Wait Count x APB Response
        // Samples a matched AHB/APB pair
        //=====================================================
        covergroup cg_write_latency_response;
            option.per_instance = 1;

            cp_write: coverpoint ahb_item.HWRITE {
                bins READ  = {1'b0};
                bins WRITE = {1'b1};
            }

            cp_wait: coverpoint apb_item.wait_count {
                bins NO_WAIT = {1};
                bins WAIT    = {[2:$]};
            }

            cp_response: coverpoint apb_item.PSLVERR {
                bins OKAY  = {1'b0};
                bins ERROR = {1'b1};
            }

            cross cp_write, cp_wait, cp_response;
        endgroup : cg_write_latency_response


        //=====================================================
        // CG-017: APB SETUP phase
        // Sampled from request_aport
        //=====================================================
        covergroup cg_apb_setup;
            option.per_instance = 1;

            cp_psel: coverpoint apb_req_item.PSEL {
                bins SELECTED = {1'b1};
            }

            cp_penable: coverpoint apb_req_item.PENABLE {
                bins SETUP = {1'b0};
            }

            cross cp_psel, cp_penable;
        endgroup : cg_apb_setup


        //=====================================================
        // Construct covergroups and analysis implementations
        //=====================================================
        function new(
            string name = "ahb2apb_coverage",
            uvm_component parent = null
        );
            super.new(name, parent);

            ahb_imp     = new("ahb_imp", this);
            apb_imp     = new("apb_imp", this);
            apb_req_imp = new("apb_req_imp", this);

            cg_transfer_type          = new();
            cg_transfer_size          = new();
            cg_address                = new();
            cg_strobe                 = new();
            cg_apb_response           = new();
            cg_transfer_latency       = new();
            cg_protection             = new();
            cg_read_write_size        = new();
            cg_read_write_response    = new();
            cg_write_latency_response = new();
            cg_apb_setup              = new();

        endfunction : new

        //=====================================================
        // AHB monitor callback
        //=====================================================
        function void write_ahb(ahb_seq_item_t t);

            ahb_fifo.push_back(t);
            ahb_item = t;

            // AHB-only coverage
            cg_transfer_type.sample();
            cg_transfer_size.sample();
            cg_address.sample();
            cg_protection.sample();
            cg_read_write_size.sample();

            try_match();

        endfunction : write_ahb


        //=====================================================
        // APB SETUP request callback
        //=====================================================
        function void write_apb_req(apb_seq_item_t t);

            apb_req_item = t;
            // Sample SETUP fields from the request item.
            cg_apb_setup.sample();

        endfunction : write_apb_req


        //=====================================================
        // APB completed-transaction callback
        //=====================================================
        function void write_apb(apb_seq_item_t t);

            apb_fifo.push_back(t);
            apb_item = t;

            // APB-only coverage
            cg_strobe.sample();
            cg_apb_response.sample();
            cg_transfer_latency.sample();

            try_match();

        endfunction : write_apb


        //=====================================================
        // Match completed AHB/APB transactions in FIFO order
        //=====================================================
        function void try_match();

            ahb_seq_item_t matched_ahb;
            apb_seq_item_t matched_apb;

            while ((ahb_fifo.size() > 0) &&
                   (apb_fifo.size() > 0)) begin

                matched_ahb = ahb_fifo.pop_front();
                matched_apb = apb_fifo.pop_front();

                ahb_item = matched_ahb;
                apb_item = matched_apb;

                // Check that the transactions correspond by address.
                // APB PADDR is word-aligned by the bridge.
                if (matched_ahb.HADDR[15:2] !=
                    matched_apb.PADDR[15:2]) begin

                    `uvm_error("AHB_APB_COV",
                        $sformatf(
                            "Address mismatch: AHB HADDR=0x%0h, APB PADDR=0x%0h",
                            matched_ahb.HADDR,
                            matched_apb.PADDR
                        ))
                end
                else begin

                    // Cross coverage: sample only matched pairs.
                    cg_read_write_response.sample();
                    cg_write_latency_response.sample();

                end

            end

        endfunction : try_match

        //=====================================================
        // Build phase
        //=====================================================
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
        endfunction : build_phase

    endclass : ahb2apb_coverage

endpackage : ahb2apb_coverage_pkg