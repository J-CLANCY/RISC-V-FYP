-- Description : singleCycCompPackage 
-- Copyright (c) 2011-2017 Fearghal Morgan

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package singleCycCompPackage is

constant numInterrupts : integer := 3;

type ISRArray is array (2 downto 0) of std_logic_vector(11 downto 0);

type instrRegArrayType is array (127 downto 0) of std_logic_vector(15 downto 0);
type dataAndStackRegArrayType is array (30 downto 0) of std_logic_vector(15 downto 0);

-- temp register for testing
type instrRegArraySliceType is array (7 downto 0) of std_logic_vector(15 downto 0);

type regType32x16   is array (31 downto 0)  of std_logic_vector(15 downto 0);
type regType8x16    is array (7 downto 0)   of std_logic_vector(15 downto 0);
type regType16x16   is array (15 downto 0)  of std_logic_vector(15 downto 0);
type regType        is array (30 downto 0)  of std_logic_vector(31 downto 0);
type regType8x12    is array (7 downto 0)   of std_logic_vector(11 downto 0);

type array128x16    is array (127 downto 0)     of std_logic_vector(15 downto 0); -- note 0 to 127

type array16x32     is array (15 downto 0)      of std_logic_vector(31 downto 0);  
type array128x32    is array (127 downto 0)     of std_logic_vector(31 downto 0); 
type array128x32Instr    is array (0 to 127)     of std_logic_vector(31 downto 0); 


type array31x33     is array (30 downto 0)      of std_logic_vector(32 downto 0);

--block type for the communication between main & cache memory
type blockType4x32  is array (3 downto 0)   of std_logic_vector(31 downto 0);
--memory blocks to simulate main memory (16 blocks of 4x32 bits)
type memBlock16x4x32 is array (63 downto 0) of std_logic_vector(31 downto 0);
--memory lines to simulate cache memory (4 lines of 1 validation bit, 22 tag bits, 128 data bits)
type memLine4x55 is array (3 downto 0) of std_logic_vector(150 downto 0);


constant maxCount : integer := 50000000;  
constant maxDlyPeriods : integer := 1; 		 

constant clkPeriod : time := 20 ns;

constant numWords : integer := 128; 
type BRAM0Type is array (numWords-1 downto 0) of std_logic_vector(31 downto 0); 


component riscV_cacheMem is
    Port ( 
        clk 	    : in std_logic;       --Clock
        rst         : in std_logic;       --Reset
        ce          : in std_logic;       --Chip Enable
        memRd        : in std_logic;       --Memory read control
        memWr       : in std_logic;       --Memory write control
        memSize     : in std_logic_vector(1 downto 0);     -- size of data to be Rd/Wr to memory (8/16/32 bits)
        memLine     : in std_logic_vector(7 downto 0);     -- line of the cache
        tagIn       : in std_logic_vector(21 downto 0);    -- tag associated with the line in
        tagOut      : out std_logic_vector(21 downto 0);   -- tag associated with the line Out
        wrCtrl      : in std_logic;
        DBlockIn    : in blockType4x32;                    -- Data in (block size)
        DBlockOut   : out blockType4x32;                   -- Data out (block size)
        memBusy     : out std_logic;                       -- 1 if memory is busy
        lineValid   : out std_logic                        -- line validity
           );
end component;



--component instructionDecode is
--    Port ( 
--        instruction         : in std_logic_vector(31 downto 0);
--        PCCUCtrl            : out std_logic_vector(1 downto 0);
--        WBCtrl              : out std_logic_vector(2 downto 0);
--        regWr               : out std_logic;
--        operandFetchCtrl    : out std_logic_vector(2 downto 0);
--        ALUOp               : out std_logic_vector(3 downto 0);
--        memCtrl             : out std_logic_vector(3 downto 0)
--           );
--end component;

