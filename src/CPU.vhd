library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU is
    port (
        clk, rst : in std_logic;
        prog_we   : in std_logic;
        prog_addr, prog_data : in std_logic_vector(5 downto 0);
        r0_debug, r1_debug, r2_debug, r3_debug : out std_logic_vector(5 downto 0);
        pc_debug, ir_debug : out std_logic_vector(5 downto 0);
        memory_debug, alu_debug, bus_debug : out std_logic_vector(5 downto 0);
        mul_acc_debug, mul_count_debug : out std_logic_vector(5 downto 0);
        state_debug : out std_logic_vector(2 downto 0)
    );
end entity CPU;

architecture structural of CPU is
    signal r0_out, r1_out, r2_out, r3_out : std_logic_vector(5 downto 0);
    signal zr0, zr1, zr2, zr3 : std_logic;
    signal pc_out, ir_out, memory_data, bus_data : std_logic_vector(5 downto 0);
    signal rx_value, ry_value, alu_input_a, alu_input_b, alu_result : std_logic_vector(5 downto 0);
    signal ry_select : std_logic_vector(1 downto 0);
    signal mul_acc, mul_value, mul_count : std_logic_vector(5 downto 0) := (others => '0');
    signal mul_zero : std_logic;
    signal ld0, ld1, ld2, ld3, ldir, ldpc, pc_inc, alu_cmd, mul_init, mul_step : std_logic;
    signal bus_sel : std_logic_vector(1 downto 0);
    signal state_internal : std_logic_vector(2 downto 0);
begin
    u_r0 : entity work.register6 port map(clk=>clk, rst=>rst, load=>ld0, data_in=>bus_data, data_out=>r0_out, zero=>zr0);
    u_r1 : entity work.register6 port map(clk=>clk, rst=>rst, load=>ld1, data_in=>bus_data, data_out=>r1_out, zero=>zr1);
    u_r2 : entity work.register6 port map(clk=>clk, rst=>rst, load=>ld2, data_in=>bus_data, data_out=>r2_out, zero=>zr2);
    u_r3 : entity work.register6 port map(clk=>clk, rst=>rst, load=>ld3, data_in=>bus_data, data_out=>r3_out, zero=>zr3);
    
    u_pc : entity work.pc6 port map(clk=>clk, rst=>rst, load=>ldpc, increment=>pc_inc, data_in=>bus_data, data_out=>pc_out);
    u_ir : entity work.register6 port map(clk=>clk, rst=>rst, load=>ldir, data_in=>memory_data, data_out=>ir_out, zero=>open);
    
    u_memory : entity work.memory6 port map(clk=>clk, prog_we=>prog_we, prog_addr=>prog_addr, prog_data=>prog_data, cpu_addr=>pc_out, cpu_data=>memory_data);
    
    u_mux_a : entity work.mux4_6 port map(input0=>r0_out, input1=>r1_out, input2=>r2_out, input3=>r3_out, sel=>ir_out(3 downto 2), data_out=>rx_value);
    
    ry_select <= memory_data(1 downto 0) when mul_init = '1' else ir_out(1 downto 0);
    u_mux_b : entity work.mux4_6 port map(input0=>r0_out, input1=>r1_out, input2=>r2_out, input3=>r3_out, sel=>ry_select, data_out=>ry_value);

    alu_input_a <= mul_acc when mul_step = '1' else rx_value;
    alu_input_b <= mul_value when mul_step = '1' else ry_value;
    u_alu : entity work.alu6 port map(input_a=>alu_input_a, input_b=>alu_input_b, command=>alu_cmd, result=>alu_result);

    mul_zero <= '1' when mul_count = "000000" else '0';
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mul_acc <= (others => '0'); mul_value <= (others => '0'); mul_count <= (others => '0');
            elsif mul_init = '1' then
                mul_acc <= (others => '0'); mul_value <= rx_value; mul_count <= ry_value;
            elsif mul_step = '1' then
                mul_acc <= alu_result; mul_count <= std_logic_vector(unsigned(mul_count) - 1);
            end if;
        end if;
    end process;

    with bus_sel select
        bus_data <= memory_data when "00", alu_result when "01", mul_acc when "10", (others => '0') when others;

    u_control : entity work.control_unit port map(
        clk=>clk, rst=>rst, ir=>ir_out, zr0=>zr0, zr1=>zr1, zr2=>zr2, zr3=>zr3, mul_zero=>mul_zero,
        ld0=>ld0, ld1=>ld1, ld2=>ld2, ld3=>ld3, ldir=>ldir, ldpc=>ldpc, pc_inc=>pc_inc,
        bus_sel=>bus_sel, alu_cmd=>alu_cmd, mul_init=>mul_init, mul_step=>mul_step, state_debug=>state_internal
    );

    r0_debug <= r0_out; r1_debug <= r1_out; r2_debug <= r2_out; r3_debug <= r3_out;
    pc_debug <= pc_out; ir_debug <= ir_out; memory_debug <= memory_data;
    alu_debug <= alu_result; bus_debug <= bus_data;
    mul_acc_debug <= mul_acc; mul_count_debug <= mul_count; state_debug <= state_internal;
end architecture structural;