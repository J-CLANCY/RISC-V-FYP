-- Authors: Fearghal Morgan, Arthur Beretta
-- Change History: Initial version
-- Copyright (c) 2011-2017 NUI Galway
--
-- Description: Top level RISC-V processor VHDL model
--
-- hostCtrlInstrMem  			assert to enable host control of instruction memory
-- hostInstrMem_Load  			assert to load instruction memory   
-- hostInstrMem_LoadIndex(1:0)  00 is default option. 01 synchronously loads a predefined test program in instruction memory 
-- hostInstrMem_LoadDat(31:0)   data value to be synchronously loaded in all instruction memory locations 
-- 
-- hostInstrMem_Add(9:0) 		instruction memory address (1024 locations max, 128 limit applied in register model)
-- hostInstrMem_DatIn(31:0)     instruction memory write data
-- hostInstrMem_Wr  			assert to synchronously write instruction memory location
-- hostInstrMem_DatOut(31:0)    combinational output, addressed instruction memory location
--
-- hostCtrlDataAndStackMem   					assert to enable host control of data/stack memory   
-- hostCtrlDataAndStackMem_Load         		assert to load data/stack memory   
-- hostCtrlDataAndStackMem_LoadDat(31:0)		data value to be synchronously loaded in all data/stack memory locations 
-- hostCtrlDataAndStackMem_Add(7:0)     		data/stack memory address (128 locations max, 16 limit applied in register model)
-- hostCtrlDataAndStackMem_DatIn(31:0)  		data/stack memory write data
-- hostCtrlDataAndStackMem_Wr           		assert to synchronously write data/stack memory location
-- hostCtrlDataAndStackMem_DatOut(31:0) 		combinational output, addressed data/stack memory location
-- hostCtrlDataAndStackMem_DatArrayOut(511:0)  	512-bit vector, concatenated  (16 x 32)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SingleCycCompPackage.all;

entity singleCycCompTop is
Port ( clk :        		in std_logic;						-- system clock strobe
       rst :        		in std_logic; 						-- asynchronous system reset, asserted

       --Host instruction interface can upload code to instruction mem
       hostCtrlInstrMem :    	   	  	 in  std_logic;    --activate the upload interface
       hostInstrMem_Load :               in  std_logic;  
       hostInstrMem_LoadIndex :          in  std_logic_vector(1 downto 0);                     
	   
       hostInstrMem_LoadDat :            in  std_logic_vector(31 downto 0); 
       hostInstrMem_Add :                in  std_logic_vector(9 downto 0);  
       hostInstrMem_DatIn :              in  std_logic_vector(31 downto 0); 
       hostInstrMem_Wr :                 in  std_logic;                     
       hostInstrMem_DatOut :             out std_logic_vector(31 downto 0); 
       
       
       --Host peripheral interface can control peripheral behaviour and read periph state
       hostCtrlDataAndStackMem :     	 in  std_logic;
       hostCtrlDataAndStackMem_Load :    in  std_logic;                      
       hostCtrlDataAndStackMem_LoadDat : in  std_logic_vector(31 downto 0); 
       hostCtrlDataAndStackMem_Add :     in  std_logic_vector(7 downto 0);  
       hostCtrlDataAndStackMem_DatIn :   in  std_logic_vector(31 downto 0);  
       hostCtrlDataAndStackMem_Wr :      in  std_logic;                      
       hostCtrlDataAndStackMem_DatOut :  out std_logic_vector(31 downto 0);  
	   hostCtrlDataAndStackMem_DatArrayOut : out std_logic_vector(511 downto 0);  


       --bypass intruction mem
       -- if useDebugInstruction == 1, exec debugInstruction
	   useDebugInstruction :       in std_logic;	                -- client instruction control. When enabled, overrides program memory instruction.   
       debugInstruction :  	       in std_logic_vector(31 downto 0);-- client instruction.     
       
	   runAll :    	 	 	       in std_logic;					-- assertion (H) asserts execInstr to enable an SCC interuction  
	   															    -- execution on each clock edge 
	   step :   			       in std_logic;					-- assertion (H) asserts execInstr for one clock period to enable 
	   															    -- a single SCC interuction, step must be deasserted before reassertion (push button)

  	   clrAllBreakpoints :   in std_logic;                         -- synchronously load breakpoint memory array
	   enableBreakpoints :   in std_logic;                         -- activate breakpointing function
	   clrBreakEvent : 		 in std_logic;                         -- assert on run/debug start or on re-run after a breakpoint detection
	   breakAdd :            in std_logic_vector(4 downto 0);      -- register array address
	   breakWr :             in std_logic;                         -- register array wr
	   breakDat :            in std_logic_vector(32 downto 0);     -- register array data in
	   breakDatOut :         out std_logic_vector(32 downto 0);    -- register array data out
	   break:    		     out std_logic;                        -- asserted if aBreakEvent or breakEvent asserted
	   
	   periphAdd		    : out std_logic_vector(31 downto 0);
       periphIn             : out std_logic_vector(31 downto 0);
       periphWr             : out std_logic;        
       periphOut            : in std_logic_vector(31 downto 0) 
	 );
