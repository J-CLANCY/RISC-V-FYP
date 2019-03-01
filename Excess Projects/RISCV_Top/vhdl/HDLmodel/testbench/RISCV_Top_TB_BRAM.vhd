----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC)
-- 
-- Module Name: RISCV_Top_TB_BRAM - RTL
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

entity RISCV_Top_TB_BRAM is end RISCV_Top_TB_BRAM;

architecture Behavioral of RISCV_Top_TB_BRAM is

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

component instruction_memory is
  port (
    clka  : in  std_logic;
    addra : in  std_logic_vector(9 downto 0);
    douta : out std_logic_vector(31 downto 0));
end component;

component data_memory is
  port (
    clka      : in std_logic;
    rsta      : in std_logic;
    wea       : in std_logic_vector(3 downto 0);
    addra     : in std_logic_vector(31 downto 0);
    dina      : in std_logic_vector(31 downto 0);
    douta     : out std_logic_vector(31 downto 0);
    rsta_busy : out std_logic);
end component;

constant clk_period : time := 20 ns;    -- 50MHz clk
signal   end_of_sim : boolean := false;

signal clk        : std_logic := '0';
signal rst_b      : std_logic := '1';
signal rst        : std_logic := '0';
signal instr_in   : std_logic_vector(31 downto 0);
signal data_in    : std_logic_vector(31 downto 0);
signal instr_addr : std_logic_vector(31 downto 0);
signal data_addr  : std_logic_vector(31 downto 0);
signal data_out   : std_logic_vector(31 downto 0);
signal ctrl_out   : std_logic;
signal wea        : std_logic_vector(3 downto 0);

begin

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
  
instr_mem_i: instruction_memory
  Port map(
    clka  => clk,
    addra => instr_addr(9 downto 0),
    douta => instr_in
  );
  
data_mem_i: data_memory
  Port map(
    clka      => clk,
    rsta      => rst,
    wea       => wea,
    addra     => data_addr,
    dina      => data_out,
    douta     => data_in,
    rsta_busy => open
  );
  
wea_ctrl_out_Assign: wea <= (others => ctrl_out); -- Xilinx IPs generate std_logic_vector(0 downto 0) which does not
                                                     -- mesh with std_logic, this is a work around
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
