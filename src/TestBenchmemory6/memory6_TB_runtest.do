SetActiveLib -work
comp -include "$dsn\src\memory6.vhd" 
comp -include "$dsn\src\TestBench\memory6_TB.vhd" 
asim +access +r TESTBENCH_FOR_memory6 
wave 
wave -noreg clk
wave -noreg prog_we
wave -noreg prog_addr
wave -noreg prog_data
wave -noreg cpu_addr
wave -noreg cpu_data
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\memory6_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_memory6 