component riscV_cacheCtrl is
    Port ( 
        clk         : in std_logic;   
        rst         : in std_logic;   
        ce          : in std_logic;                         --Chip enable in
        addr        : in std_logic_vector  (31 downto 0);   -- Instrution comming from instruction memory
        memBusy     : in std_logic;                         -- stall the processor if 1
        MissOrHit   : in std_logic;                         --'0' = miss, '1' = hit
        memRd        : in std_logic;                         --Cache memory read control
        memWr       : in std_logic;                         --Cache memory write control
        mainMemBusy : in std_logic;
        cacheMemBusy: out std_logic;
        selMainOrCache  : out std_logic;
        WrMainMem       : out std_logic;        -- Write control for main memory
        RdMainMem       : out std_logic;        -- Read control for main memory
        blockAddr       : out std_logic_vector(31 downto 0);
        WrCtrl          : out std_logic;    -- WrControl for the cache memory, if 1, writte to chache memory block that is present in blockout
        replaceWord     : out std_logic     -- if 1, dataCtr will replace the word in the block
        );
end component;

component riscV_cacheDataCtrl is
    Port ( 
        DMainOut    : in blockType4x32;     --Block from main memory
        DMainIn     : out blockType4x32;    --Block to main memory
        DBlockOut   : in blockType4x32;     --Block from cache memory
        DBlockIn    : out blockType4x32;    --Block to cache memory
        DProcIn         : in std_logic_vector(31 downto 0);     --word from processor
        DProcOut        : out std_logic_vector(31 downto 0);    -- word to processor
        replaceWord : in std_logic;         -- if 1, replace the word of DMainOut by DProcIn an outputed it on DBlockIn & DMainIn
        selMainOrCache : in std_logic;      -- if 0, main memory is selected, if 1 cache memory is selected
        cell        : in std_logic_vector (1 downto 0)  --define the word position in the block
           );
end component;

component riscV_mainMem is
    Port ( 
        clk         : in std_logic;       --Clock
        rst         : in std_logic;       --Reset
        ce          : in std_logic;       --Chip Enable
        memRdWr     : in std_logic;       --Memory read/write control (if 0 read, if 1, writte)
        addr        : in std_logic_vector(31 downto 0);      --Address of the block         
        DIn         : in std_logic_vector(31 downto 0);      --Data in 
        valid       : in std_logic;                          -- validate de commande
        memSize     : in std_logic_vector(1 downto 0);
        Dout        : out std_logic_vector(31 downto 0);     --Data in 
        memBusy     : out std_logic            -- 1 if memory is busy
           );
end component;

component riscV_controller is
    Port ( 
        clk                 : in std_logic;   
        rst                 : in std_logic;   
        instruction         : in std_logic_vector  (31 downto 0);   -- Instrution comming from instruction memory
        memBusy             : in std_logic;                         -- stall the processor if 1
        CE_in               : in std_logic;                         --Chip enable in
        PCCUCtrl            : out std_logic_vector (1 downto 0);    
        PCCUValidate        : out std_logic;                        -- Validate next PC
        WBCtrl              : out std_logic_vector (2 downto 0);
        WBValidate          : out std_logic;
        OFCtrl              : out std_logic_vector (2 downto 0);
        ALUCtrl             : out std_logic_vector (3 downto 0);
        memValid            : out std_logic;
        memRdWr             : out std_logic;
        memSize             : out std_logic_vector (1 downto 0)
           );
end component;

component riscV_PCCU is
    Port (
        clk 		    : in std_logic;                       	  --clock
        rst 		    : in std_logic;			  	  --reset
        CE              : in std_logic;                         --Chip Enable
        zero            : in std_logic;                           --compaison from ALU
        PCCUCtrl        : in std_logic_vector(1 downto 0);        --Control from decoder/controler
        PCplusOffset    : in std_logic_vector (31 downto 0);      --PC from address comutation
        PC              : out std_logic_vector (31 downto 0);     
        PCplus4         : out std_logic_vector (31 downto 0)
          );
end component;

component writeBack is
    Port ( 
        clk 	    	: in std_logic;
        rst             : in std_logic;
        CE              : in std_logic;                         --Chip Enable
        instruction     : in std_logic_vector(31 downto 0);
        WBCtrl          : in std_logic_vector(2 downto 0);
        PCplus4         : in std_logic_vector(31 downto 0);
        memOut          : in std_logic_vector(31 downto 0);
        ALUOut          : in std_logic_vector(31 downto 0);     --default input connected 
        reg             : out regType
           );
end component;


