----------------------------------------------------------------------------------
-- Company: National University of Ireland Galway
-- Engineer: Joseph Clancy
-- 
-- Create Date: 24.10.2018 17:25:27
-- Design Name: RISC-V
-- Module Name: RISCV_Top - RTL
-- Project Name: RISC-V
-- Target Devices: Zynq 7020
-- Tool Versions: 2018.2
-- Description: Top Level Module of the Single Cycle RISC-V Processor
-- 
-- Revision:
-- Revision 0.01 - File created
-- Revision 0.02 - mem_busy, mem_valid, mem_size added to match SCC wrappers
-- Revision 0.03 - Break function module added
--
-- Additional Comments:
-- The documentation supplied for this design includes all signal and functionality
-- descriptions required.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_Package.ALL;

entity RISCV_Top is
  Port ( 
		clk               : in  std_logic;
        rst_b             : in  std_logic;
        ce                : in  std_logic;
        mem_busy          : in  std_logic;
        instr_in          : in  std_logic_vector(31 downto 0);
        data_in           : in  std_logic_vector(31 downto 0);
        
        instr_addr        : out std_logic_vector(31 downto 0);
        data_addr         : out std_logic_vector(31 downto 0);
        data_out          : out std_logic_vector(31 downto 0);
        mem_rd_wr         : out std_logic;
        mem_valid         : out std_logic;
        mem_size          : out std_logic_vector(1 downto 0);
        
        clrAllBreakpoints : in std_logic;   
        enableBreakpoints : in std_logic;
        clrBreakEvent     : in std_logic;                      
        breakAdd          : in std_logic_vector(4 downto 0);  
        breakWr           : in std_logic;                      
        breakDat          : in std_logic_vector(32 downto 0);  
        breakDatOut       : out std_logic_vector(32 downto 0); 
        break             : out std_logic);
end RISCV_Top;

architecture RTL of RISCV_Top is

-- IF originating signals
signal IF_pc_plus_4 : std_logic_vector(31 downto 0);
signal IF_pc        : std_logic_vector(31 downto 0);

-- ID originating signals
signal ID_rs1_addr  : std_logic_vector(4 downto 0);
signal ID_rs2_addr  : std_logic_vector(4 downto 0);
signal ID_rd_addr   : std_logic_vector(4 downto 0);
signal ID_f3        : std_logic_vector(2 downto 0);
signal ID_f7        : std_logic_vector(6 downto 0);
signal ID_opcode    : std_logic_vector(6 downto 0);
signal ID_immediate : std_logic_vector(31 downto 0);

-- EX originating signals 
signal EX_alu_out    : std_logic_vector(31 downto 0);
signal EX_branch_out : std_logic_vector(31 downto 0);

-- MEM originating signals
signal MEM_data_val : std_logic_vector(31 downto 0);

-- WB originating signals
signal WB_rd_data : std_logic_vector(31 downto 0);
signal WB_reg_wr  : std_logic;

-- RegBank originating signals
signal RegBank_rs1_data : std_logic_vector(31 downto 0);
signal RegBank_rs2_data : std_logic_vector(31 downto 0);
signal RegBank_reg_bank : RISCV_regType;

-- Break Function signals
signal rstBreak : std_logic;

begin

data_addr_Assign:  data_addr <= EX_alu_out; -- Tying the ALU output that generates data memory addresses to the output port
instr_addr_Assign: instr_addr <= IF_pc;     -- Tying the current program counter to the instr_addr output port
rst_Invert:        rstBreak <= not rst_b;        -- Inverting rst_b for the break function module

RISCV_IF_i: RISCV_IF 
  Port map(
        clk       => clk,
        rst_b     => rst_b,
        ce        => ce,
        mem_busy  => mem_busy,
        npc       => EX_branch_out,
        pc_plus_4 => IF_pc_plus_4,
        pc        => IF_pc
  );
  
RISCV_ID_i: RISCV_ID
  Port map(
		instruction => instr_in,
		rs1         => ID_rs1_addr,
		rs2         => ID_rs2_addr,
		rd          => ID_rd_addr,
		f3          => ID_f3,
		f7          => ID_f7,
		opcode      => ID_opcode,
		immediate   => ID_immediate
  );
  
RISCV_EX_i: RISCV_EX 
  Port map(
        rs1_data   => RegBank_rs1_data,
        rs2_data   => RegBank_rs2_data,
        rs2_addr   => ID_rs2_addr,
        f3         => ID_f3,
        f7         => ID_f7,
        opcode     => ID_opcode,
        immediate  => ID_immediate,
        pc         => IF_pc,
        pc_plus_4  => IF_pc_plus_4,
        alu_out    => EX_alu_out,
        branch_out => EX_branch_out
  );
  
RISCV_MEM_i: RISCV_MEM 
  Port map(
  		opcode 		 => ID_opcode,
		f3           => ID_f3,
		rs2_data     => RegBank_rs2_data,
        mem_data_in  => data_in,
		mem_data_out => data_out,
		data_val     => MEM_data_val,
		mem_rd_wr 	 => mem_rd_wr,
		mem_valid    => mem_valid,
		mem_size     => mem_size
  );

RISCV_WB_i: RISCV_WB 
  Port map(
		opcode      => ID_opcode,
        data_mem_in => MEM_data_val,
        alu_out     => EX_alu_out,
        pc_plus_4   => IF_pc_plus_4,
        rd_data     => WB_rd_data,
		reg_wr      => WB_reg_wr
  );

RISCV_RegBank_i: RISCV_RegBank 
  Port map(
		clk      => clk,
        rst_b    => rst_b,
        ce       => ce,
		reg_wr   => WB_reg_wr,
        rs1_addr => ID_rs1_addr,
        rs2_addr => ID_rs2_addr,
        rd_addr  => ID_rd_addr,
        rd_data  => WB_rd_data,
        rs1_data => RegBank_rs1_data,
        rs2_data => RegBank_rs2_data,
        reg_bank => RegBank_reg_bank
  );
  
breakFunction_i: breakFunction
    Port map  (
          clk               => clk,
          rst               => rstBreak, 
          clrAllBreakpoints => clrAllBreakpoints,
          enableBreakpoints => enableBreakpoints,
          clrBreakEvent     => clrBreakEvent,
          PC                => IF_pc,
          R                 => RegBank_reg_bank,
          breakAdd          => breakAdd,
          breakWr           => breakWr,
          breakDat          => breakDat,
          breakDatOut       => breakDatOut,
          break             => break
      ); 

end RTL;
