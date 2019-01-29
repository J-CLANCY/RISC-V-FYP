----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC) 
-- 
-- Module Name: RISCV_ID - RTL
-- Description: Instruction Decoder Module for the RISC-V Processor
-- 
-- Revision:
-- Revision 0.01 - (JC) File created
-- Revision 0.02 - (JC) Immediate generation from old RISCV architecture (AB) brought over
--						and adjusted for new archtecture
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_ID is
  Port (
		instruction : in  std_logic_vector(31 downto 0);
		rs1         : out std_logic_vector(4 downto 0);
		rs2         : out std_logic_vector(4 downto 0);
		rd          : out std_logic_vector(4 downto 0);
		f3          : out std_logic_vector(2 downto 0);
		f7          : out std_logic_vector(6 downto 0);
		opcode      : out std_logic_vector(6 downto 0);
		immediate   : out std_logic_vector(31 downto 0));
end RISCV_ID;

architecture RTL of RISCV_ID is

begin

rs1_Assign:    rs1    <= instruction(19 downto 15); -- Decoding rs1 operand
rs2_Assign:    rs2    <= instruction(24 downto 20); -- Decoding rs2 operand
rd_Assign:     rd     <= instruction(11 downto 7);  -- Decoding rd operand
f3_Assign:     f3     <= instruction(14 downto 12); -- Decoding funct3 operand
f7_Assign:     f7     <= instruction(31 downto 25); -- Decoding funct7 operand
opcode_Assign: opcode <= instruction(6 downto 0);   -- Decode opcode operand


immediate_generator_Logic: process(instruction)
    begin
    immediate <= (others => '0'); --default assignment
    
    case instruction(6 downto 2) is
        when "11001" |  "00000" |  "00100" =>   -- I-immediate
            immediate(31 downto 11) <= (others => instruction(31));
            immediate(10 downto 5)  <= instruction(30 downto 25);
            immediate(4 downto 1)   <= instruction(24 downto 21);
            immediate(0)  			<= instruction(20);
            
        when "01000" =>   -- S-immediate
            immediate(31 downto 11) <= (others => instruction(31));
            immediate(10 downto 5)  <= instruction(30 downto 25);
            immediate(4 downto 1)   <= instruction(11 downto 8);
            immediate(0)            <= instruction(7);
            
        when "11000" =>   -- B-immediate
            immediate(31 downto 12) <= (others => instruction(31));
            immediate(11)           <= instruction(7);
            immediate(10 downto 5)  <= instruction(30 downto 25);
            immediate(4 downto 1)   <= instruction(11 downto 8);
            immediate(0)            <= '0';  
                  
        when "01101" | "00101"=>   -- U-immediate
            immediate(31 downto 12) <= instruction(31 downto 12);
            immediate(11 downto 0)  <= (others => '0');

        when "11011" =>   -- J-immediate
            immediate(31 downto 20) <= (others => instruction(31));
            immediate(19 downto 12) <= instruction(19 downto 12);
            immediate(11)           <= instruction(20);
            immediate(10 downto 5)  <= instruction(30 downto 25);
            immediate(4 downto 1)   <= instruction(24 downto 21);
            immediate(0)            <= '0';
            
        when others => NULL;
    end case;
end process;

end RTL;
