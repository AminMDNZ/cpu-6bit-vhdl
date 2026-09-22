SetActiveLib -work
comp -include "$dsn\src\control_unit.vhd" 
comp -include "$dsn\src\TestBench\tb_control_unit.vhd" 
asim +access +r TESTBENCH_FOR_control_unit 
wave 
wave -noreg clk
wave -noreg rst
wave -noreg ir
wave -noreg zr0
wave -noreg zr1
wave -noreg zr2
wave -noreg zr3
wave -noreg ld0
wave -noreg ld1
wave -noreg ld2
wave -noreg ld3
wave -noreg ldir
wave -noreg ldpc
wave -noreg pc_inc
wave -noreg bus_sel
wave -noreg alu_cmd
wave -noreg state_debug
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\tb_control_unit_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_control_unit 
