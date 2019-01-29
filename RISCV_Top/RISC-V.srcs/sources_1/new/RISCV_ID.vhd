----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.10.2018 17:25:27
-- Design Name: 
-- Module Name: RISCV_ID - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RISCV_ID is
--  Port ( );
end RISCV_ID;

architecture RTL of RISCV_ID is

signal internal_immediate : std_logic_vector(31 downto 0);
signal instruction : std_logic_vector(31 downto 0);

begin

immGenerator_Proc : process(instruction)
    begin
    
    internal_immediate <= X"00000000"; --default assignment
    case instruction(6 downto 0) is
        when "1100111" |  "0000011" |  "0010011"=>   -- I-immediate
            internal_immediate(31 downto 11) <= (others => instruction(31));
            internal_immediate(10 downto 5)  <= instruction(30 downto 25);
            internal_immediate(4 downto 1)   <= instruction(24 downto 21);
            internal_immediate(0)            <= instruction(20); 
        when "0100011" =>   -- S-immediate
            internal_immediate(31 downto 11) <= (others => instruction(31));
            internal_immediate(10 downto 5)  <= instruction(30 downto 25);
            internal_immediate(4 downto 1)   <= instruction(11 downto 8);
            internal_immediate(0)            <= instruction(7);
            
        when "1100011" =>   -- B-immediate
            internal_immediate(31 downto 12) <= (others => instruction(31));
            internal_immediate(11)           <= instruction(7);
            internal_immediate(10 downto 5)  <= instruction(30 downto 25);
            internal_immediate(4 downto 1)   <= instruction(11 downto 8);
            internal_immediate(0)            <= '0';  
                  
        when "0110111" | "0010111"=>   -- U-immediate
            internal_immediate(31 downto 12) <= instruction(31 downto 12);
            internal_immediate(11 downto 0)  <= (others => '0');

        when "1101111" =>   -- J-immediate
            internal_immediate(31 downto 20) <= (others => instruction(31));
            internal_immediate(19 downto 12) <= instruction(19 downto 12);
            internal_immediate(11)           <= instruction(20);
            internal_immediate(10 downto 5)  <= instruction(30 downto 25);
            internal_immediate(4 downto 1)   <= instruction(24 downto 21);
            internal_immediate(0)            <= '0';
        when others => NULL;
    end case;
    end process;


end RTL;
