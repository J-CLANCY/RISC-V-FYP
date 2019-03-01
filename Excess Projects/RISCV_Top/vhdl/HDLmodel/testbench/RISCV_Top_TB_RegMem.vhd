----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC)
-- 
-- Module Name: RISCV_Top_TB_RegMem - RTL
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

entity RISCV_Top_TB_RegMem is end RISCV_Top_TB_RegMem;

architecture Behavioral of RISCV_Top_TB_RegMem is

component RISCV_Top is
  Port ( 
      clk        : in  std_logic;
      rst_b      : in  std_logic;
      instr_in   : in  std_logic_vector(31 downto 0);
      data_in    : in  std_logic_vector(31 downto 0);
      instr_addr : out std_logic_vector(31 downto 0);
      data_addr  : out std_logic_vector(31 downto 0);
      data_out   : out std_logic_vector(31 downto 0);
      ctrl_out   : out std_logic);
end component;

constant clk_period : time := 20 ns;    -- 50MHz clk
signal   end_of_sim : boolean := false;

signal clk             : std_logic := '0';
signal rst_b           : std_logic := '1';
signal rst             : std_logic := '0';
signal instr_in        : std_logic_vector(31 downto 0);
signal data_in         : std_logic_vector(31 downto 0);
signal instr_addr      : std_logic_vector(31 downto 0);
signal data_addr       : std_logic_vector(31 downto 0);
signal data_out        : std_logic_vector(31 downto 0);
signal ctrl_out        : std_logic;
signal instr_addr_conv : std_logic_vector(9 downto 0);

begin

--Processor program counter is aligned on a byte (8-bit) whereas instruction memory is aligned on a word (32-bit), therefore "instr_addr" is divided by 4
pc_translation_Logic: instr_addr_conv <= std_logic_vector(to_unsigned(to_integer(unsigned(instr_addr))/4, 10));

RISCV_Top_i: RISCV_Top
  Port map(
      clk        => clk,
      rst_b      => rst_b,
      instr_in   => instr_in,
      data_in    => data_in,
      instr_addr => instr_addr,
      data_addr  => data_addr,
      data_out   => data_out,
      ctrl_out   => ctrl_out
  );
  

rst_inversion_Assign: rst <= not rst_b;

clk_stim_Gen: process (clk)
begin
    if (end_of_sim = false) then 
        clk <= not clk after clk_period/2;
    end if; 
end process;

rst_other_stim_Gen: process
begin
    report "%N : Simulation Start.";
    rst_b    <= '0';  -- initialise input and toggle rst
    wait for clk_period*1.2;
    rst_b    <= '1'; 
    wait for clk_period*50;
    
    report "%N : Simulation Done.";
    end_of_sim <= true;
    wait; -- wait forever
end process;

end Behavioral;
