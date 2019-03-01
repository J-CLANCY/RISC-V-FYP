----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Joseph Clancy (JC)
-- 
-- Module Name: RISCV_RegBank_TB - RTL
-- Description: Register Bank module testbench of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RISCV_RegBank_TB is
end RISCV_RegBank_TB;

architecture TB of RISCV_RegBank_TB is

    component RISCV_RegBank
        port (clk      : in std_logic;
              rst_b    : in std_logic;
              reg_wr   : in std_logic;
              rs1_addr : in std_logic_vector (4 downto 0);
              rs2_addr : in std_logic_vector (4 downto 0);
              rd_addr  : in std_logic_vector (4 downto 0);
              rd_data  : in std_logic_vector (31 downto 0);
              rs1_data : out std_logic_vector (31 downto 0);
              rs2_data : out std_logic_vector (31 downto 0));
    end component;

    signal clk      : std_logic;
    signal rst_b    : std_logic;
    signal reg_wr   : std_logic;
    signal rs1_addr : std_logic_vector (4 downto 0);
    signal rs2_addr : std_logic_vector (4 downto 0);
    signal rd_addr  : std_logic_vector (4 downto 0);
    signal rd_data  : std_logic_vector (31 downto 0);
    signal rs1_data : std_logic_vector (31 downto 0);
    signal rs2_data : std_logic_vector (31 downto 0);

    constant period : time := 20 ns;
    signal clock : std_logic := '0';
    signal sim_ended : std_logic := '0';

begin

    dut : RISCV_RegBank
    port map (clk      => clk,
              rst_b    => rst_b,
              reg_wr   => reg_wr,
              rs1_addr => rs1_addr,
              rs2_addr => rs2_addr,
              rd_addr  => rd_addr,
              rd_data  => rd_data,
              rs1_data => rs1_data,
              rs2_data => rs2_data);

    -- Clock generation
    clock <= not clock after period/2 when sim_ended /= '1' else '0';
    clk <= clock;

    stimuli : process
    begin
        reg_wr <= '0';
        rs1_addr <= "00000";
        rs2_addr <= "00001";
        rd_addr <= "00000";
        rd_data <= X"AAAAAAAA";

        -- Reset generation
        rst_b <= '0';
        wait for 1.2*period;
        rst_b <= '1';
        wait for period;

        reg_wr <= '1';
        wait for period;
		rd_data <= "00001";
		wait for period;

        -- Stop the clock and hence terminate the simulation
        sim_ended <= '1';
        wait;
    end process;

end TB;