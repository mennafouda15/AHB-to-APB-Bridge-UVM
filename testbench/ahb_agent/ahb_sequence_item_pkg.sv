package ahb_sequence_item_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh"

	class ahb_sequence_item #(parameter ADDRWIDTH = 16) extends uvm_sequence_item;

		`uvm_object_param_utils(ahb_sequence_item #(ADDRWIDTH))

		function new(string name = "ahb_sequence_item");
			super.new(name);	
		endfunction : new

        // Request
        rand     logic                         HSEL   ;     
        rand     logic     [ADDRWIDTH-1:0]     HADDR  ; 
        rand     logic     [1:0]               HTRANS ;   
        rand     logic     [2:0]               HSIZE  ;   
        rand     logic     [3:0]               HPROT  ; 
        rand     logic                         HWRITE ;      
        rand     logic     [31:0]              HWDATA ; 
        
        // Response
        logic                HREADYOUT   ;
        logic     [31:0]     HRDATA      ;    
        logic                HRESP       ;  
        int                  wait_states ;
 

        constraint hsel_c { soft HSEL dist { 1:=90 , 0:=10}; }
        constraint htrans_c { soft HTRANS dist { 2'b10:=60 , 2'b00:=40 }; }
        constraint hwrite_c { soft HWRITE dist { 1:=70 , 0:=30 }; }
        constraint hsize_c { soft HSIZE inside {[0:2]}; }
        constraint hwdata_c { soft HWRITE == 0 -> HWDATA == '0 ; }
        constraint haddr_alignment_c {
            HSIZE == 3'b001 -> (HADDR%2 == 0) ;
            HSIZE == 3'b010 -> (HADDR%4 == 0) ; }

        function string convert2string();
        	return $sformatf("HSEL = %d || HWRITE = %d || HADDR = 0X%h || HWDATA = 0X%h || HSIZE = %b || HTRANS = %b || HPROT = %b" , 
        		HSEL , HWRITE , HADDR , HWDATA , HSIZE , HTRANS , HPROT);	
        endfunction : convert2string
		
	endclass : ahb_sequence_item	
	
endpackage : ahb_sequence_item_pkg

