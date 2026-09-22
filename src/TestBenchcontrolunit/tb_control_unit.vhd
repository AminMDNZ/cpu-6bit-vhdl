library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TESTBENCH_FOR_control_unit is
end entity TESTBENCH_FOR_control_unit;

architecture simulation of TESTBENCH_FOR_control_unit is

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal ir : std_logic_vector(5 downto 0) := (others => '0');

    signal zr0 : std_logic := '1';
    signal zr1 : std_logic := '1';
    signal zr2 : std_logic := '1';
    signal zr3 : std_logic := '1';
    
    -- Added missing mul_zero signal for Part 3
    signal mul_zero : std_logic := '0';

    signal ld0 : std_logic;
    signal ld1 : std_logic;
    signal ld2 : std_logic;
    signal ld3 : std_logic;

    signal ldir   : std_logic;
    signal ldpc   : std_logic;
    signal pc_inc : std_logic;

    -- Changed to 2-bit vector to match control_unit.vhd
    signal bus_sel : std_logic_vector(1 downto 0);
    signal alu_cmd : std_logic;
    
    -- Added missing MUL control signals
    signal mul_init : std_logic;
    signal mul_step : std_logic;

    signal state_debug : std_logic_vector(2 downto 0);

begin

    clk <= not clk after 5 ns;

    uut : entity work.control_unit
        port map (
            clk => clk,
            rst => rst,

            ir => ir,

            zr0 => zr0,
            zr1 => zr1,
            zr2 => zr2,
            zr3 => zr3,
            
            -- Mapped the new mul_zero port
            mul_zero => mul_zero,

            ld0 => ld0,
            ld1 => ld1,
            ld2 => ld2,
            ld3 => ld3,

            ldir   => ldir,
            ldpc   => ldpc,
            pc_inc => pc_inc,

            bus_sel => bus_sel,
            alu_cmd => alu_cmd,
            
            -- Mapped the new MUL outputs
            mul_init => mul_init,
            mul_step => mul_step,

            state_debug => state_debug
        );

    stimulus : process
    begin

        --------------------------------------------------
        -- Reset
        --------------------------------------------------

        rst <= '1';
        wait for 20 ns;

        rst <= '0';

        --------------------------------------------------
        -- Test LOAD R0
        --------------------------------------------------

        ir <= "000000";

        wait until rising_edge(clk); -- DECODE
        wait until rising_edge(clk); -- LOAD
        wait for 1 ns;

        assert state_debug = "010"
            report "LOAD state selection failed"
            severity failure;

        assert ld0 = '1'
            report "LOAD R0 signal failed"
            severity failure;

        -- Updated assertion for 2-bit bus_sel
        assert bus_sel = "00"
            report "LOAD bus selection failed"
            severity failure;

        assert pc_inc = '1'
            report "LOAD PC increment failed"
            severity failure;

        --------------------------------------------------
        -- LOAD -> FETCH
        --------------------------------------------------

        wait until rising_edge(clk);
        wait for 1 ns;

        assert state_debug = "000"
            report "Return to FETCH after LOAD failed"
            severity failure;

        --------------------------------------------------
        -- Test ADD R0, R1
        --------------------------------------------------

        ir <= "010001";

        wait until rising_edge(clk); -- DECODE
        wait until rising_edge(clk); -- ADD
        wait for 1 ns;

        assert state_debug = "011"
            report "ADD state selection failed"
            severity failure;

        assert ld0 = '1'
            report "ADD destination register failed"
            severity failure;

        -- Updated assertion for 2-bit bus_sel
        assert bus_sel = "01"
            report "ADD bus selection failed"
            severity failure;

        assert alu_cmd = '0'
            report "ADD ALU command failed"
            severity failure;

        --------------------------------------------------
        -- ADD -> FETCH
        --------------------------------------------------

        wait until rising_edge(clk);
        wait for 1 ns;

        --------------------------------------------------
        -- Test SUB R2, R3
        --------------------------------------------------

        ir <= "101011";

        wait until rising_edge(clk); -- DECODE
        wait until rising_edge(clk); -- SUB
        wait for 1 ns;

        assert state_debug = "100"
            report "SUB state selection failed"
            severity failure;

        assert ld2 = '1'
            report "SUB destination register failed"
            severity failure;

        -- Updated assertion for 2-bit bus_sel
        assert bus_sel = "01"
            report "SUB bus selection failed"
            severity failure;

        assert alu_cmd = '1'
            report "SUB ALU command failed"
            severity failure;

        --------------------------------------------------
        -- SUB -> FETCH
        --------------------------------------------------

        wait until rising_edge(clk);
        wait for 1 ns;

        --------------------------------------------------
        -- Test JNZ R1 when R1 is not zero
        --------------------------------------------------

        ir  <= "110100";
        zr1 <= '0';

        wait until rising_edge(clk); -- DECODE
        wait until rising_edge(clk); -- JNZ
        wait for 1 ns;

        assert state_debug = "101"
            report "JNZ state selection failed"
            severity failure;

        assert ldpc = '1'
            report "JNZ taken branch failed"
            severity failure;

        assert pc_inc = '0'
            report "JNZ taken PC increment error"
            severity failure;

        --------------------------------------------------
        -- JNZ -> FETCH
        --------------------------------------------------

        wait until rising_edge(clk);
        wait for 1 ns;

        --------------------------------------------------
        -- Test JNZ R1 when R1 is zero
        --------------------------------------------------

        ir  <= "110100";
        zr1 <= '1';

        wait until rising_edge(clk); -- DECODE
        wait until rising_edge(clk); -- JNZ
        wait for 1 ns;

        assert state_debug = "101"
            report "Second JNZ state selection failed"
            severity failure;

        assert ldpc = '0'
            report "JNZ zero branch incorrectly loaded PC"
            severity failure;

        assert pc_inc = '1'
            report "JNZ zero branch did not increment PC"
            severity failure;

        report "All Control Unit tests passed successfully."
            severity note;

        wait;

    end process;

end architecture simulation;