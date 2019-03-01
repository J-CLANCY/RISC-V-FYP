LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
USE ieee.std_logic_textio.all; -- necessary when using fileIO
USE std.textio.all;	 
use work.SingleCycCompPackage.all;

ENTITY singleCycCompTop_TB IS END singleCycCompTop_TB;

ARCHITECTURE behavior OF singleCycCompTop_TB IS 

component singleCycCompTop is
Port (
	   clk :        		in std_logic;						-- system clock strobe
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
end component; 

SIGNAL clk :  std_logic := '0';
SIGNAL rst :  std_logic := '1';

SIGNAL       hostCtrlInstrMem :    	   	  	   std_logic;
SIGNAL       hostInstrMem_Load :               std_logic;
signal       hostInstrMem_LoadIndex :          std_logic_vector(1 downto 0);                     
                     
SIGNAL       hostInstrMem_LoadDat :            std_logic_vector(31 downto 0); 
SIGNAL       hostInstrMem_Add :                std_logic_vector(9 downto 0);  
SIGNAL       hostInstrMem_DatIn :              std_logic_vector(31 downto 0); 
SIGNAL       hostInstrMem_Wr :                 std_logic;                     
SIGNAL       hostInstrMem_DatOut :             std_logic_vector(31 downto 0); 
    
signal       hostCtrlDataAndStackMem :         std_logic;
SIGNAL       hostCtrlDataAndStackMem_Load :    std_logic;                      
SIGNAL       hostCtrlDataAndStackMem_LoadDat : std_logic_vector(31 downto 0); 
SIGNAL       hostCtrlDataAndStackMem_Add :     std_logic_vector(7 downto 0);  
SIGNAL       hostCtrlDataAndStackMem_DatIn :   std_logic_vector(31 downto 0);  
SIGNAL       hostCtrlDataAndStackMem_Wr :      std_logic;                      
SIGNAL       hostCtrlDataAndStackMem_DatOut :  std_logic_vector(31 downto 0);  
SIGNAL	     hostCtrlDataAndStackMem_DatArrayOut : std_logic_vector(511 downto 0);  

signal 	     useDebugInstruction : 			   std_logic;	                    -- client instruction control. When enabled, overrides program memory instruction.   
signal 	     debugInstruction :  			   std_logic_vector(31 downto 0);	-- client instruction.     
signal 	     runAll : 		 				   std_logic;
signal 	     step :   		 				   std_logic;

signal	     periphAdd		    :  std_logic_vector(31 downto 0);
signal       periphIn             :  std_logic_vector(31 downto 0);
signal       periphWr             :  std_logic;        
signal       periphOut            :  std_logic_vector(31 downto 0);
signal     	 clrAllBreakpoints :      std_logic;   
signal	   	 enableBreakpoints :      std_logic;
signal	   	 clrBreakEvent : 		  std_logic;                      -- assert on run/debug start or on re-rn after a breakpoint detection
signal	  	 breakAdd  :              std_logic_vector(4 downto 0);   -- ctrlReg register array address
signal	  	 breakWr :                std_logic;                      -- ctrlReg register array write enable, asserted high
signal	  	 breakDat 	:             std_logic_vector(32 downto 0);  -- ctrlReg register array data (to be written)
signal	  	 breakDatOut:             std_logic_vector(32 downto 0);  -- enable specific interrupt breakpoint
signal	  	 break:    		          std_logic;                      -- asserted if aBreakEvent or breakEvent asserted 

constant clkPeriod   : time := 20 ns;	      -- 50MHz clk


--Outputs
signal endOfSim :        boolean := false;
signal instrArray: array128x32 := 	 
 (X"ff010113", X"00100793", X"00f12623", X"00200793", X"00f12423", X"00012223", X"00c12703", X"00812783", 
  X"00f707b3", X"00f12223", X"00412783", X"00078513", X"01010113", X"00008067", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
  X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000"
  );
 

BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: singleCycCompTop port map 
	 (clk  			  => clk,  					
	  rst 			  => rst, 
	  
	  hostCtrlInstrMem                         => hostCtrlInstrMem,                    
      hostInstrMem_Load                        => hostInstrMem_Load,                   
      hostInstrMem_LoadIndex                   => hostInstrMem_LoadIndex,                   
	         
	  hostInstrMem_LoadDat                     => hostInstrMem_LoadDat,                
	  hostInstrMem_Add                         => hostInstrMem_Add,                    
	  hostInstrMem_DatIn                       => hostInstrMem_DatIn,                  
	  hostInstrMem_Wr                          => hostInstrMem_Wr,                     
	  hostInstrMem_DatOut                      => hostInstrMem_DatOut,                 
                                                                                    
      hostCtrlDataAndStackMem 				   => hostCtrlDataAndStackMem, 
      hostCtrlDataAndStackMem_Load             => hostCtrlDataAndStackMem_Load,        
      hostCtrlDataAndStackMem_LoadDat          => hostCtrlDataAndStackMem_LoadDat,     
      hostCtrlDataAndStackMem_Add              => hostCtrlDataAndStackMem_Add,         
      hostCtrlDataAndStackMem_DatIn            => hostCtrlDataAndStackMem_DatIn,       
	  hostCtrlDataAndStackMem_Wr               => hostCtrlDataAndStackMem_Wr,          
      hostCtrlDataAndStackMem_DatOut           => hostCtrlDataAndStackMem_DatOut,      
      hostCtrlDataAndStackMem_DatArrayOut      => hostCtrlDataAndStackMem_DatArrayOut, 

      useDebugInstruction  => useDebugInstruction, 
      debugInstruction     => debugInstruction,
      
	  runAll          => runAll,           
	  step            => step,           

	  	  
      clrAllBreakpoints  => clrAllBreakpoints,
	  enableBreakpoints  => enableBreakpoints, 
	  clrBreakEvent  	 => clrBreakEvent, 		   
	  breakAdd           => breakAdd,          
	  breakWr            => breakWr,          
	  breakDat 	         => breakDat,         
	  breakDatOut        => breakDatOut, 
	  break     		 => break,
	  periphAdd		     => periphAdd,
      periphIn           => periphIn,
      periphWr           => periphWr,
               
      periphOut          => periphOut      
	 ); 			  
 
clkStim:	process (clk)
begin
 if (endOfSim = false) then 
   clk <= not clk after clkPeriod/2;
 end if; 
end process;

STIMUsingFileIO : PROCESS 
 -- line 1 : contains number of data values to be read and number of clk periods delay 
 -- further lines : each contains data value and number of clk periods delay 
 variable i: integer range 0 to 255 := 0; 
 variable instructionMem : std_logic_vector(31 downto 0) := (others => '1');

 variable foundInstr : boolean;
 variable LL : line;
 variable char : character; 
 variable char3, char2, char1, char0 : character; 
 variable data : std_logic_vector(7 downto 0); 
 variable numClks : integer range 0 to 255; 
 file stimIn : text open READ_MODE is "stimDatSCC.txt";  -- input file declaration
 variable result : Bit_Vector(3 downto 0);	
 variable good, issue_error : boolean;

 procedure chkIFCharIsx(C: Character; 
				RESULT: out Bit_Vector(3 downto 0);
				GOOD: out Boolean;
				ISSUE_ERROR: in Boolean) is
	begin
		case c is
			when 'x'    => result := x"F"; good := TRUE;
			when others =>                 good := FALSE;
		end case;
	end;

  
 procedure Char2QuadBits(C: Character; 
				RESULT: out Bit_Vector(3 downto 0);
				GOOD: out Boolean;
				ISSUE_ERROR: in Boolean) is
	begin
		case c is
			when '0' => result :=  x"0"; good := TRUE;
			when '1' => result :=  x"1"; good := TRUE;
			when '2' => result :=  x"2"; good := TRUE;
			when '3' => result :=  x"3"; good := TRUE;
			when '4' => result :=  x"4"; good := TRUE;
			when '5' => result :=  x"5"; good := TRUE;
			when '6' => result :=  x"6"; good := TRUE;
			when '7' => result :=  x"7"; good := TRUE;
			when '8' => result :=  x"8"; good := TRUE;
			when '9' => result :=  x"9"; good := TRUE;
			when 'A' => result :=  x"A"; good := TRUE;
			when 'B' => result :=  x"B"; good := TRUE;
			when 'C' => result :=  x"C"; good := TRUE;
			when 'D' => result :=  x"D"; good := TRUE;
			when 'E' => result :=  x"E"; good := TRUE;
			when 'F' => result :=  x"F"; good := TRUE;
 
			when 'a' => result :=  x"A"; good := TRUE;
			when 'b' => result :=  x"B"; good := TRUE;
			when 'c' => result :=  x"C"; good := TRUE;
			when 'd' => result :=  x"D"; good := TRUE;
			when 'e' => result :=  x"E"; good := TRUE;
			when 'f' => result :=  x"F"; good := TRUE;
			when others =>
			   if ISSUE_ERROR then 
				   assert FALSE report
					"HREAD Error: Read a '" & c &
					   "', expected a Hex character (0-F).";
			   end if;
			   good := FALSE;
		end case;
	end;
 
 begin 

-- defaults

       hostCtrlInstrMem <= '0';
       hostInstrMem_Load <= '0';
       hostInstrMem_LoadIndex <= "00";
       hostInstrMem_Add    <= (others => '0');
       hostInstrMem_DatIn  <= (others => '0');
       hostInstrMem_Wr     <= '0'; 
	   
	   hostCtrlDataAndStackMem                <= '0';
	   hostCtrlDataAndStackMem_Load           <= '0';
	   hostCtrlDataAndStackMem_LoadDat        <= (others => '0');
	   hostCtrlDataAndStackMem_Add            <= (others => '0');
	   hostCtrlDataAndStackMem_DatIn          <= (others => '0');
	   hostCtrlDataAndStackMem_Wr             <= '0';
	   
      useDebugInstruction  <= '0';
      debugInstruction     <= (others => '0');
      
	  periphOut <= (others => '0');

       hostInstrMem_Add    <= (others => '0');
       hostInstrMem_DatIn  <= (others => '0');
       hostInstrMem_Wr     <= '0'; 
 	   
	   hostCtrlDataAndStackMem <= '0';
       hostCtrlDataAndStackMem_Load     <= '0';
       hostCtrlDataAndStackMem_LoadDat  <= (others => '0');

       hostCtrlInstrMem <= '0';
       hostInstrMem_Load <= '0';
       hostInstrMem_LoadDat <= X"00000000";
	   
	   
 runAll 				<= '0';			-- deassertion (h) enables single stepping 
 step 					<= '0';			-- single step input signal (default is deasserted)

   	   clrAllBreakpoints            <= '0';	 
	   enableBreakpoints            <= '0';	 
	   clrBreakEvent 				<= '0';	 
	   breakAdd  			    	<= (others => '0'); 
	   breakWr 				        <= '0';	           
	   breakDat 				    <= (others => '0'); 

 rst 					<= '1';
 wait for 1.7*clkPeriod; -- simulate to just after clk rising edge
 rst 					<= '0';
 wait for clkPeriod;  


 
-- clear memory intruction arrays, brealpointint and data & stack
   	   clrAllBreakpoints            <= '1';	 
       hostCtrlInstrMem <= '1';
       hostInstrMem_Load <= '1';
       hostInstrMem_LoadDat <= X"00000000"; 
	   wait for clkPeriod;
   	   clrAllBreakpoints            <= '0';	 
       hostInstrMem_Load <= '0';
       hostCtrlInstrMem <= '0';
	   wait for clkPeriod;  

	   hostCtrlDataAndStackMem <= '1';
       hostCtrlDataAndStackMem_Load     <= '1';
       hostCtrlDataAndStackMem_LoadDat  <= (others => '0');
	   wait for clkPeriod;  
       hostCtrlDataAndStackMem_Load     <= '0';
	   hostCtrlDataAndStackMem <= '0';
	   wait for clkPeriod;  


 -- o/p msg to simulation  transcript
 report "generate single cycle computer stimulus instruction memory array"; 

--not using debug intr
      useDebugInstruction  <= '0';
      debugInstruction     <= (others => '0');

--feedind instr mem from instr array
 for i in 0 to 127 loop
  hostCtrlInstrMem <= '1';
  hostInstrMem_Add    <= std_logic_vector(to_unsigned(i, 10));
  hostInstrMem_DatIn  <= instrArray(127-i);
  hostInstrMem_Wr     <= '1'; 
  wait for clkPeriod; 	 
  hostInstrMem_Wr     <= '0'; 
  wait for clkPeriod; 	 
 end loop;
 hostCtrlInstrMem <= '0';   --disable feeding
 
 
 --reset doesn't affect instr mme, breakpoint mem or data & stack mem
-- assert rst to clear PC and reg
  rst 					<= '1';
  wait for clkPeriod; 
  rst 					<= '0';
  wait for clkPeriod;  
 
--	   breakAdd    <= "01011";
--	   breakWr     <= '1'; 
--	   breakDat    <= '1' & X"0000F7FF"; -- 33 bits
--  wait for clkPeriod;  
--	   breakWr     <= '0'; 

--  enableBreakpoints            <= '1';	 

  for j in 1 to 50 loop
    step <= '1'; -- single step assert
    wait for clkPeriod; 	 
    step <= '0'; -- single step deassert
    wait for clkPeriod;
  end loop;
    

  runAll <= '1'; -- single step assert
  wait for 500*clkPeriod;  
   
 report "simulation done";   -- o/p msg to sim transcript
 endOfSim <= true;
 wait; -- will wait forever
 END PROCESS;

end;