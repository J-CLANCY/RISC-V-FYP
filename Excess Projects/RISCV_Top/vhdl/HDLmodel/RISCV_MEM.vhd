----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC) 
-- 
-- Module Name: RISCV_MEM - RTL
-- Description: Memory Management Module for the RISC-V Processor
-- 
-- Revision:
-- Revision 0.01 - (JC) File created
-- Revision 0.02 - (JC) Edited to match SCC signals
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_MEM is
  Port (
		opcode 		 : in  std_logic_vector(6 downto 0);
		f3           : in  std_logic_vector(2 downto 0);
		rs2_data     : in  std_logic_vector(31 downto 0);
        mem_data_in  : in  std_logic_vector(31 downto 0);
		mem_data_out : out std_logic_vector(31 downto 0);
		data_val     : out std_logic_vector(31 downto 0);
		mem_rd_wr    : out std_logic;
		mem_valid    : out std_logic;
		mem_size     : out std_logic_vector(1 downto 0));
end RISCV_MEM;

architecture RTL of RISCV_MEM is

begin

mem_ctrl_Logic: process(opcode, f3, mem_data_in, rs2_data) -- Logic to control the write and output enable signals
begin
	data_val <= (others => '0'); -- Default assignment
	mem_data_out <= (others => '0');
	mem_rd_wr <= '0';
	mem_valid <= '0';
	mem_size <= "00";

		case opcode(6 downto 2) is
			when "00000" => -- Load operation
			    mem_valid <= '1';
				
				case f3 is
					when "000" => -- LB
						data_val(31 downto 8) <=(others => mem_data_in(7));
						data_val(7 downto 0) <= mem_data_in(7 downto 0);
						mem_size <= "00";
						
					when "001" => -- LH
						data_val(31 downto 16) <= (others => mem_data_in(15));
						data_val(15 downto 0) <= mem_data_in(15 downto 0);
						mem_size <= "01";
						
					when "010" => -- LW
						data_val(31 downto 0) <= mem_data_in(31 downto 0);
						mem_size <= "10";
						
					when "100" => -- LBU
						data_val(31 downto 8) <= (others => '0');
						data_val(7 downto 0) <= mem_data_in(7 downto 0);
						mem_size <= "00";
						
					when "101" => -- LHU
						data_val(31 downto 16) <= (others => '0');
						data_val(15 downto 0) <= mem_data_in(15 downto 0);
						mem_size <= "01";
						
					when others => null;
				end case;
				
			when "01000" => -- Store operation
				mem_rd_wr <= '1';
				mem_valid <= '1';
				
				case f3 is
					when "000" => -- SB
						mem_data_out(31 downto 8) <= (others => rs2_data(7));
						mem_data_out(7 downto 0) <= rs2_data(7 downto 0);
						mem_size <= "00";
					
					when "001" => -- SH
						mem_data_out(31 downto 16) <= (others => rs2_data(15));
						mem_data_out(15 downto 0) <= rs2_data(15 downto 0);
						mem_size <= "01";
					
					when "010" => -- SW
						mem_data_out(31 downto 0) <= rs2_data(31 downto 0);
						mem_size <= "10";
						
					when others => null;
				end case;
				
			when others => null;
		end case;
end process;

end RTL;
