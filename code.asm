LOAD R0, 6    ; PC 0, 1: Load 6 into R0
LOAD R1, 8    ; PC 2, 3: Load 8 into R1
MUL R0, R1    ; PC 4, 5: Hardware Multiply! R0 = 48
LOAD R3, 1    ; PC 6, 7: Load 1 into R3 to create a true condition
JNZ R3, 8     ; PC 8, 9: Jump back to address 8 infinitely