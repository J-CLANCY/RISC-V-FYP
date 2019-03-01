-- Engineer: Fearghal Morgan
-- viciLogic 
-- Creation Date: 18/5/2010
-- singleShot:  Pulse generator, unregistered signal aShot asserted on low to high transition of signal sw, 
-- and deasserted on subsequent active clk edge. 
-- 
-- Assume in normal operation that signal sw is deasserted.
-- If sw asserted when rst is toggled (asserted and deasserted), then aShot is asserted on the 
-- active clk edge following rst deassertion. This is likely to be unwanted functionality.
-- Could avoid this by defining waitFor0 as the reset state. 
-- aShot signal assertion will not occur if signal sw is asserted during rst assertion. 
--
-- Signal data dictionary 
--  clk	 clk strobe
--  rst	 asynchronous reset. Assertion puts state machine in state waitFor0. 
--  sw 	 input signal (low to high transition generates aShot pulse 
--  aShot unregistered signal aShot is asserted on low to high transition of signal sw. 
--	 	  unregistered signal aShot is deasserted on subsequent active clk edge.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity singleShot is
Port (
	  clk   : 	in 	std_logic;
      rst   : 	in 	std_logic;
      sw    : 	in 	std_logic; 
      aShot :   out std_logic  
	 ); 
end singleShot;

architecture RTL of singleShot is  
type stateType is (waitFor1, waitFor0); -- two states
signal CS, NS: stateType;			    -- current and next state signals

begin

NSAndOPDec_i: process (CS, sw) 
begin
   aShot <= '0';
   NS 	 <= CS; 				
   case CS is
		when waitFor1 => 		
			if sw = '1' then 
				aShot <= '1';    
				NS    <= waitFor0;
			end if;
		when waitFor0 =>  
			if sw = '0' then 
				NS    <= waitFor1;
			end if;
		when others => 
			null;  
   end case;
end process; 

stateReg_i: process (clk, rst)
begin
  if rst='1' then 		
    CS <= waitFor1;	
  elsif rising_edge(clk) then 
    CS <= NS;
  end if;
end process; 
   
end RTL;