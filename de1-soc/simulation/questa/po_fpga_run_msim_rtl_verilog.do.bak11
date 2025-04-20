transcript on
if ![file isdirectory po_fpga_iputf_libs] {
	file mkdir po_fpga_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog "D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/my_clock_sim/my_clock.vo"

vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/signed_adder_substractor.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/dual_port_ram.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/datapath.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/control_unit.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/po_fpga_simulation.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/integer_comparator.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/integer_divider.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/integer_multiplier.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/single_port_ram.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/index_comparator.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/ram_module.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/integer_parallel_adder.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/parallel_divider.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/sequential_loader.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/parallel_result_adjuster.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/db {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/db/mult_73n.v}
vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/db {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/db/mult_2l01.v}

vlog -vlog01compat -work work +incdir+D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning {D:/QuartusProjects/26_warning_original_DE1_SOC_valid_cleaning/tb_po_fpga.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_po_fpga

add wave *
view structure
view signals
run -all
