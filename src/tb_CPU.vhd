library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cpu_part4 is
    -- A testbench has no external ports
end entity tb_cpu_part4;

architecture behavior of tb_cpu_part4 is

    -- Component Declaration for the CPU (Unit Under Test)
    component CPU is
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            
            -- Memory programming interface (tied to 0 since we use program.txt)
            prog_we         : in std_logic;
            prog_addr       : in std_logic_vector(5 downto 0);
            prog_data       : in std_logic_vector(5 downto 0);
            
            -- Debug outputs for waveform visualization
            r0_debug        : out std_logic_vector(5 downto 0);
            r1_debug        : out std_logic_vector(5 downto 0);
            r2_debug        : out std_logic_vector(5 downto 0);
            r3_debug        : out std_logic_vector(5 downto 0);
            pc_debug        : out std_logic_vector(5 downto 0);
            ir_debug        : out std_logic_vector(5 downto 0);
            memory_debug    : out std_logic_vector(5 downto 0);
            alu_debug       : out std_logic_vector(5 downto 0);
            bus_debug       : out std_logic_vector(5 downto 0);
            mul_acc_debug   : out std_logic_vector(5 downto 0);
            mul_count_debug : out std_logic_vector(5 downto 0);
            state_debug     : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Stimulus signals
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal prog_we   : std_logic := '0';
    signal prog_addr : std_logic_vector(5 downto 0) := (others => '0');
    signal prog_data : std_logic_vector(5 downto 0) := (others => '0');

    -- Observation signals
    signal r0_debug, r1_debug, r2_debug, r3_debug : std_logic_vector(5 downto 0);
    signal pc_debug, ir_debug, memory_debug       : std_logic_vector(5 downto 0);
    signal alu_debug, bus_debug                   : std_logic_vector(5 downto 0);
    signal mul_acc_debug, mul_count_debug         : std_logic_vector(5 downto 0);
    signal state_debug                            : std_logic_vector(2 downto 0);

    -- Clock period definition (10 ns = 100 MHz)
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the CPU
    uut: CPU port map (
        clk             => clk,
        rst             => rst,
        prog_we         => prog_we,
        prog_addr       => prog_addr,
        prog_data       => prog_data,
        r0_debug        => r0_debug,
        r1_debug        => r1_debug,
        r2_debug        => r2_debug,
        r3_debug        => r3_debug,
        pc_debug        => pc_debug,
        ir_debug        => ir_debug,
        memory_debug    => memory_debug,
        alu_debug       => alu_debug,
        bus_debug       => bus_debug,
        mul_acc_debug   => mul_acc_debug,
        mul_count_debug => mul_count_debug,
        state_debug     => state_debug
    );

    -- Continuous Clock Generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Main Simulation Sequence
    stim_proc: process
    begin
        -- 1. Initialize CPU in a Reset State
        rst <= '1';
        wait for 20 ns;
        
        -- 2. Release Reset (CPU starts fetching instruction 0 from program.txt)
        rst <= '0';
        
        -- 3. Wait for the program to finish calculating
        -- We give it 2000 ns (200 clock cycles), which is more than enough time 
        -- for the multi-cycle hardware multiplication loop to finish completely.
        wait for 2000 ns;
        
        -- The testbench process will safely pause here.
        wait;
    end process;

end architecture behavior;