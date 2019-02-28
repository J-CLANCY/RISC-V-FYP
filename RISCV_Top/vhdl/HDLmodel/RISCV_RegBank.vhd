----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC) 
-- 
-- Module Name: RISCV_RegBank - RTL
-- Description: Register Bank Module for the RISC-V Processor
-- 
-- Revision:
-- Revision 0.01 - (JC) File created
-- Revision 0.02 - (JC) Created registers, write and read logic
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_Package.ALL;

entity RISCV_RegBank is
  Port ( 
		clk      : in  std_logic;
        rst_b    : in  std_logic;
        ce       : in  std_logic;
		reg_wr   : in  std_logic;
        rs1_addr : in  std_logic_vector(4 downto 0);
        rs2_addr : in  std_logic_vector(4 downto 0);
        rd_addr  : in  std_logic_vector(4 downto 0);
        rd_data  : in  std_logic_vector(31 downto 0);
        rs1_data : out std_logic_vector(31 downto 0);
        rs2_data : out std_logic_vector(31 downto 0);
        reg_bank : out RISCV_regType);
end RISCV_RegBank;

architecture RTL of RISCV_RegBank is

signal int_reg_bank : RISCV_regType;
signal cmb_reg_bank : RISCV_regType;

begin

reg_bank_Assign: reg_bank <= int_reg_bank;

state_Reg: process(clk, rst_b) -- State registers for our 32 32-bit registers
begin
    if rst_b = '0' then
        int_reg_bank <= (others => (others => '0'));
    elsif rising_edge(clk) then
        if ce = '1' then
            int_reg_bank <= cmb_reg_bank;
        end if;
    end if;
end process;

wr_Logic: process(reg_wr, rd_addr, rd_data, int_reg_bank) -- The write logic for our registers
begin
    cmb_reg_bank <= int_reg_bank;
	
    if reg_wr = '1' and rd_addr /= "00000" then
        cmb_reg_bank(to_integer(unsigned(rd_addr))) <= rd_data;
    end if;
end process;

rs1_data_Assign: process(rs1_addr, int_reg_bank) -- First operand read logic
begin
    if rs1_addr = "00000" then
        rs1_data <= (others => '0');
    else
        rs1_data <= int_reg_bank(to_integer(unsigned(rs1_addr)));
    end if;
end process;

rs2_data_Assign: process(rs2_addr) -- Second operand read logic
begin
    if unsigned(rs2_addr) = "00000" then
        rs2_data <= (others => '0');
    else
        rs2_data <= int_reg_bank(to_integer(unsigned(rs2_addr)));
    end if;
end process;

end RTL;
