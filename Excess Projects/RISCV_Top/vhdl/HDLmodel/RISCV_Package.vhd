-- Description : RISCV_Package 
-- Copyright (c) 2011-2017 Fearghal Morgan

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package RISCV_Package is

type regType is array (31 downto 0)  of std_logic_vector(31 downto 0);

component RISCV_IF is 
  Port (
        clk       : in  std_logic;
        rst_b     : in  std_logic;
        ce        : in  std_logic;
        mem_busy  : in  std_logic;
        npc       : in  std_logic_vector(31 downto 0);
        pc_plus_4 : out std_logic_vector(31 downto 0);
        pc        : out std_logic_vector(31 downto 0));
end component;

component RISCV_ID is
  Port (
		instruction : in  std_logic_vector(31 downto 0);
		rs1         : out std_logic_vector(4 downto 0);
		rs2         : out std_logic_vector(4 downto 0);
		rd          : out std_logic_vector(4 downto 0);
		f3          : out std_logic_vector(2 downto 0);
		f7          : out std_logic_vector(6 downto 0);
		opcode      : out std_logic_vector(6 downto 0);
		immediate   : out std_logic_vector(31 downto 0));
end component;

component RISCV_EX is 
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
end component;

component RISCV_MEM is 
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
end component;

component RISCV_WB is 
   Port ( 
		opcode      : in  std_logic_vector(6 downto 0);
        data_mem_in : in  std_logic_vector(31 downto 0);
        alu_out     : in  std_logic_vector(31 downto 0);
        pc_plus_4   : in  std_logic_vector(31 downto 0);
        rd_data     : out std_logic_vector(31 downto 0);
		reg_wr      : out std_logic);
end component;

component RISCV_RegBank is 
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
        reg_bank : out regType
        );
end component;

component breakFunction is 
    Port ( 
        clk               : in std_logic;                         
	    rst               : in std_logic;                         
	    clrAllBreakpoints : in std_logic;
	    enableBreakpoints : in std_logic;
	    clrBreakEvent     : in std_logic;                         

	    PC                : in std_logic_vector(31 downto 0);     
	    R                 : in regType;	     	                

	    breakAdd          : in std_logic_vector(4 downto 0);      
	    breakWr           : in std_logic;                         
	    breakDat          : in std_logic_vector(32 downto 0);     
	    breakDatOut       : out std_logic_vector(32 downto 0);    
	    break             : out std_logic := '0'                
	  );
end component;

end RISCV_Package;

package body RISCV_Package is
 
end RISCV_Package;