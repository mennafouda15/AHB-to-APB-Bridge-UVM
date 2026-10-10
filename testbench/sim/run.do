proc run_task {label hclk_period pclk_period pclk_phase} {
    puts "\nRunning $label"

    vsim -coverage -voptargs=+acc \
        -gHCLK_PERIOD=$hclk_period \
        -gPCLK_PERIOD=$pclk_period \
        -gPCLK_PHASE=$pclk_phase \
        work.tb_top

    do coverage_exclusion.do
    do wave.do

    # QuestaSim's built-in simulation command
    run -all

    coverage save -codeAll -cvg -assert ${label}.ucdb
}

# Run 1: HCLK = 10ns, PCLK = 10ns, PHASE = 0ns
run_task coverage_equal         10ns 10ns 0ns

# Run 2: HCLK = 7ns, PCLK = 11ns, PHASE = 0ns
run_task coverage_hclk_faster    7ns 11ns 0ns

# Run 3: HCLK = 11ns, PCLK = 7ns, PHASE = 0ns
run_task coverage_hclk_slower   11ns  7ns 0ns

# Run 4: HCLK = 10ns, PCLK = 10ns, PHASE = 2ns
run_task coverage_different_phase 10ns 10ns 2ns

# Generate a text coverage report
coverage report -output coverage_report.txt \
-append -du=cmsdk_ahb_to_apb_async \
-du=cmsdk_ahb_to_apb_async_h \
-du=cmsdk_ahb_to_apb_async_p \
-du=cmsdk_ahb_to_apb_async_syn -detail -all -dump -annotate -option -codeAll

