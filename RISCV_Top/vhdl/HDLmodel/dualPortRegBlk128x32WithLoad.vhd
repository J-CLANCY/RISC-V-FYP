-- dualPortRegBlk128x32WithLoad
-- Synthesisable VHDL model for 128, writeable word (32-bit)-wide dual port register array, 
-- 
-- with load of all elements by either port 0 or port 1
-- Created :    Dec 2017. Fearghal Morgan
--
-- Supports two address/data/write/read ports (p0 and p1)
-- read
--   Port 0/1 can simultaneously read their addressed (p0Add/p1Add) array data (on buses P0DatOut/P1DatOut respectively) 
--
-- write
--   If enPort0 is asserted,   
--      assertion of p0Load (has priority over p0Wr): all elements in the array are synchronously loaded with p0LoadDat
--      port 0 data write access to the memory array is active (writing data p0Dat to p0Add, on assertion of p0Wr)
--   If enPort0 is deasserted,   
--      assertion of p1Load (has priority over p1Wr): all elements in the array are synchronously loaded with p1LoadDat
--      port 1 data write access to the memory array is active (writing data p1Dat to p1Add, on assertion of p1Wr)

-- Signal data dictionary
-- clk			      System clock strobe, rising edge active
-- rst			      System reset, assertion (high) clears all registers
-- enPort0			  Assertion (H) enables memory port 0 load (on assertion of p0Load), or writes (on assertion of p0Wr) 
--
-- p0Load 	 		  port 0 load enable. Assertion synchronously loads all memory array elements with p0LoadDat()
-- 	p0LoadDatIndex    allows selection of different load patterns
-- p0LoadDat(31:0)	  port 0 load data 
-- p0Add(7:0)  		  port 0 memory array address 
-- p0DatIn(31:0) 	  port 0 input data 
-- p0Wr 			  Assertion (H) enables synchronous write of addressed port 1 memory
-- P0DatOut(31:0)     port 0 data at p0Add
--
-- p1Load 	 		  port 1 load enable. Assertion synchronously loads all memory array elements with p1LoadDat()
-- p1LoadDat(31:0)	  port 1 load data 
-- p1Add(7:0)  		  port 1 memory array address 
-- p1DatIn(31:0) 	  port 1 input data 
-- p1Wr 			  Assertion (H) enables synchronous write of addressed port 1 memory
-- P1DatOut(31:0)     port 1 data at p1Add

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SingleCycCompPackage.ALL;

entity dualPortRegBlk128x32WithLoad is
 Port (  clk		: in  std_logic;    					 
		 rst		: in  std_logic;    					 
         enPort0    : in  std_logic;

		 p0Load	    : in  std_logic;   
		 p0LoadDatIndex  : in  std_logic_vector(1 downto 0);                      
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
end dualPortRegBlk128x32WithLoad;

architecture RTL of dualPortRegBlk128x32WithLoad is
signal XX_NS   : array128x32Instr; -- next state
signal XX_CS   : array128x32Instr; -- current state 
signal XX_load    : std_logic;   
signal XX_loadDat : std_logic_vector(31 downto 0);                      
signal XX_datIn   : std_logic_vector(31 downto 0);                      
signal XX_add     : std_logic_vector( 9 downto 0);                      
signal XX_wr      : std_logic;   
signal intP0LoadDat : array128x32Instr;

begin

genwrAddAndDat: process (enPort0,   p0Load, p0LoadDat, p0Add, p0DatIn, p0Wr,     p1Load, p1LoadDat, p1Add, p1DatIn, p1Wr)
begin
  XX_load    <= p1Load; -- defaults to port 1
  XX_loadDat <= p1LoadDat; 
  XX_add     <= p1Add; 
  XX_datIn   <= p1DatIn; 
  XX_wr      <= p1Wr; 
  if enPort0 = '1' then
    XX_load      <= p0Load;     
	XX_loadDat   <= p0LoadDat; 
    XX_add       <= p0Add; 
    XX_datIn     <= p0DatIn; 
    XX_wr        <= p0Wr; 
  end if;
  
  --XX_add(6 downto 4) <= "000"; -- force memory to 16 x 32 locations  
end process;

XX_NSDecode_i: process(XX_CS, XX_wr, XX_add, XX_datIn) 
begin
  XX_NS    <= XX_CS;                            -- default
  if XX_wr = '1' then
     XX_NS(TO_INTEGER(unsigned(XX_add(6 downto 0)))) <= XX_datIn; -- write addressed element (convert vector to integers, as index). 128 locations
  end if;
end process;

process (p0LoadDatIndex, XX_loadDat)
begin 
 intP0LoadDat <= (others => XX_loadDat); -- default
 if p0LoadDatIndex = "01" then 
   intP0LoadDat <= (others => X"00000000");
 end if;
end process;

stateReg_i: process(clk, rst) 
begin
 if rst = '1' then
    XX_CS <= (others => (others => '0')); 
 elsif clk'event and clk = '1' then
   if XX_load = '1' then 
     XX_CS <= intP0LoadDat; -- load array
   else
    XX_CS <= XX_NS; 
   end if;
 end if;
end process;

p0DatOut_i: p0DatOut <= XX_CS(TO_INTEGER(unsigned(p0Add(6 downto 0)))); -- output the addressed port 0 element -- have 128x32-bit locations
p1DatOut_i: p1DatOut <= XX_CS(TO_INTEGER(unsigned(p1Add(6 downto 0)))); -- output the addressed port 1 element

end RTL;