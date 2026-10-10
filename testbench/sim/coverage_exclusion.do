# Sync enable always = 1
coverage exclude -scope /tb_top/dut/u_ahb_to_apb_async_syn_1 -togglenode enable
coverage exclude -scope /tb_top/dut/u_ahb_to_apb_async_syn_2 -togglenode enable
coverage exclude -srcfile ../RTL/cmsdk_ahb_to_apb_async_syn.v -linerange 53 -allfalse -code b

# DATA MAX WIDTH = 32
coverage exclude -scope /tb_top/dut/u_ahb_to_apb_async_h -togglenode HSIZE[2]

# PPROT[1] always = 0
coverage exclude -scope /tb_top/dut/u_ahb_to_apb_async_p -togglenode PPROT[1]

# PADDR [1:0] always = 0
coverage exclude -scope /tb_top/dut/u_ahb_to_apb_async_p -togglenode {PADDR[1:0]} 

# FSM default state 
coverage exclude -src ../RTL/cmsdk_ahb_to_apb_async_h.v -line 196
coverage exclude -src ../RTL/cmsdk_ahb_to_apb_async_h.v -line 197
coverage exclude -du cmsdk_ahb_to_apb_async_h -fstate curr_state xx
coverage exclude -src ../RTL/cmsdk_ahb_to_apb_async_p.v -line 134
coverage exclude -src ../RTL/cmsdk_ahb_to_apb_async_p.v -line 135
coverage exclude -du cmsdk_ahb_to_apb_async_p -fstate curr_state xx

# unaligned addresses
coverage exclude -src ../RTL/cmsdk_ahb_to_apb_async_h.v -line 126
coverage exclude -src ../RTL/cmsdk_ahb_to_apb_async_h.v -line 128


