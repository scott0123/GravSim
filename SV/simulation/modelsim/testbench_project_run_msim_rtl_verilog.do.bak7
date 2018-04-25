transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV {C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/FPU.v}

vlog -sv -work work +incdir+C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV {C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/testbench_FPU.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench_FPU

add wave *
view structure
view signals
run 1000 ns
