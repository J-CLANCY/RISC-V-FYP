----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Joseph Clancy (JC)
-- 
-- Module Name: RISCV_MEM_TB - RTL
-- Description: Memory Management module testbench of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RISCV_MEM_TB is
end RISCV_MEM_TB;

architecture TB of RISCV_MEM_TB is

    component RISCV_MEM
        port (opcode       : in std_logic_vector (6 downto 0);
              f3           : in std_logic_vector (2 downto 0);
              rs2_data     : in std_logic_vector (31 downto 0);
              mem_data_in  : in std_logic_vector (31 downto 0);
              mem_data_out : out std_logic_vector (31 downto 0);
              data_val     : out std_logic_vector (31 downto 0);
              mem_wr       : out std_logic;
              mem_oe       : out std_logic);
    end component;

    signal opcode       : std_logic_vector (6 downto 0);
    signal f3           : std_logic_vector (2 downto 0);
    signal rs2_data     : std_logic_vector (31 downto 0);
    signal mem_data_in  : std_logic_vector (31 downto 0);
    signal mem_data_out : std_logic_vector (31 downto 0);
    signal data_val     : std_logic_vector (31 downto 0);
    signal mem_wr       : std_logic;
    signal mem_oe       : std_logic;

begin

    dut : RISCV_MEM
    port map (opcode       => opcode,
              f3           => f3,
              rs2_data     => rs2_data,
              mem_data_in  => mem_data_in,
              mem_data_out => mem_data_out,
              data_val     => data_val,
              mem_wr       => mem_wr,
              mem_oe       => mem_oe);

    stimuli : process
    begin
        opcode <= "0000011";
        f3 <= "010";
        rs2_data <= X"AAAAAAAA";
        mem_data_in <= X"BBBBBBBB";
		
		wait for 20 ns;
		
		opcode <= "0100011";

        wait;
    end process;

end TB;