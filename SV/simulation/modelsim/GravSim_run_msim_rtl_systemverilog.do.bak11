transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV {C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/FPU.v}
vlib nios_system
vmap nios_system nios_system
vlog -sv -work nios_system +incdir+C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/nios_system/synthesis/submodules {C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/nios_system/synthesis/submodules/avalon_interface.sv}
vlog -sv -work work +incdir+C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV {C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/ball.sv}
vlog -sv -work work +incdir+C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV {C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/FSM.sv}

vlog -sv -work work +incdir+C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV {C:/Users/anish/Documents/ECE_385/Final_Project/GravSim/SV/testbench_FSM.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -L nios_system -voptargs="+acc"  testbench_FSM

add wave *
view structure
view signals
run 10000 ns
