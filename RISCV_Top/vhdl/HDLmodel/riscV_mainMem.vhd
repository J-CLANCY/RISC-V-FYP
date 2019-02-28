-- Description: Main mmeory, simuated with registers
-- Engineer: Arthur Beretta
-- * viciLogic (organisation)
-- Date: 21th June 2018 
-- Change History: Initial version
-- 

-- Precise description :
--The main memory is the sower one but the larger one. It is now simulted with registers,
--only four block of four words are available.

-- How does it work for writting :
-- memWr is asserted, the data is present on DInOut and the adress is present on addr.
-- During the writting process, memBusy is asserted, saying that memory cannot be activated 
-- for other operation. During the writting process, the data and the address on DInOut and addr
-- must not be present. When the writting is finihed, memBusy is deasserted.

-- How does it work for the reading :
-- memRd is asserted which lead to the assertion of memBusy. memRd can be deasserted
-- during the reading process. When the reading process is finished, data are released
-- on the DInOut bus and memBusy is deasserted.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_Package.all;

-- include component name and signals
entity riscV_mainMem is
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
end riscV_mainMem;

architecture RTL of riscV_mainMem is

signal count        : integer range 0 to 10;
signal XX_memReg       : array128x32;	-- memory register !!! CAUTION !!! If you change the size of the memory, you must change initialization of the stack pointer in WritteBack VHDL file
signal releaseWr    : std_logic;        --Writting is done in a 10 clock period time
signal releaseRd    : std_logic;        --Reading is done in a 8 clock period time
signal memWrIntern  : std_logic;         --internal memWr, due to the possibility that memWr can be deasserted during the writting process
signal memRdIntern  : std_logic;         --internal memRd, due to the possibility that memRd can be deasserted during the reading process
signal DinReg       : std_logic_vector(31 downto 0);    --register to store Din
signal addrReg      : std_logic_vector(6 downto 0);     --register to store Addr

begin
-- constant links, memBusy is asserted at the moment the processor ask for read or writte
memBusy_Assign: process(memRdIntern, memWrIntern, memRdWr)
begin
    if memRdWr = '1' then
        memBusy <= memWrIntern;
    else
        memBusy <= memRdIntern;
    end if;
end process;

-- register to store data commig in the memory, as Din can change
DinReg_i : process (clk, rst)
begin
    if rst = '1' then
        DinReg <= (others => '0');   --reset register signals
    elsif rising_edge(clk) then
        if ce = '1' and valid = '1' and memRdWr = '1' then
            DinReg <= Din;
        end if;
    end if;
end process;

-- register to store address commig in the memory, as addr can change
addrReg_i : process (clk, rst)
begin
    if rst = '1' then
        addrReg <= (others => '0');   --reset register signals
    elsif rising_edge(clk) then
        if ce = '1' and valid = '1'then
            addrReg <= addr(6 downto 0);
        end if;
    end if;
end process;
    
--memWr register, to save write status
memWrInternReg_i : process (clk, rst)
begin
    if rst = '1' then
        memWrIntern <= '0';   --reset internal signals
    elsif rising_edge(clk) then
        if ce = '1' and valid = '1' and memRdWr = '1' then
            memWrIntern <= '1';
        end if;
        if releaseWr = '1' then
            memWrIntern <= '0';
        end if;
    end if;
end process;

--memRd register, to save read status
memRdInternReg_i : process (clk, rst)
begin

    if rst = '1' then
        memRdIntern <= '0';   --reset internal signals
    elsif rising_edge(clk) then
        if ce = '1' and valid = '1' and memRdWr = '0' then
            memRdIntern <= '1';
        end if;
        if releaseRd = '1' then
            memRdIntern <= '0';
        end if;
    end if;
end process;

-- synchronous process
-- simulate memory slowness by counting clock period
count_i: process(clk, rst, CE, memRdWr, memWrIntern, memRdIntern, count)
begin

    if rst = '1' then
        count <= 0;   --reset counter
    elsif rising_edge(clk) then
        releaseWr <= '0';   --default
        releaseRd <= '0';
        count <= 0;
        if CE = '1' then
            if (memRdIntern = '1') then
                if count < 8 then
                    count <= count + 1;
                else
                    releaseRd <= '1';
                end if;
                
            elsif (memWrIntern = '1') then
                if count < 10 then
                    count <= count + 1;
                else
                    releaseWr <= '1';
                end if;
            end if;
        end if;
    end if;


end process;

-- synchronous process
-- Read and writte from/to memory when relasedWr/Rd = 1
synch_i : process(clk, rst, CE, releaseWr, releaseRd, DInReg, addrReg, XX_memReg)
begin
	if rst = '1' then
        XX_memReg <= (others => x"00000000");
        Dout <= x"00000000";
	elsif rising_edge(clk) then	
	   if CE = '1' then
	       if releaseWr = '1' then
	            XX_memReg(to_integer(to_unsigned(to_integer(signed(addrReg))/4,7))) <= DInReg;
	       elsif releaseRd = '1' then
                DOut <= XX_memReg(to_integer(to_unsigned(to_integer(signed(addrReg))/4,7)));
				
				case memSize is
					when "00" => 
						DOut(31 downto 8) <= (others => '0');
						DOut(7 downto 0) <= XX_memReg(to_integer(to_unsigned(to_integer(signed(addrReg))/4,7)))(7 downto 0);
						
					when "01" => 
						DOut(31 downto 16) <= (others => '0');
						DOut(15 downto 0) <= XX_memReg(to_integer(to_unsigned(to_integer(signed(addrReg))/4,7)))(15 downto 0);
						
					when others => null;
				end case;
           end if;
        end if;
     end if;
end process;


end RTL;