end singleCycCompTop;

architecture struct of singleCycCompTop is 
-- Assertion enables register updates, e.g, R, SFR, PC, interrupt register writes, and pipelined register writes, if included in SCC architecture.  
signal int_break: std_logic;  -- asserted if aBreakEvent or breakEvent asserted 

signal execInstr :      std_logic;
signal singleStepPls :  std_logic;
signal PCVec :          std_logic_vector(11 downto 0);
signal cnt0To2 :        integer range 0 to 2;
signal execInstr_Reg :  std_logic;


begin 


singleShotStep_i : singleShot port map (  
	clk   => clk,
	rst   => rst,
	sw    => step,
	aShot => singleStepPls
	); 
	
execInstr_Reg_i:   execInstr_Reg <= singleStepPls or runAll; 

selectExecInstr_i: process (int_break, execInstr_Reg)
begin
  execInstr <= '0'; -- default 
  if int_break = '0' then        -- stop progress if break asserted
     execInstr <= execInstr_Reg; -- default. Assert every clk_period.
  end if;
end process;

break <= int_break;

singleCycCompAndMem_i: singleCycCompAndMem port map
     ( clk                             => clk, 
       rst                             => rst,             
       useDebugInstruction             => useDebugInstruction,
       debugInstruction                => debugInstruction,      
       PCVec                           => PCVec,      
       execInstr                       => execInstr,
	   	   
       hostCtrlInstrMem      => hostCtrlInstrMem,
       hostInstrMem_Load     => hostInstrMem_Load,
	   hostInstrMem_LoadIndex       =>  hostInstrMem_LoadIndex,

	   hostInstrMem_LoadDat  => hostInstrMem_LoadDat,
       hostInstrMem_Add      => hostInstrMem_Add, 
       hostInstrMem_DatIn    => hostInstrMem_DatIn,      
       hostInstrMem_Wr       => hostInstrMem_Wr,
       hostInstrMem_DatOut   => hostInstrMem_DatOut,

       hostCtrlDataAndStackMem         => hostCtrlDataAndStackMem,
       hostCtrlDataAndStackMem_Load    => hostCtrlDataAndStackMem_Load,        
       hostCtrlDataAndStackMem_LoadDat => hostCtrlDataAndStackMem_LoadDat,     
       hostCtrlDataAndStackMem_Add     => hostCtrlDataAndStackMem_Add,  
       hostCtrlDataAndStackMem_DatIn   => hostCtrlDataAndStackMem_DatIn, 
       hostCtrlDataAndStackMem_Wr      => hostCtrlDataAndStackMem_Wr,   
       hostCtrlDataAndStackMem_DatOut  => hostCtrlDataAndStackMem_DatOut,
	   hostCtrlDataAndStackMem_DatArrayOut => hostCtrlDataAndStackMem_DatArrayOut,


	   
   	   clrAllBreakpoints               => clrAllBreakpoints,
	   enableBreakpoints 			   => enableBreakpoints, 
	   clrBreakEvent  		           => clrBreakEvent,
	   breakAdd                        => breakAdd,  
	   breakWr                         => breakWr,   
	   breakDat                        => breakDat,  
       breakDatOut                     => breakDatOut,
	   break    		               => int_break,
	   
	   periphAdd		               => periphAdd,
       periphIn                        => periphIn,
       periphWr                        => periphWr,
                
       periphOut                       =>   periphOut  		          
  );

end struct;