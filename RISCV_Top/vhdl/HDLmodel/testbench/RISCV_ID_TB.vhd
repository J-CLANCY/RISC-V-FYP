----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Joseph Clancy (JC)
-- 
-- Module Name: RISCV_ID_TB - RTL
-- Description: Instruction decode module testbench of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RISCV_ID_TB is
end RISCV_ID_TB;

architecture TB of RISCV_ID_TB is

    component RISCV_ID
        port (instruction : in std_logic_vector (31 downto 0);
			  rs1         : out std_logic_vector (4 downto 0);
              rs2         : out std_logic_vector (4 downto 0);
              rd          : out std_logic_vector (4 downto 0);
              f3          : out std_logic_vector (2 downto 0);
              f7          : out std_logic_vector (6 downto 0);
              opcode      : out std_logic_vector (6 downto 0);
              immediate   : out std_logic_vector (31 downto 0));
    end component;

    signal instruction : std_logic_vector (31 downto 0);
    signal rs1         : std_logic_vector (4 downto 0);
    signal rs2         : std_logic_vector (4 downto 0);
    signal rd          : std_logic_vector (4 downto 0);
    signal f3          : std_logic_vector (2 downto 0);
    signal f7          : std_logic_vector (6 downto 0);
    signal opcode      : std_logic_vector (6 downto 0);
    signal immediate   : std_logic_vector (31 downto 0);

begin

    dut : RISCV_ID
    port map (instruction => instruction,
              rs1         => rs1,
              rs2         => rs2,
              rd          => rd,
              f3          => f3,
              f7          => f7,
              opcode      => opcode,
              immediate   => immediate);

    stimuli : process
    begin
	
        instruction <= (others => '0');
		
		wait for 20ns;
		
		instruction <= X"00A07013";

        -- EDIT Add stimuli here

        wait;
    end process;

end TB;