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
		clk        : in  std_logic;
        rst_b      : in  std_logic;
        instr_in   : in  std_logic_vector(31 downto 0);
        data_in    : in  std_logic_vector(31 downto 0);
        instr_addr : out std_logic_vector(31 downto 0);
        data_addr  : out std_logic_vector(31 downto 0);
        data_out   : out std_logic_vector(31 downto 0);
        ctrl_out   : out std_logic_vector(1 downto 0));
end RISCV_Top;

architecture RTL of RISCV_Top is

-- IF originating signals
signal IF_pc_plus_4 : std_logic_vector(31 downto 0);

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

begin

data_addr_Assign: data_addr <= EX_alu_out; -- Tying the ALU output that generates data memory addresses to the output port

RISCV_IF_i: RISCV_IF 
  Port map(
        clk       => clk,
        rst_b     => rst_b,
        npc       => EX_branch_out,
        pc_plus_4 => IF_pc_plus_4,
        pc        => instr_addr
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
		mem_wr 		 => ctrl_out(1),
		mem_oe 		 => ctrl_out(0)
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
		reg_wr   => WB_reg_wr,
        rs1_addr => ID_rs1_addr,
        rs2_addr => ID_rs2_addr,
        rd_addr  => ID_rd_addr,
        rd_data  => WB_rd_data,
        rs1_data => RegBank_rs1_data,
        rs2_data => RegBank_rs2_data
  );

end RTL;
