package ahb2apb_apb_predictor_pkg;

  import uvm_pkg::*;

  `include "uvm_macros.svh"

  import ahb_sequence_item_pkg::*;

  import apb_sequence_item_pkg::*;

  typedef ahb_sequence_item#(16) ahb_seq_item_t;

	typedef apb_sequence_item#(16) apb_seq_item_t;

  class ahb2apb_apb_predictor extends uvm_subscriber #(ahb_seq_item_t);
    `uvm_component_utils(ahb2apb_apb_predictor)

    uvm_analysis_port #(apb_seq_item_t) apb_exp_aport;

    function new(string name = "ahb2apb_apb_predictor", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      apb_exp_aport = new("apb_exp_aport", this);
    endfunction : build_phase

    virtual function void write(ahb_seq_item_t t);
      apb_seq_item_t apb_exp_seq_item;

      `uvm_info("DEBUG","Broadcast Apb prediction using analysis port",UVM_HIGH); // check predictor is sending to the comparator

      apb_exp_seq_item = apb_seq_item_t::type_id::create("apb_exp_seq_item");
      apb_exp_out(t, apb_exp_seq_item);
      
      if (apb_exp_seq_item.PSEL)
        apb_exp_aport.write(apb_exp_seq_item);
    endfunction : write

    // calculate expected apb outputs
    function void apb_exp_out(input ahb_seq_item_t data_in, inout apb_seq_item_t data_out);
      `uvm_info("DEBUG","APB Expected Output Funtion Had Been Called",UVM_HIGH) // check predictor has called the calc function

      // PADDR
      data_out.PADDR = {data_in.HADDR[15:2],2'b00};

      // PWRITE
      data_out.PWRITE = data_in.HWRITE;

      // PPROT
      data_out.PPROT = {~data_in.HPROT[0], 1'b0, data_in.HPROT[1]};

      // PWDATA
      data_out.PWDATA = data_in.HWDATA;

      // PSEL
      data_out.PSEL = data_in.HSEL & data_in.HTRANS[1];

      // PENABLE
      data_out.PENABLE = 1'b1;

      // APBACTIVE
      data_out.APBACTIVE = 1'b1;

      // PSTRB
      if (data_in.HWRITE) begin

          case (data_in.HSIZE)

              3'b000: begin // byte
                  case (data_in.HADDR[1:0])
                      2'b00: data_out.PSTRB = 4'b0001;
                      2'b01: data_out.PSTRB = 4'b0010;
                      2'b10: data_out.PSTRB = 4'b0100;
                      2'b11: data_out.PSTRB = 4'b1000;
                  endcase
              end

              3'b001  : data_out.PSTRB = (data_in.HADDR[1]) ? 'b1100 : 'b0011; // half-word

              3'b010  : data_out.PSTRB = 'b1111; // word
         
              default : data_out.PSTRB = 'b0000;
          endcase
      end else begin
        data_out.PSTRB = 'b0000;
      end
    endfunction : apb_exp_out
    
  endclass : ahb2apb_apb_predictor
  
endpackage : ahb2apb_apb_predictor_pkg