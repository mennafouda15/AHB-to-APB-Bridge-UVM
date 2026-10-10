package ahb_apb_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Import Sequence Packages
    import ahb_sequence_item_pkg::*;
    import apb_sequence_item_pkg::*;

    import ahb_base_sequence_pkg::*;
    import ahb_back2back_read_sequence_pkg::*;
    import ahb_back2back_write_sequence_pkg::*;
    import ahb_htrans_transition_sequence_pkg::*;
    import ahb_random_back2back_read_write_sequence_pkg::*;
    import ahb_random_read_write_sequence_pkg::*;
    import ahb_read_sequence_pkg::*;
    import ahb_write_sequence_pkg::*;
    import ahb_unmatched_req_reset_sequence_pkg::*;

    import apb_sequence_pkg::*;

    import reset_sequence_pkg::*;
    import ahb_idle_sequence_pkg::*;
    

    import ahb2apb_environment_pkg::*;

    import apb_config_pkg::*;
    import ahb_config_pkg::*;

    class ahb_apb_base_test extends uvm_test;

        `uvm_component_utils(ahb_apb_base_test)

        // Environment and Configurations
        ahb2apb_environment env;
        ahb_config  ahb_cfg;
        apb_config  apb_cfg;

        // Reset Sequence
        reset_sequence rst_seq;

        // AHB Sequences
        ahb_base_sequence                    base_seq;
        ahb_back2back_read_sequence          back2back_read_seq;
        ahb_back2back_write_sequence         back2back_write_seq;
        ahb_htrans_transition_sequence       htrans_transition_seq;
        ahb_random_back2back_read_write_sequence random_back2back_rw_seq;
        ahb_random_read_write_sequence       random_rw_seq;
        ahb_read_sequence                    read_seq;
        ahb_write_sequence                   write_seq;
        ahb_idle_sequence                    idle_seq;
        ahb_unmatched_req_reset_sequence     unmatched_seq;


        // APB Sequence
        apb_sequence apb_seq;

        function new(string name = "ahb_apb_base_test",
                     uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            // Create Environment
            env = ahb2apb_environment::type_id::create("env", this);

            // Create and set up AHB Configuration
            ahb_cfg = ahb_config::type_id::create("ahb_cfg");

            if (!uvm_config_db#(virtual ahb_if)::get(
                    this, "", "ahb_vif", ahb_cfg.ahb_vif))
                `uvm_fatal(get_type_name(),
                           "Failed to get AHB virtual interface")

            uvm_config_db#(ahb_config)::set(
                this, "*", "ahb_cfg", ahb_cfg);

            // Create and set up APB Configuration
            apb_cfg = apb_config::type_id::create("apb_cfg");

            if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_cfg.apb_vif))
                `uvm_fatal(get_type_name(),"Failed to get APB virtual interface")

            uvm_config_db#(apb_config)::set(this, "*", "apb_cfg", apb_cfg);

            // Instantiate Sequences
            base_seq = ahb_base_sequence#()::type_id::create("base_seq");

            rst_seq = reset_sequence::type_id::create("rst_seq");

            apb_seq = apb_sequence::type_id::create("apb_seq");

            write_seq = ahb_write_sequence#()::type_id::create("write_seq");

            read_seq = ahb_read_sequence#()::type_id::create("read_seq");

            back2back_write_seq = ahb_back2back_write_sequence#()::type_id::create("back2back_write_seq");

            back2back_read_seq = ahb_back2back_read_sequence#()::type_id::create("back2back_read_seq");

            random_back2back_rw_seq = ahb_random_back2back_read_write_sequence#()::type_id::create("random_back2back_rw_seq");

            random_rw_seq = ahb_random_read_write_sequence#()::type_id::create("random_rw_seq");

            htrans_transition_seq = ahb_htrans_transition_sequence#()::type_id::create("htrans_transition_seq");

            idle_seq = ahb_idle_sequence#()::type_id::create("idle_seq");

            unmatched_seq = ahb_unmatched_req_reset_sequence#()::type_id::create("unmatched_seq");

        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);

            `uvm_info(get_type_name(), "Starting AHB-APB Base Test", UVM_LOW)

            // 1. Run Reset Sequence
            `uvm_info(get_type_name(), "Apply System Reset", UVM_LOW)
            rst_seq.start(null);
            rst_seq.both_reset();
            `uvm_info(get_type_name(), "Finish System Reset", UVM_LOW)

            // 2. Start APB Sequence in the Background
            fork
                apb_seq.start(env.apb_agt.seqr);
            join_none

            // 3. Start AHB Write Sequence
            `uvm_info(get_type_name(),"Apply WRITE sequence", UVM_LOW)
            write_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(),"Finish WRITE sequence", UVM_LOW)

            // 4. Start AHB Read Sequence
            `uvm_info(get_type_name(), "Apply READ sequence", UVM_LOW)
            read_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(), "Finish READ sequence", UVM_LOW)

            // 5. Start AHB Back-to-Back Write Sequence
            `uvm_info(get_type_name(), "Apply BACK-TO-BACK WRITE sequence", UVM_LOW)
            back2back_write_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(), "Finish BACK-TO-BACK WRITE sequence", UVM_LOW)

            // 6. Start AHB Back-to-Back Read Sequence
            `uvm_info(get_type_name(), "Apply BACK-TO-BACK READ sequence", UVM_LOW)
            back2back_read_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(), "Finish BACK-TO-BACK READ sequence", UVM_LOW)

            // 7. Start AHB Random Back-to-Back Read/Write Sequence
            `uvm_info(get_type_name(), "Apply RANDOM BACK-TO-BACK READ/WRITE sequence", UVM_LOW)
            random_back2back_rw_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(), "Finish RANDOM BACK-TO-BACK READ/WRITE sequence", UVM_LOW)

            // 8. Start AHB Random Read/Write Sequence
            `uvm_info(get_type_name(), "Apply RANDOM READ/WRITE sequence", UVM_LOW)
            random_rw_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(), "Finish RANDOM READ/WRITE sequence", UVM_LOW)

            // 9. Start AHB TRANSITION Sequence
            `uvm_info(get_type_name(), "Apply HTRANS TRANSITION sequence", UVM_LOW)
            htrans_transition_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(), "Finish HTRANS TRANSITION sequence", UVM_LOW)

            // 10. Start Idle Sequence
            `uvm_info(get_type_name(), "Apply Idle sequence", UVM_LOW)
            idle_seq.start(env.ahb_agt.seqr);
            `uvm_info(get_type_name(), "Finish Idle sequence", UVM_LOW)

            // 11. Start Reset After Idle Sequence
            `uvm_info(get_type_name(), "Apply Reset After sequence", UVM_LOW)
            rst_seq.both_reset();
            `uvm_info(get_type_name(), "Finish Reset After sequence", UVM_LOW)

            // 12. Start Reset During APB Setup Phase Sequence
            `uvm_info(get_type_name(), "Start Reset during APB setup phase sequence", UVM_LOW)
            reset_during_apb_setup();
            `uvm_info(get_type_name(), "Finish Reset during APB setup phase sequence", UVM_LOW)

            // 12. Start Reset During APB Access Phase Sequence
            `uvm_info(get_type_name(), "Start Reset during APB access phase sequence", UVM_LOW)
            reset_during_apb_access();
            `uvm_info(get_type_name(), "Finsh Reset during APB access phase sequence", UVM_LOW)

            // 13. Start Reset During AHB Data Phase Sequence
            `uvm_info(get_type_name(), "Start Reset during AHB data phase sequence", UVM_LOW)
            reset_during_ahb_data();
            `uvm_info(get_type_name(), "Finsh Reset during AHB data phase sequence", UVM_LOW)

            // 14. Start Invalid data request
            `uvm_info(get_type_name(), "Start request/acknowledgment mismatch sequence", UVM_LOW)

            // Disable the assertion for this sequence
            ahb_cfg.ahb_vif.ignore_hs3_check = 1;

            unmatched_seq.mode = RESET_AHB_ONLY;
            unmatched_seq.start(env.ahb_agt.seqr);

            unmatched_seq.mode = RESET_APB_GLITCH;
            unmatched_seq.start(env.ahb_agt.seqr);

            // Re-enable the assertion
            ahb_cfg.ahb_vif.ignore_hs3_check = 0;
            
            `uvm_info(get_type_name(), "Finish request/acknowledgment mismatch sequence", UVM_LOW)

            // Allow final responses to propagate back to AHB
            #1000000;

            `uvm_info(get_type_name(), "AHB-APB Base Test Completed", UVM_LOW)

            phase.drop_objection(this);

        endtask : run_phase


        
        task reset_during_apb_access();

            ahb_write_sequence reset_write_seq_1;

            reset_write_seq_1 = ahb_write_sequence#()::type_id::create("reset_write_seq_1");

            `uvm_info(get_type_name(), "Starting reset-during-APB-access test", UVM_LOW)

            fork : reset_test_fork

                begin
                    reset_write_seq_1.start(env.ahb_agt.seqr);
                end

                begin
                    // Wait until the APB access phase is active
                    // and the slave is holding the transfer.
                    wait (apb_cfg.apb_vif.PSEL &&
                          apb_cfg.apb_vif.PENABLE &&
                          !apb_cfg.apb_vif.PREADY);

                    `uvm_info(get_type_name(),
                        "APB access stalled; asserting reset", UVM_LOW)

                    rst_seq.both_reset();

                    // Explicitly terminate the interrupted sequence.
                    reset_write_seq_1.kill();
                end

            join

            `uvm_info(get_type_name(), "Reset-during-APB-access test completed", UVM_LOW)

        endtask : reset_during_apb_access


        task reset_during_apb_setup();

            ahb_write_sequence reset_write_seq_2;

            reset_write_seq_2 = ahb_write_sequence#()::type_id::create("reset_write_seq_2");

            `uvm_info(get_type_name(), "Starting reset-during-APB-setup test", UVM_LOW)

            fork : reset_test_fork

                begin
                    reset_write_seq_2.start(env.ahb_agt.seqr);
                end

                begin
                    // Wait until the APB setup phase is active
                    // and the slave is holding the transfer.
                    wait (apb_cfg.apb_vif.PSEL &&
                          !apb_cfg.apb_vif.PENABLE &&
                          !apb_cfg.apb_vif.PREADY);

                    `uvm_info(get_type_name(), "APB setup stalled; asserting reset", UVM_LOW)

                    rst_seq.both_reset();

                    // Explicitly terminate the interrupted sequence.
                    reset_write_seq_2.kill();
                end

            join

            `uvm_info(get_type_name(), "Reset-during-APB-setup test completed", UVM_LOW)

        endtask : reset_during_apb_setup

        
        task reset_during_ahb_data();

            ahb_write_sequence reset_write_seq_3;

            reset_write_seq_3 = ahb_write_sequence#()::type_id::create("reset_write_seq_3");

            `uvm_info(get_type_name(), "Starting reset-during-AHB-data test", UVM_LOW)

            fork : reset_test_fork

                begin
                    reset_write_seq_3.start(env.ahb_agt.seqr);
                end

                begin
                    // Wait for an accepted AHB write address phase.
                    do begin
                        @(posedge ahb_cfg.ahb_vif.HCLK);
                    end while (!(ahb_cfg.ahb_vif.HSEL &&
                                 ahb_cfg.ahb_vif.HTRANS[1] &&
                                 ahb_cfg.ahb_vif.HWRITE &&
                                 ahb_cfg.ahb_vif.HREADY));

                    // Move to the falling edge to avoid racing the driver.
                    @(negedge ahb_cfg.ahb_vif.HCLK);

                    `uvm_info(get_type_name(), "AHB write accepted; asserting reset during data phase", UVM_LOW)

                    rst_seq.both_reset();

                    reset_write_seq_3.kill();
                end

            join

            `uvm_info(get_type_name(), "Reset-during-AHB-data test completed", UVM_LOW)
        endtask : reset_during_ahb_data

    endclass : ahb_apb_base_test

endpackage : ahb_apb_test_pkg