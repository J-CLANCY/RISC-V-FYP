-- Break Function
-- Copyright (c) 2011-2017 Fearghal Morgan
-- 
-- Break when 
--  PC (program counter) breakpoints enabled (8 in total) and PC = any of 8 stored PC values, each enabled separately, with mask	in break array (12-bit value)
--  R  (register array)  breakpoint enabled (8 registers), R(7:0)(15:0)   value changes, and R   value = the corresponding stored R   value in break array   (16-bit value)
--
-- Store breakpoint values and breakpoint enable bits in break register array (XX_breakArray), written using the breakAdd(), breadWr, breakDat() interface.
-- Each breakpoint enable is bit(16) of XX_breakArray element
-- Breakpoint memory clears (all 0) synchronously on assertion of signal clrAllBreakpoints
--
-- breakEvent signal asserted on the occurrence of any breakpoint event
-- This can be used to deassert execInstr in Single Cycle Computer (SCC) to pause instruction execution, i.e, deasserted execInstr in singleCycleCompTop.vhd
-- The SCC Integrated Development Environment (IDE) can deassert the signal breakEvent following user action, by 
--  deasserting signal enableBreakpoints and then stepping the program etc
-- The IDE can reactivate breakpoints by re-asserting signal enableBreakpoint
-- 
-- PC(11:0)        current PC value  
-- R(7:0)(15:0):   current R array values. Register this to ensure that the value has changed in this clk cycle and avoid repeated breakpointing 
--
-- 
-- Signal data dictionary 
-- clk 	  	 				-- system clock strobe, low-to-high active edge
-- enableBreakpoints 		-- Assert to activate breakpointing
-- clrBreakEvent 			-- assert on run/debug start or on re-run after a breakpoint detection
-- clrAllBreakpoints        -- initialise breakpoint array
-- 
-- breakAdd(4:0)	     	 	 	     
-- breakWr 	    		         
-- breakDat(16:0) 				     
--
-- break						-- asserted if aBreakEvent or breakEvent asserted 
-- 
-- break array map: (V: bit value, X: don't care, always = 0)
--       	       16    15-13    12 11           0 


-- RISC-V
--       	       16    15-13    12 11           0 
--    PC* 		   EN    XXX      V  VVVV VVVV VVVV (check)
--
--       	       16    31-0  
--    R(n) 		   EN    VVVVVVVV


-- break array map: (V: bit value, X: don't care, always = 0)
--       	       16    15-13    12 11           0 
-- 8  R(0) 		   EN    VVV      V  VVVV VVVV VVVV
-- 9  R(1) 		   EN    VVV      V  VVVV VVVV VVVV
-- 10 R(2) 		   EN    VVV      V  VVVV VVVV VVVV
-- 11 R(3) 		   EN    VVV      V  VVVV VVVV VVVV
-- 12 R(4) 		   EN    VVV      V  VVVV VVVV VVVV
-- 13 R(5) 		   EN    VVV      V  VVVV VVVV VVVV
-- 14 R(6) 		   EN    VVV      V  VVVV VVVV VVVV
-- 15 R(7) 		   EN    VVV      V  VVVV VVVV VVVV
                                
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.RISCV_Package.all;
use work.arrayPackage.all;

-- FM: consider using system clk without needing SCC step control
-- for writing values to breakpoint ctrlReg, and for loading 0 in the breakpoint ctrlReg
entity breakFunction is 
Port ( clk : 			     in std_logic;                         -- system clock strobe, low-to-high active edge
	   rst : 			     in std_logic;                         -- system rst 
	   clrAllBreakpoints :   in std_logic;
	   enableBreakpoints :   in std_logic;
	   clrBreakEvent : 		 in std_logic;                         -- assert on run/debug start or on re-rn after a breakpoint detection

	   PC: 	           		 in std_logic_vector(31 downto 0);     -- current PC, R 
	   R:  	           		 in regType;	     	               -- 31 x 32-bit registers 

	   breakAdd :            in std_logic_vector(4 downto 0);      -- register array address
	   breakWr :             in std_logic;                         -- register array wr
	   breakDat :            in std_logic_vector(32 downto 0);     -- register array data in
	   breakDatOut :         out std_logic_vector(32 downto 0);    -- register array data out
	   break:    		     out std_logic := '0'                  -- asserted if aBreakEvent or breakEvent asserted 
	  );
end entity breakFunction;

architecture RTL of breakFunction is

component ctrlRegBlk31x33 is
 Port (  clk :              in std_logic;                     -- system clock strobe, low-to-high active edge
		 ld0 :              in std_logic;    				  -- synchronously load 0s in array
		 ctrlRegAdd31x33 :  in std_logic_vector(4 downto 0);  -- register address
		 enCtrlRegWr31x33:  in std_logic;                     -- register write enable, asserted high
		 ctrlRegIn31x33 :   in std_logic_vector(32 downto 0); -- data byte (to be written)
		 XX_ctrlReg31x33 :  out array31x33;                   -- array of ctrlReg 
		 ctrlRegOut31x33 :  out std_logic_vector(32 downto 0) -- addressed ctrlReg data 
 	  );
end component;

signal XX_breakArray               : array31x33;                                                    
signal XX_PCBreakValueArray 	   : regType8x12                  := (others => X"000");  -- 8 x 12-bit array
signal XX_PCBreakValueArrayEnable  : std_logic_vector(7 downto 0) := (others => '0');

signal XX_RBreakValueArray 	       : array31x33                    := (others => '0' & X"00000000"); -- 8 x 16-bit array
signal XX_RBreakValueEnable        : std_logic_vector(30 downto 0) := (others => '0');

signal breakEvent 		           : std_logic                    := '0';                 -- synchronously asserted on occurrence of any breakpoint

-- registered R values, used to ensure that R value changes as part of an R breakpoint detection
signal XX_dR                       : regType;  
signal XX_dPC                      : std_logic_vector(11 downto 0); -- registered PC value

-- combinational breakpoint flags 
signal aPCBreakFlag                 : std_logic;
signal aRBreakFlag                  : std_logic_vector(30 downto 0);
signal aBreakEvent                  : std_logic;                      

-- FM not required: registered breakpoint flags 
signal PCBreakFlag                  : std_logic;
signal RBreakFlag                  : std_logic_vector(30 downto 0);

begin	

breakDatOut <= (others => '0');
break <= '0';

--regValues_i: process (clk) -- register R values and use in breakpoint detection to prevent repeating a break on the current break value.  
--begin
--	if clk = '1' and clk'event then 
--		XX_dR   <= R;  
--        XX_dPC  <= PC;
--	end if;
--end process;

--asgnBreak_i: break <= aBreakEvent or breakEvent; -- aBreakEvent is unregistered signal, breakEvent is registered signal  
		 
--breakArray_i: ctrlRegBlk31x33  
-- Port map
--        (clk				=> clk,  
--		 ld0                => clrAllBreakpoints, 
--		 ctrlRegAdd31x33    => breakAdd,    
--		 enCtrlRegWr31x33   => breakWr,  
--		 ctrlRegIn31x33     => breakDat,    
--		 XX_ctrlReg31x33 	=> XX_breakArray,	 
--		 ctrlRegOut31x33	=> breakDatOut); 
		 
--process (XX_breakArray) -- assign ctrlReg breakpoint array values to specific breakpoint category signals, and breakpoint enable bits  
--begin
--	for i in 0 to 7 loop		
--		XX_PCBreakValueArray(i) 		 <= XX_breakArray(i)(11 downto 0);		
--		XX_PCBreakValueArrayEnable(i)       <= XX_breakArray(i)(32);
--	end loop;
    
--	for i in 8 to 39 loop		
--	  XX_RBreakValueArray(i-8) 		     <= XX_breakArray(i)(31 downto 0);
--	  XX_RBreakValueEnable(i-8)             <= XX_breakArray(i)(32);
--	end loop;

--end process;

--process (enableBreakpoints,   
--         PC,  XX_dPC,  XX_PCBreakValueArrayEnable,  XX_PCBreakValueArray,  
--         R,   XX_dR,   XX_RBreakValueEnable,        XX_RBreakValueArray)
--variable RMatchFlag   : BOOLEAN;
--begin
--	RMatchFlag   := FALSE;        -- defaults
--	aPCBreakFlag        <= '0'; 
--	aRBreakFlag         <= (others => '0'); 
--	aBreakEvent         <= '0';  

--    if enableBreakpoints = '1' then                     -- breakpoints enabled?

--	  for i in 0 to 7 loop
--			if XX_PCBreakValueArrayEnable(i) = '1' then -- breakpoint enabled?
--		 	   if (XX_PCBreakValueArray(i) = PC) then   -- check if the PC value is one of the PC break values
--			      if XX_dPC = PC then                   -- be sure to move on from current break event
--			        null;
--			      else
--					aPCBreakFlag <= '1';
--					aBreakEvent  <= '1';                     -- assert, combinationally 
--				  end if;
--			   end if;
--			end if;
--	  end loop;

--	  for i in 0 to 7 loop
--        if XX_RBreakValueEnable(i) = '1' then                -- breakpoint enabled?
--        	if XX_RBreakValueArray(i) = R(i) then            -- check each R value. Break event if any is equal to its break value
--        	    if XX_dR(i) = R(i) then                      -- no change from previous R value
--        	       null;                          
--        	    else                              
--        		   aRBreakFlag(i) <= '1'; 	          
--        		   aBreakEvent    <= '1';                    -- assert, combinationally 
--                end if;
--            end if;
--        end if;
--      end loop;
	   
--    end if;
-- end process;
	
--process (clk, rst) -- FM registered flags not used as outputs of this component
--begin
--	if rst = '1' then 
--		  PCBreakFlag        <= '0'; 
--          RBreakFlag         <= (others => '0'); 
--          breakEvent         <= '0';                       
--	elsif clk = '1' and clk'event then 
--   	      if clrBreakEvent = '1' then 
--		    PCBreakFlag        <= '0'; 
--            RBreakFlag         <= (others => '0'); 
--            breakEvent         <= '0';                       
--          else
--            if aPCBreakFlag = '1' then 
--              PCBreakFlag <= '1';   
--            end if;
--	  	    for i in 0 to 7 loop
--	  		  if aRBreakFlag(i) = '1' then 
--	  			RBreakFlag(i) <= '1';   
--	  		  end if;
--	  	    end loop;
--            if aBreakEvent = '1' then 
--              breakEvent <= '1';   
--            end if;
--		end if;
--	end if;
--end process;

end  RTL; 