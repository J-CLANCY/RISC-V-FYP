----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Joseph Clancy (JC)
-- 
-- Module Name: RISCV_WB_TB - RTL
-- Description: Write Back module testbench of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RISCV_WB_TB is
end RISCV_WB_TB;

architecture TB of RISCV_WB_TB is

    component RISCV_WB
        port (opcode      : in std_logic_vector (6 downto 0);
              data_mem_in : in std_logic_vector (31 downto 0);
              alu_out     : in std_logic_vector (31 downto 0);
              pc_plus_4   : in std_logic_vector (31 downto 0);
              rd_data     : out std_logic_vector (31 downto 0);
              reg_wr      : out std_logic);
    end component;

    signal opcode      : std_logic_vector (6 downto 0);
    signal data_mem_in : std_logic_vector (31 downto 0);
    signal alu_out     : std_logic_vector (31 downto 0);
    signal pc_plus_4   : std_logic_vector (31 downto 0);
    signal rd_data     : std_logic_vector (31 downto 0);
    signal reg_wr      : std_logic;

begin

    dut : RISCV_WB
    port map (opcode      => opcode,
              data_mem_in => data_mem_in,
              alu_out     => alu_out,
              pc_plus_4   => pc_plus_4,
              rd_data     => rd_data,
              reg_wr      => reg_wr);

    stimuli : process
    begin
        opcode <= "0010011";
        data_mem_in <= X"AAAAAAAA";
        alu_out <= X"BBBBBBBB";
        pc_plus_4 <= X"CCCCCCCC";
		
		wait for 20 ns; 
		
		opcode <= "0100011";
		
		wait for 20 ns;
		
		opcode <= "1100111";

        wait;
    end process;

end TB;