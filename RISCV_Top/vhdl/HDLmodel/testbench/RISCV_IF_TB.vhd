----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Joseph Clancy (JC)
-- 
-- Module Name: RISCV_IF_TB - RTL
-- Description: Instruction fetch module testbench of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RISCV_IF_TB is
end RISCV_IF_TB;

architecture TB of RISCV_IF_TB is

    component RISCV_IF
        port (clk       : in  std_logic;
              rst_b     : in  std_logic;
              npc       : in  std_logic_vector (31 downto 0);
              pc_plus_4 : out std_logic_vector (31 downto 0);
              pc        : out std_logic_vector (31 downto 0));
    end component;

    signal clk       		 : std_logic;
    signal rst_b     		 : std_logic;
    signal npc       		 : std_logic_vector (31 downto 0);
    signal pc_plus_4 		 : std_logic_vector (31 downto 0);
    signal pc        		 : std_logic_vector (31 downto 0);
	signal con_npc_pc_plus_4 : std_logic_vector(31 downto 0);

    constant period    : time      := 20 ns;
    signal   clock 	   : std_logic := '0';
    signal   sim_ended : std_logic := '0';

begin

    dut : RISCV_IF
    port map (clk       => clk,
              rst_b     => rst_b,
              npc       => con_npc_pc_plus_4,
              pc_plus_4 => con_npc_pc_plus_4,
              pc        => pc);

    -- clock generation
    clock <= not clock after period/2 when sim_ended /= '1' else '0';
    clk <= clock;

    stimuli : process
    begin
        
        npc <= (others => '0');

        -- Reset generation
        rst_b <= '0';
        wait for 1.2*period;
        rst_b <= '1';
        wait for period;
        wait for 100 * period;

        -- Stop the clock and hence terminate the simulation
        sim_ended <= '1';
        wait;
    end process;

end TB;