-- Description: singleCycCompAndMem
-- Copyright 2011-2017 Fearghal Morgan
-- Authors: Fearghal Morgan, Arthur Beretta, Joseph Clancy
-- Change History: Initial version
-- Copyright (c) 2011-2017 NUI Galway
--
-- Description: singleCycCompAndMem Synthesisable VHDL model for RISC-V processor

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_Package.ALL;

entity singleCycCompAndMem is
Port (
       clk :                                in std_logic;                        -- system clock strobe
       rst :                                in std_logic;                         -- asynchronous system reset, asserted
       useDebugInstruction :                in std_logic;                        -- client instruction control. When enabled, overrides program memory instruction.   
       debugInstruction :                      in std_logic_vector(31 downto 0);    -- client instruction.     
       PCVec :                              out std_logic_vector(11 downto 0);   
       execInstr :                          in std_logic;

       hostCtrlInstrMem :                    in  std_logic;
       hostInstrMem_Load :                  in  std_logic;
       hostInstrMem_LoadIndex :           in  std_logic_vector(1 downto 0);
       hostInstrMem_LoadDat :               in  std_logic_vector(31 downto 0);
       hostInstrMem_Add :                   in  std_logic_vector(9 downto 0);
       hostInstrMem_DatIn :                 in  std_logic_vector(31 downto 0);
       hostInstrMem_Wr :                    in  std_logic;
       hostInstrMem_DatOut :                out std_logic_vector(31 downto 0);

       hostCtrlDataAndStackMem :          in  std_logic;
       hostCtrlDataAndStackMem_Load :    in  std_logic;
       hostCtrlDataAndStackMem_LoadDat : in  std_logic_vector(31 downto 0);
       hostCtrlDataAndStackMem_Add :     in  std_logic_vector(7 downto 0);
       hostCtrlDataAndStackMem_DatIn :   in  std_logic_vector(31 downto 0);
       hostCtrlDataAndStackMem_Wr :  in  std_logic;
       hostCtrlDataAndStackMem_DatOut :  out std_logic_vector(31 downto 0);
       hostCtrlDataAndStackMem_DatArrayOut : out std_logic_vector(511 downto 0);

       clrAllBreakpoints :   in std_logic;   
       enableBreakpoints :   in std_logic;
       clrBreakEvent :          in std_logic;                         -- assert on run/debug start or on re-run after a breakpoint detection
       breakAdd :            in std_logic_vector(4 downto 0);      -- register array address
       breakWr :             in std_logic;                         -- register array wr
       breakDat :            in std_logic_vector(32 downto 0);     -- register array data in
       breakDatOut :         out std_logic_vector(32 downto 0);    -- register array data out
       break:                 out std_logic;                         -- asserted if aBreakEvent or breakEvent asserted
       periphAdd        : out std_logic_vector(31 downto 0);
       periphIn         : out std_logic_vector(31 downto 0);
       periphWr         : out std_logic;
                
       periphOut        : in std_logic_vector(31 downto 0) 
       );
end singleCycCompAndMem;

architecture struct of singleCycCompAndMem is
signal PCinteger            : integer range 0 to 4095;      -- 16 bit instruction address 
signal intPCVec             : std_logic_vector(11 downto 0);
signal instruction          : std_logic_vector(31 downto 0);   -- 16 bit instruction, includes 7 bit OPCODE (15:9). Refer to instruction set. 
signal instructionToDecoder : std_logic_vector(31 downto 0);   -- 16 bit instruction, includes 7 bit OPCODE (15:9). Refer to instruction set. 

signal intDSAdd     : std_logic_vector(11 downto 0);   -- 4096 locations
signal intDSIn      : std_logic_vector(31 downto 0);
signal intDSWr      : std_logic;
signal DSOut        : std_logic_vector(31 downto 0);   -- data and stack memory I/F signals 
signal PCToMem      : std_logic_vector(9 downto 0);

--memory signals
--Ctrl signal
signal memRdWr      : std_logic;
signal memValid     : std_logic;
signal memBusy      : std_logic;
signal memSize      : std_logic_vector(1 downto 0);

--data signals
signal addr         : std_logic_vector(31 downto 0);
signal DIn          : std_logic_vector(31 downto 0);
signal Dout         : std_logic_vector(31 downto 0);
signal PC           : std_logic_vector(31 downto 0);

signal rst_b        : std_logic;

begin 

--Processor PC is aligned on a byte (8b) whereas instruction memory is aligned on a word (32b). Consequantly, PC need to be devides by 4
PCToMem <= std_logic_vector(to_unsigned(to_integer(unsigned(PC))/4, 10));

--Inverting rst for the RISC-V Processor
rst_Invert: rst_b <= not rst;

instrMemArray_i: dualPortRegBlk128x32WithLoad 
Port map (  clk             => clk,
            rst             => '0',
            enPort0         => hostCtrlInstrMem,

            p0Load          => hostInstrMem_Load,
            p0LoadDatIndex  => hostInstrMem_LoadIndex,

            p0LoadDat       => hostInstrMem_LoadDat,
            p0Add           => hostInstrMem_Add,
            p0DatIn         => hostInstrMem_DatIn,
            p0Wr            => hostInstrMem_Wr,
            p0DatOut        => hostInstrMem_DatOut,
                        
            p1Load          => '0', 
            p1LoadDat       => (others => '0'),
            p1Add           => PCToMem,
            p1DatIn         => (others => '0'),
            p1Wr            => '0',
            p1DatOut        => instruction
          );
        
-- this mux allow the user to decide if the instruction going to the processor come from instruction memory or from the user himself
instructionToDecoder_i: process(instruction, useDebugInstruction, debugInstruction) -- instruction from program memory or external debug instruction
begin
    instructionToDecoder <= instruction; 
    if useDebugInstruction = '1' then
        instructionToDecoder <= debugInstruction;
    end if;
end process;

mainMemory_i: riscV_mainMem 
Port map (
            clk     => clk,
            rst     => rst,
            ce      => '1',
            memRdWr => memRdWr,
            addr    => addr,
            DIn     => DIn,
            valid   => memValid,
            memSize => memSize,
            Dout    => Dout,
            memBusy => memBusy
         );


RISCV_Top_i: RISCV_Top 
  Port map( 
		clk               => clk,
        rst_b             => rst_b,
        ce                => execInstr,
        mem_busy          => memBusy,
        instr_in          => instructionToDecoder,
        data_in           => DOut,
        
        instr_addr        => PC,
        data_addr         => addr,
        data_out          => DIn,
        mem_rd_wr         => memRdWr,
        mem_valid         => memValid,
        mem_size          => memSize,
        
        clrAllBreakpoints => clrAllBreakpoints,  
        enableBreakpoints => enableBreakpoints,
        clrBreakEvent     => clrBreakEvent,   
        breakAdd          => breakAdd, 
        breakWr           => breakWr,                    
        breakDat          => breakDat, 
        breakDatOut       => breakDatOut,
        break             => break
		);
end struct;