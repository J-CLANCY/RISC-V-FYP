----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Joseph Clancy (JC)
-- 
-- Module Name: RISCV_EX_TB - RTL
-- Description: Execution module testbench of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RISCV_EX_TB is
end RISCV_EX_TB;

architecture TB of RISCV_EX_TB is

    component RISCV_EX
        port (rs1_data   : in std_logic_vector (31 downto 0);
              rs2_data   : in std_logic_vector (31 downto 0);
              rs2_addr   : in std_logic_vector (4 downto 0);
              f3         : in std_logic_vector (2 downto 0);
              f7         : in std_logic_vector (6 downto 0);
              opcode     : in std_logic_vector (6 downto 0);
              immediate  : in std_logic_vector (31 downto 0);
              pc_plus_4  : in std_logic_vector (31 downto 0);
              alu_out    : out std_logic_vector (31 downto 0);
              branch_out : out std_logic_vector (31 downto 0));
    end component;

    signal rs1_data   : std_logic_vector (31 downto 0);
    signal rs2_data   : std_logic_vector (31 downto 0);
    signal rs2_addr   : std_logic_vector (4 downto 0);
    signal f3         : std_logic_vector (2 downto 0);
    signal f7         : std_logic_vector (6 downto 0);
    signal opcode     : std_logic_vector (6 downto 0);
    signal immediate  : std_logic_vector (31 downto 0);
    signal pc_plus_4  : std_logic_vector (31 downto 0);
    signal alu_out    : std_logic_vector (31 downto 0);
    signal branch_out : std_logic_vector (31 downto 0);

begin

    dut : RISCV_EX
    port map (rs1_data   => rs1_data,
              rs2_data   => rs2_data,
              rs2_addr   => rs2_addr,
              f3         => f3,
              f7         => f7,
              opcode     => opcode,
              immediate  => immediate,
              pc_plus_4  => pc_plus_4,
              alu_out    => alu_out,
              branch_out => branch_out);

    stimuli : process
    begin
        rs1_data <= X"00000001";
        rs2_data <= (others => '0');
        rs2_addr <= (others => '0');
        f3 <= (others => '0');
        f7 <= (others => '0');
        opcode <= "0010011";
        immediate <= (others => '0');
        pc_plus_4 <= X"00000001";

        wait;
    end process;

end TB;