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


vlog "C:/Users/ELIF/Desktop/PO/fpga/26_warning/my_clock_sim/my_clock.vo"

vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/signed_adder_substractor.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/datapath.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/control_unit.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/po_fpga_simulation.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/integer_comparator.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/integer_divider.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/integer_multiplier.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/single_port_ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/index_comparator.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/integer_parallel_adder.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/parallel_divider.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/sequential_loader.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/parallel_result_adjuster.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning/db {C:/Users/ELIF/Desktop/PO/fpga/26_warning/db/mult_73n.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/dual_port_ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/ram_module.v}

vlog -vlog01compat -work work +incdir+C:/Users/ELIF/Desktop/PO/fpga/26_warning {C:/Users/ELIF/Desktop/PO/fpga/26_warning/tb_po_fpga.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_po_fpga

add wave *
view structure
view signals
run -all