component ALU is
    Port ( operation : in std_logic_vector(3 downto 0);             
           A 	     : in std_logic_vector (31 downto 0);
           B 	     : in std_logic_vector (31 downto 0);
           result 	 : out std_logic_vector (31 downto 0);
--         carryout	 : out std_logic;
           Zero      : out std_logic
		 );
end component;

component operandFetch is
    Port ( 
        OFCtrl              : in std_logic_vector(2 downto 0);      --controler
        PC                  : in std_logic_vector(31 downto 0);     --Program Counter
        instruction         : in std_logic_vector(31 downto 0);       
        reg                 : in regType;                             --Register i/p
        PCorRegA             : out std_logic_vector(31 downto 0);    --Output to address computation
        immediate           : out std_logic_vector(31 downto 0);    --Output to address computation
        memIn                 : out std_logic_vector(31 downto 0);    --Output to memory 
        ALUA                 : out std_logic_vector(31 downto 0);    --Output A to ALU
        ALUB                 : out std_logic_vector(31 downto 0)    --Output B to ALU
       );
end component;

component addr_add is
    Port ( 
        PCorRegA    	: in std_logic_vector(31 downto 0);   
        immediate       : in std_logic_vector(31 downto 0);   
        PCPlusOffset 	: out std_logic_vector(31 downto 0)  
                 
           );
end component;

component breakFunction is 
    Port ( 
       clk                  : in std_logic;                         -- system clock strobe, low-to-high active edge
	   rst                  : in std_logic;                         -- system rst 
	   clrAllBreakpoints    : in std_logic;
	   enableBreakpoints    : in std_logic;
	   clrBreakEvent        : in std_logic;                         -- assert on run/debug start or on re-rn after a breakpoint detection

	   PC                   : in std_logic_vector(11 downto 0);     -- current PC, R, SFR values
	   R  	           		: in regType;	     	                -- 8 x 16-bit registers 

	   breakAdd             : in std_logic_vector(4 downto 0);      -- register array address
	   breakWr              : in std_logic;                         -- register array wr
	   breakDat             : in std_logic_vector(32 downto 0);     -- register array data in
	   breakDatOut          : out std_logic_vector(32 downto 0);    -- register array data out
	   break    		    : out std_logic := '0'                 -- asserted if aBreakEvent or breakEvent asserted 
	  );
end component;

component SCCStepAndRunAllInterface is -- no longer used
Port (
	   clk : 	  in 	std_logic;
       rst : 	  in 	std_logic;
       ddStep :   in 	std_logic; 
       ddRunAll : in 	std_logic; 
       memRdInstruction : in 	std_logic; 
       execInstr : out 	std_logic  
     );
end component;

