package ahb2apb_comparator_pkg;

	import uvm_pkg::*;	
	`include "uvm_macros.svh"

	import ahb_sequence_item_pkg::*;

    import apb_sequence_item_pkg::*;

    typedef ahb_sequence_item #(16) ahb_seq_item_t;
    typedef apb_sequence_item #(16) apb_seq_item_t;

	class ahb2apb_comparator extends uvm_component;
		`uvm_component_utils(ahb2apb_comparator)

		// ----------------------------------------------------
        // 			    analysis exports and fifos
        // ----------------------------------------------------

        // expected ahb
        uvm_analysis_export #(ahb_seq_item_t) ahb_exp_aexport;
        uvm_tlm_analysis_fifo #(ahb_seq_item_t) ahb_exp_fifo;

        // actual ahb
        uvm_analysis_export #(ahb_seq_item_t) ahb_act_aexport;
        uvm_tlm_analysis_fifo #(ahb_seq_item_t) ahb_act_fifo;

        // expected apb
        uvm_analysis_export #(apb_seq_item_t) apb_exp_aexport;
        uvm_tlm_analysis_fifo #(apb_seq_item_t) apb_exp_fifo;

        // actual apb
        uvm_analysis_export #(apb_seq_item_t) apb_act_aexport;
        uvm_tlm_analysis_fifo #(apb_seq_item_t) apb_act_fifo;

        function new(string name = "ahb2apb_comparator", uvm_component parent = null);
        	super.new(name, parent);
        endfunction : new

        function void build_phase(uvm_phase phase);
        	super.build_phase(phase);

        	// expected ahb
	        ahb_exp_aexport = new("ahb_exp_aexport", this);
	        ahb_exp_fifo = new("ahb_exp_fifo", this);

	        // actual ahb
	        ahb_act_aexport = new("ahb_act_aexport", this);
	        ahb_act_fifo = new("ahb_act_fifo", this);

	        // expected apb
	        apb_exp_aexport = new("apb_exp_aexport", this);
	        apb_exp_fifo = new("apb_exp_fifo", this);

	        // actual apb
	        apb_act_aexport = new("apb_act_aexport", this);
	        apb_act_fifo = new("apb_act_fifo", this);
        endfunction : build_phase

        function void connect_phase(uvm_phase phase);
        	super.connect_phase(phase);

        	ahb_exp_aexport.connect(ahb_exp_fifo.analysis_export);
        	ahb_act_aexport.connect(ahb_act_fifo.analysis_export);
        	apb_exp_aexport.connect(apb_exp_fifo.analysis_export);
        	apb_act_aexport.connect(apb_act_fifo.analysis_export);
        endfunction : connect_phase

        task run_phase(uvm_phase phase);

        	ahb_seq_item_t ahb_exp_seq_item, ahb_act_seq_item;
        	apb_seq_item_t apb_exp_seq_item, apb_act_seq_item;

        	super.run_phase(phase);

        	forever begin
        		
        		ahb_exp_fifo.get(ahb_exp_seq_item);
        		ahb_act_fifo.get(ahb_act_seq_item);
        		apb_exp_fifo.get(apb_exp_seq_item);
        		apb_act_fifo.get(apb_act_seq_item);

        		if (ahb_exp_seq_item.compare(ahb_act_seq_item)) begin
        			ahb_pass_count();
        		end else begin
        			ahb_fail_count(ahb_exp_seq_item.convert2string(), ahb_act_seq_item.convert2string());
        		end

        		if (apb_exp_seq_item.compare(apb_act_seq_item)) begin
        			apb_pass_count();
        		end else begin
        			apb_fail_count(apb_exp_seq_item.convert2string(), apb_act_seq_item.convert2string());
        		end
        	end
        endtask : run_phase


        // counters
        int ahb_correct_count, apb_correct_count, ahb_error_count, apb_error_count;

        function void ahb_pass_count();
            ahb_correct_count++;
            `uvm_info("CMP_PASS", "The expected signals for AHB match the outputs of the DUT", UVM_HIGH)
        endfunction : ahb_pass_count

        function void apb_pass_count();
            apb_correct_count++;
            `uvm_info("CMP_PASS", "The expected signals for APB match the outputs of the DUT", UVM_HIGH)
        endfunction : apb_pass_count

        function void ahb_fail_count(input string expected, actual);
            string msg;
            ahb_error_count++;
            msg = $sformatf("The expected signals for AHB don't match the outputs of the DUT\n Expected: %s\n Actual: %s",
                            expected, actual);
            `uvm_error("CMP_FAILED", msg)
        endfunction : ahb_fail_count

        function void apb_fail_count(input string expected, actual);
            string msg;
            apb_error_count++;
            msg = $sformatf("The expected signals for APB don't match the outputs of the DUT\n Expected: %s\n Actual: %s",
                            expected, actual);
            `uvm_error("CMP_FAILED", msg)
        endfunction : apb_fail_count

        function void report_phase(uvm_phase phase);
            int ahb_total;
            int apb_total;
            int total_checks;
            int total_errors;

            super.report_phase(phase);

            // Calculate totals
            ahb_total = ahb_correct_count + ahb_error_count;
            apb_total = apb_correct_count + apb_error_count;

            total_checks = ahb_total + apb_total;
            total_errors = ahb_error_count + apb_error_count;

            // ----------------------------------------------------
            //                    AHB SUMMARY
            // ----------------------------------------------------
            `uvm_info("CMP_REPORT",
                      {"\n==============================================\n",
                       "              AHB2APB COMPARATOR\n",
                       "==============================================\n",
                       "                  AHB RESULTS\n",
                       "----------------------------------------------\n",
                       $sformatf("  Correct Checks : %0d\n", ahb_correct_count)},
                      UVM_LOW)

            `uvm_info("CMP_REPORT",
                      {$sformatf("  Failed Checks  : %0d\n", ahb_error_count),
                       $sformatf("  Total Checks   : %0d\n", ahb_total),
                       $sformatf("  Pass Rate      : %0.2f%%\n",
                                 (ahb_total != 0) ? (100.0 * ahb_correct_count / ahb_total) : 0.0)},
                      UVM_LOW)

            // ----------------------------------------------------
            //                    APB SUMMARY
            // ----------------------------------------------------
            `uvm_info("CMP_REPORT",
                      {"\n                  APB RESULTS\n",
                       "----------------------------------------------\n"},
                      UVM_LOW)

            `uvm_info("CMP_REPORT",
                      {$sformatf("  Correct Checks : %0d\n", apb_correct_count),
                       $sformatf("  Failed Checks  : %0d\n", apb_error_count),
                       $sformatf("  Total Checks   : %0d\n", apb_total),
                       $sformatf("  Pass Rate      : %0.2f%%\n",
                                 (apb_total != 0) ? (100.0 * apb_correct_count / apb_total) : 0.0)},
                      UVM_LOW)

            // ----------------------------------------------------
            //                 OVERALL SUMMARY
            // ----------------------------------------------------
            `uvm_info("CMP_REPORT",
                      {"\n==============================================\n",
                       "                 OVERALL RESULT\n",
                       "==============================================\n"},
                      UVM_LOW)

            `uvm_info("CMP_REPORT",
                      {$sformatf("  Total Checks : %0d\n", total_checks),
                       $sformatf("  Total Passed : %0d\n", ahb_correct_count + apb_correct_count),
                       $sformatf("  Total Failed : %0d\n", total_errors)},
                      UVM_LOW)

            if (total_errors == 0 && total_checks != 0) begin

                `uvm_info("CMP_REPORT",
                          {"  STATUS       : *** TEST PASSED ***\n",
                           "=============================================="},
                          UVM_LOW)

            end else if (total_errors != 0) begin

                `uvm_error("CMP_REPORT",
                           {"  STATUS       : *** TEST FAILED ***\n",
                            "  Please check the comparison errors above.\n",
                            "=============================================="})

            end else begin

                `uvm_warning("CMP_REPORT",
                             {"  STATUS       : *** NO CHECKS PERFORMED ***\n",
                              "=============================================="})
            end

        endfunction : report_phase

    endclass : ahb2apb_comparator

endpackage : ahb2apb_comparator_pkg