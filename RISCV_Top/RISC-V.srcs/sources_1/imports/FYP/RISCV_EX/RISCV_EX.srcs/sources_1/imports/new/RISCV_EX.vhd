----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Arthur Beretta (AB), Joseph Clancy (JC)
-- 
-- Module Name: RISCV_EX - RTL
-- Description: Execution module of RISC-V processor
-- 
-- Revision:
-- Revision 0.01 - File created
-- Revision 0.02 - Code ported from (AB) RISCV_ALU, RISCV_operandFetch and adjusted
--				   for new architecture
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_EX is
  Port (  
        rs1_data    : in  std_logic_vector(31 downto 0);
        rs2_data    : in  std_logic_vector(31 downto 0);
        rs2_addr    : in  std_logic_vector(4 downto 0);
        f3          : in  std_logic_vector(2 downto 0);
        f7          : in  std_logic_vector(6 downto 0);
        opcode      : in  std_logic_vector(6 downto 0);
        immediate   : in  std_logic_vector(31 downto 0);
        pc_plus_4   : in  std_logic_vector(31 downto 0);
        alu_out     : out std_logic_vector(31 downto 0);
        branch_out  : out std_logic_vector(31 downto 0));
end RISCV_EX;

architecture RTL of RISCV_EX is

signal A 	  	 	: std_logic_vector(31 downto 0); -- First input of the ALU
signal B 	  	 	: std_logic_vector(31 downto 0); -- Second input of the ALU
signal alu_op 	 	: std_logic_vector(3 downto 0);  -- Function selector for ALU logic
signal branch_op 	: std_logic_vector(2 downto 0);  -- Function selector for branch detector
signal compare_cond : std_logic; 					 -- Signal denoting whether the processor is branching or not
signal result       : std_logic_vector(31 downto 0); -- Result of the ALU operation

begin

alu_Logic: process(A, B, alu_op, compare_cond) -- Logic containing all ALU functions
begin
    result   <= (others => '0'); -- Default assignment
	
    case alu_op is 
      when "0000" => result <= std_logic_vector(signed(A) + signed(B)); -- Addition
      when "0001" => result <= std_logic_vector(signed(A) - signed(B)); -- Subtraction
      when "0010" => result <= A and B; -- AND
      when "0011" => result <= A or B;  -- OR
      when "0100" => result <= A xor B; -- XOR
      when "0101" => result <= std_logic_vector(shift_left(unsigned(A),to_integer(unsigned(B))));   -- Shift left logical
      when "0110" => result <= std_logic_vector(shift_right(unsigned(A),to_integer(unsigned(B))));  -- Shift right logical
      when "0111" => result <= std_logic_vector(rotate_right(unsigned(A),to_integer(unsigned(B)))); -- Shift right arithmetic
	  when "1000" => -- Set less than
			case compare_cond is
				when '0' => null;
				when '1' => result <= X"00000001";
			end case;
			
      when others => null;
    end case;
end process;

branch_detection_Logic: process(A, B, branch_op) -- Logic for comparison operations for branch instructions
begin
    compare_cond <= '0'; -- Default assignment
	
    case branch_op is
        when "000" =>  if A = B then -- BEQ
                            compare_cond <= '1'; 
                        end if;
						
        when "001" =>  if A /= B then -- BNE
                            compare_cond <= '1'; 
                        end if;	
						
        when "010" =>  if signed(A) < signed(B)  then -- BLT
                            compare_cond <= '1';
                        end if;
						
        when "011" =>  if signed(A) >= signed(B)  then -- BGE
                            compare_cond <= '1';
                       end if;
					   
        when "100" =>  if unsigned(A) < unsigned(B) then -- BLTU
                            compare_cond <= '1';  
                        end if;
						
        when "101" =>  if unsigned(A) >= unsigned(B)  then -- BGEU
                            compare_cond <= '1';
                       end if;
					   
		when "110" => compare_cond <= '1'; -- JAL and JALR			
		
		when others => null;
    end case;
end process;

alu_out_Assign: alu_out <= result;

branch_out_Assign: process(compare_cond, result, pc_plus_4) -- Choosing whether or not to branch
begin
	case compare_cond is
		when '0' => branch_out <= pc_plus_4; -- No branch
		when '1' => branch_out <= result;    -- Branch
	end case;
end process;

operand_sel_Logic: process(opcode, rs1_data, rs2_data, immediate, pc_plus_4) -- Selecting the operands to pass to the ALU
begin
   A <= (others => '0'); -- Default assignment
   B <= (others => '0');
   
   case opcode(6 downto 2) is
        when "01100" => -- Register to register operations
            A <= rs1_data;
            B <= rs2_data;
			
        when "00000"|"11001"|"00100" => -- Register to immediate operations
            A <= rs1_data;
            B <= immediate;
			
        when "00101"|"11011"|"11000" => -- AUIPC, JAL and branch operations
            A <= pc_plus_4;
            B <= immediate;
			
		when "01101" => -- LUI
			B <= immediate;
			
        when others => null;
   end case; 
end process;

operation_decode_Logic: process(opcode, f3, f7) -- Logic to select ALU and branch functions
begin
	alu_op <= X"0";  -- Addition
	branch_op <= "110"; -- No branch
	
	case opcode(6 downto 2) is
		when "11011"|"11001" => branch_op <= "110"; -- JAL/JALR
		
		when "11000" => -- Branch
			case f3 is
				when "000" => branch_op <= "000"; -- BEQ
				when "001" => branch_op <= "001"; -- BNE
				when "100" => branch_op <= "010"; -- BLT
				when "101" => branch_op <= "011"; -- BGE
				when "110" => branch_op <= "100"; -- BLTU
				when "111" => branch_op <= "101"; -- BGEU
				when others => null; 
			end case;
			
		when "00100" => -- Register-Immediate Arithmetic/Logic
			case f3 is
				when "010" => -- SLT
					alu_op <= "1000";
					branch_op <= "010";
					
				when "011" => -- SLTU
					alu_op <= "1000";
					branch_op <= "100";
					
				when "100" => alu_op <= "0100"; -- XORI
				when "110" => alu_op <= "0011"; -- ORI
				when "111" => alu_op <= "0010"; -- ANDI
				when "001" => alu_op <= "0101"; -- SLLI
				when "101" => 						  
					case f7(5) is
						when '0' => alu_op <= "0111"; -- SRLI
						when '1' => alu_op <= "0110"; -- SRAI
					end case;
					
				when others => null;
			end case;
			
		when "01100" => -- Register-Register Arithmetic/Logic
			case f3 is
				when "000" => -- ADD/SUB
					case f7(5) is
						when '0' => null; 			  -- ADD
						when '1' => alu_op <= "0001"; -- SUB
					end case;
					
				when "010" => -- SLT
					alu_op <= "1000";
					branch_op <= "010";
					
				when "011" => -- SLTU
					alu_op <= "1000";
					branch_op <= "100";
					
				when "100" => alu_op <= "0100"; -- XOR
				when "110" => alu_op <= "0011"; -- OR
				when "111" => alu_op <= "0010"; -- AND
				when "001" => alu_op <= "0101"; -- SLL
				when "101" => -- SRI
					case f7(5) is
						when '0' => alu_op <= "0111"; -- SRL
						when '1' => alu_op <= "0110"; -- SRA
					end case;
					
			end case;
			
		when others => null;
	end case;
end process;

end RTL;
