----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC)
-- 
-- Module Name: RISCV_IF - RTL
-- Description: Instruction fetch module of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
-- Revision 0.02 - Code ported from (AB) RISCV_PCCU and adjusted for new architecture
-- REvision 0.03 - Quick fixes added to deal with latencies with Instr. and Data Memories.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_IF is
  Port (
        clk       : in  std_logic;
        rst_b     : in  std_logic;
        npc       : in  std_logic_vector(31 downto 0);
        pc_plus_4 : out std_logic_vector(31 downto 0);
        pc        : out std_logic_vector(31 downto 0));
end RISCV_IF;

architecture RTL of RISCV_IF is

signal pc_internal  : std_logic_vector(31 downto 0);
signal pc_internal2 : std_logic_vector(31 downto 0);
signal pc_internal3 : std_logic_vector(31 downto 0);
signal pc_internal4 : std_logic_vector(31 downto 0);

begin

current_pc_Assign: pc        <= pc_internal3;                                 -- Current program counter assignment
next_pc_Assign:    pc_plus_4 <= std_logic_vector(unsigned(pc_internal3) + 1); -- Next sequential program counter value assignment. NB CHANGE TO +4 LATER

program_counter_Reg: process(clk, rst_b) -- Register for the program counter
begin
    if rst_b = '0' then
        pc_internal <= (others => '0');
    elsif rising_edge(clk) then
        pc_internal <= npc;
    end if;
end process;  

program_counter_Reg2: process(clk, rst_b) -- Quick fix until better method of dealing with BRAM 1 cycle delay
begin
    if rst_b = '0' then
        pc_internal2 <= (others => '0');
    elsif rising_edge(clk) then
        pc_internal2 <= pc_internal;
    end if;
end process; 

program_counter_Reg3: process(clk, rst_b) -- Quick fix until better method of dealing with BRAM 1 cycle delay
begin
    if rst_b = '0' then
        pc_internal3 <= (others => '0');
    elsif rising_edge(clk) then
        pc_internal3 <= pc_internal2;
    end if;
end process; 

end RTL;
