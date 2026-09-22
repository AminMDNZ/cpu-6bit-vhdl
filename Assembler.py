import sys

def assemble_from_file(input_filename, output_filename):
    """
    Reads a custom 6-bit assembly file and converts it into binary machine code.
    """
    # Instruction Set Architecture (ISA) Mapping
    registers = {'R0': '00', 'R1': '01', 'R2': '10', 'R3': '11'}
    machine_code = []
    
    try:
        with open(input_filename, 'r') as f:
            lines = f.readlines()
            
        print(f"Translating {input_filename} to binary...")
        
        for line_num, line in enumerate(lines):
            # Strip comments (anything after ';') and whitespace
            clean_line = line.split(';')[0].strip()
            if not clean_line: 
                continue # Skip empty lines
            
            # Standardize spacing and split the instruction parts
            parts = clean_line.replace(',', ' ').split()
            instruction = parts[0].upper()
            
            try:
                if instruction == 'LOAD':
                    # Format: 00 Rx 00 \n VALUE
                    rx = registers[parts[1].upper()]
                    val = format(int(parts[2]), '06b') # Convert integer to 6-bit binary
                    machine_code.append(f"00{rx}00")
                    machine_code.append(val)
                    
                elif instruction == 'ADD':
                    # Format: 01 Rx Ry
                    rx = registers[parts[1].upper()]
                    ry = registers[parts[2].upper()]
                    machine_code.append(f"01{rx}{ry}")
                    
                elif instruction == 'SUB':
                    # Format: 10 Rx Ry
                    rx = registers[parts[1].upper()]
                    ry = registers[parts[2].upper()]
                    machine_code.append(f"10{rx}{ry}")
                    
                elif instruction == 'JNZ':
                    # Format: 11 Rx 00 \n ADDRESS
                    rx = registers[parts[1].upper()]
                    addr = format(int(parts[2]), '06b')
                    machine_code.append(f"11{rx}00")
                    machine_code.append(addr)
                    
                elif instruction == 'MUL':
                    # Format: 11 Rx 01 \n 0000 Ry (From your Part 3 Hardware Extension)
                    rx = registers[parts[1].upper()]
                    ry = registers[parts[2].upper()]
                    machine_code.append(f"11{rx}01")
                    machine_code.append(f"0000{ry}")
                    
                else:
                    print(f"Warning: Unknown instruction '{instruction}' on line {line_num + 1}")
                    
            except KeyError as e:
                print(f"Error on line {line_num + 1}: Invalid register {e}")
                return
            except ValueError:
                print(f"Error on line {line_num + 1}: Invalid number format")
                return

        # Write the compiled binary to the output file
        with open(output_filename, 'w') as f_out:
            for code in machine_code:
                f_out.write(code + '\n')
                
        print(f"Success! {len(machine_code)} lines of machine code written to {output_filename}")
                
    except FileNotFoundError:
        print(f"Error: Could not find the file '{input_filename}'. Make sure it exists.")
    except Exception as e:
        print(f"Unexpected error: {e}")

# Run the assembler
if __name__ == "__main__":
    # Input: your assembly text | Output: the binary file for VHDL
    assemble_from_file('code.asm', 'program.txt')