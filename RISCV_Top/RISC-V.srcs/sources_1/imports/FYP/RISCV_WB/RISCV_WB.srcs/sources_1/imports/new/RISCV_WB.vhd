----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC) 
-- 
-- Module Name: RISCV_WB - RTL
-- Description: Write Back Module for the RISC-V Processor
-- 
-- Revision:
-- Revision 0.01 - (JC) File created
-- Revision 0.02 - (JC) Write back mux created
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_WB is
   Port ( 
		opcode      : in  std_logic_vector(6 downto 0);
        data_mem_in : in  std_logic_vector(31 downto 0);
        alu_out     : in  std_logic_vector(31 downto 0);
        pc_plus_4   : in  std_logic_vector(31 downto 0);
        rd_data     : out std_logic_vector(31 downto 0);
		reg_wr      : out std_logic);
end RISCV_WB;

architecture RTL of RISCV_WB is

signal wb_sel : std_logic_vector(1 downto 0);

begin

wb_sel_reg_wr_Logic: process(opcode) -- Generate the mux selection and register write signal
begin
	wb_sel <= "11"; -- Default assignments, don't write back to registers
	reg_wr <= '0';
	
	case opcode(6 downto 2) is
		when "01101"|"00101"|"00100"|"01100" => -- LUI, AUIPC, Arithmetic, Logical
			wb_sel <= "00";
			reg_wr <= '1';
			
		when "00000" => -- Load
			wb_sel <= "01";
			reg_wr <= '1';
			
		when "11011"|"11001" => -- JAL, JALR
			wb_sel <= "10";
			reg_wr <= '1';
		
		when others => null;
	end case;
end process;

rd_data_Assign: process(wb_sel, data_mem_in, alu_out, pc_plus_4) -- Write back mux
begin
    case wb_sel is
        when "00" => rd_data <= alu_out;
        when "01" => rd_data <= data_mem_in;
        when "10" => rd_data <= pc_plus_4;
        when "11" => rd_data <= X"00000000";
        when others => null;
    end case;
end process;


end RTL;
