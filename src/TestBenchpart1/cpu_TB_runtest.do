SetActiveLib -work
comp -include "$dsn\src\control_unit.vhd" 
comp -include "$dsn\src\alu6.vhd" 
comp -include "$dsn\src\mux4_6.vhd" 
comp -include "$dsn\src\memory6.vhd" 
comp -include "$dsn\src\register6.vhd" 
comp -include "$dsn\src\pc6.vhd" 
comp -include "$dsn\src\CPU.vhd" 
comp -include "$dsn\src\TestBench\cpu_TB.vhd" 
asim +access +r TESTBENCH_FOR_cpu 
wave 
wave -noreg clk
wave -noreg rst
wave -noreg prog_we
wave -noreg prog_addr
wave -noreg prog_data
wave -noreg r0_debug
wave -noreg r1_debug
wave -noreg r2_debug
wave -noreg r3_debug
wave -noreg pc_debug
wave -noreg ir_debug
wave -noreg memory_debug
wave -noreg alu_debug
wave -noreg bus_debug
wave -noreg state_debug
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\cpu_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_cpu 
