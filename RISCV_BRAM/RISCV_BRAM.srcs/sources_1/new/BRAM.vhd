----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC)
-- 
-- Module Name: RISCV_Top_TB - RTL
-- Description: General testbench for the RISC-V Processor
-- 
-- Revision:
-- Revision 0.01 - File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.ALL; -- Necessary when using fileIO
use std.textio.ALL;	 

entity BRAM is end BRAM;

architecture Behavioral of BRAM is

component instruction_memory is
  port (
    clka  : in  std_logic;
    addra : in  std_logic_vector(9 downto 0);
    douta : out std_logic_vector(31 downto 0));
end component;

constant clk_period : time := 20 ns;    -- 50MHz clk
signal   end_of_sim : boolean := false;

signal clk        : std_logic := '0';
signal rst_b      : std_logic := '1';
signal instr_in   : std_logic_vector(31 downto 0);
signal instr_addr : std_logic_vector(31 downto 0);

begin

instr_mem_i: instruction_memory
  Port map(
    clka  => clk,
    addra => instr_addr(9 downto 0),
    douta => instr_in
  );
  
clk_stim_Gen: process (clk)
begin
    if (end_of_sim = false) then 
        clk <= not clk after clk_period/2;
    end if; 
end process;

rst_other_stim_Gen: process
begin
    report "%N : Simulation Start.";
    wait for clk_period*1.2;
    instr_addr(9 downto 0) <= X"000";
    wait for clk_period*20;
    
    
    
    report "%N : Simulation Done.";
    end_of_sim <= true;
    wait; -- wait forever
end process;

end Behavioral;