COMPONENT singleShotWithExecInstr is
Port (
	   clk : 	   in 	std_logic;
       rst : 	   in 	std_logic;
       execInstr : in std_logic;
       sw : 	   in 	std_logic; 	-- i/p sig (assumed sourced within clk domain, so no metastability synch reqd
       aShot :     out 	std_logic; 	-- unregistered output
       shot : 	   out 	std_logic); -- registered version of shot
end COMPONENT;

component singleShot is
Port ( clk : 	in 	std_logic;
       rst : 	in 	std_logic;
       sw : 	in 	std_logic; 	  -- i/p sig (assumed sourced within clk domain, so no metastability synch reqd
       aShot :  out 	std_logic -- unregistered output
       ); 
end component;

component singleShotandDelay is
Port (
	   clk : 	in 	std_logic;
       rst : 	in 	std_logic;
       sw : 	in 	std_logic; 	    -- i/p sig (assumed sourced within clk domain, so no metastability synch reqd
       aShot : out 	std_logic; 	    -- unregistered output
       shot : 	out 	std_logic); -- registered version of shot
end component;

COMPONENT dataAndStackMemCtrlr is 
port ( 	
    clk         : in std_logic;
    rst         : in std_logic;
    addr		: in std_logic_vector(31 downto 0);   
    memIn	    : in std_logic_vector(31 downto 0);   
    memCtrl 	: in std_logic_vector(3 downto 0); 
    
    periphAdd   : out std_logic_vector(31 downto 0);
    periphIn    : out std_logic_vector(31 downto 0);
    periphWr    : out std_logic;
    
    periphOut   : in std_logic_vector(31 downto 0);             -- data and stack memory	   
    memOut      : out std_logic_vector(31 downto 0)	
			);
end COMPONENT;

component dualPortRegBlk16x32WithLoad is
 Port (  clk		: in  std_logic;    					 
		 rst		: in  std_logic;    					 
         enPort0    : in  std_logic;

		 p0Load	    : in  std_logic;   
		 p0LoadDat  : in  std_logic_vector(31 downto 0);                      
		 p0Add 	 	: in  std_logic_vector( 6 downto 0);   
		 p0DatIn  	: in  std_logic_vector(31 downto 0);                      
		 p0Wr 	    : in  std_logic;   
	     p0DatOut   : out std_logic_vector(31 downto 0);                      
		 p0DatArrayOut : out std_logic_vector(511 downto 0);

		 p1Load	    : in  std_logic;   
		 p1LoadDat  : in  std_logic_vector(31 downto 0);                      
		 p1Add 	 	: in  std_logic_vector( 6 downto 0);   
		 p1DatIn  	: in  std_logic_vector(31 downto 0);                      
		 p1Wr 	    : in  std_logic;   
	     p1DatOut   : out std_logic_vector(31 downto 0)                     
 		 );         
end component;

component dualPortRegBlk128x32WithLoad is
 Port (  clk		: in  std_logic;    					 
		 rst		: in  std_logic;    					 
         enPort0    : in  std_logic;

		 p0Load	    : in  std_logic;   
		 p0LoadDatIndex : in  std_logic_vector(1 downto 0);
		 p0LoadDat  : in  std_logic_vector(31 downto 0);                      
		 p0Add 	 	: in  std_logic_vector( 9 downto 0);   
		 p0DatIn  	: in  std_logic_vector(31 downto 0);                      
		 p0Wr 	    : in  std_logic;   
	     p0DatOut   : out std_logic_vector(31 downto 0);                      

		 p1Load	    : in  std_logic;   
		 p1LoadDat  : in  std_logic_vector(31 downto 0);                      
		 p1Add 	 	: in  std_logic_vector( 9 downto 0);   
		 p1DatIn  	: in  std_logic_vector(31 downto 0);                      
		 p1Wr 	    : in  std_logic;   
	     p1DatOut   : out std_logic_vector(31 downto 0)                     
 		 );         
end component;


component InstructionMemory is 
port (	
    PC              : in integer range 4095 downto 0; -- instruction address
    instruction     : out std_logic_vector(31 downto 0)
		 );
end component;

component singleCycComp is
    Port ( 
        clk         		: in std_logic;						-- system clock strobe
        rst                 : in std_logic;                         -- asynchronous system reset, asserted
        PC                  : out std_logic_vector(31 downto 0);   -- instruction address 
        instruction         : in std_logic_vector(31 downto 0);   -- instruction, includes 7 bit OPCODE (15:9). Refer to incstruction set.
        execInstr           : in std_logic;                        -- asserted through user control (step/runAll) to enable registers    
        
        
        clrAllBreakpoints   : in std_logic;   
        enableBreakpoints   : in std_logic;
        clrBreakEvent       : in std_logic;                      -- assert on run/debug start or on re-run after a breakpoint detection
        breakAdd            : in std_logic_vector(4 downto 0);   -- register array address
        breakWr             : in std_logic;                      -- register array wr
        breakDat            : in std_logic_vector(32 downto 0);  -- register array data in
        breakDatOut         : out std_logic_vector(32 downto 0); -- register array data out
        break               : out std_logic;                      -- asserted if aBreakEvent or breakEvent asserted 
        
        memBusy             : in std_logic;
        memOut              : in std_logic_vector(31 downto 0);
        memValid            : out std_logic;
        memRdWr             : out std_logic;
        memSize             : out std_logic_vector (1 downto 0);
        ALUOut              : out std_logic_vector(31 downto 0);
        memIn               : out std_logic_vector(31 downto 0)
	   );
end component;

component singleCycCompAndMem is
Port (
        clk :        		       		 in std_logic;						-- system clock strobe
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
end component;

component RISCV_Top is
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
end component;

end singleCycCompPackage;

package body singleCycCompPackage is
 
end singleCycCompPackage;