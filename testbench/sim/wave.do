onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} -color Magenta /tb_top/dut/HCLK
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HRESETn
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HADDR
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HPROT
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HREADY
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HSEL
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HSIZE
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HTRANS
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HWDATA
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB INPUTS} /tb_top/dut/HWRITE
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB OUTPUTS} -color Orange /tb_top/dut/HRDATA
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB OUTPUTS} -color Orange /tb_top/dut/HREADYOUT
add wave -noupdate -expand -group {AHB SIGNALS} -expand -group {AHB OUTPUTS} -color Orange /tb_top/dut/HRESP
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB INPUTS} -color Magenta /tb_top/dut/PCLK
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB INPUTS} /tb_top/dut/PRESETn
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB INPUTS} /tb_top/dut/PRDATA
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB INPUTS} /tb_top/dut/PREADY
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB INPUTS} /tb_top/dut/PSLVERR
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/APBACTIVE
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/PADDR
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/PENABLE
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/PPROT
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/PSEL
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/PSTRB
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/PWDATA
add wave -noupdate -expand -group {APB SIGNALS} -expand -group {APB OUTPUTS} -color Orange /tb_top/dut/PWRITE
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_ack_h
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_ack_p
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_addr
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_prot
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_rdata
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_req_h
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_req_p
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_resp
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_strb
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_trans_valid
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_wdata
add wave -noupdate -expand -group {BRIDGE SIGNALS} /tb_top/dut/s_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {39262 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {130488 ps}
