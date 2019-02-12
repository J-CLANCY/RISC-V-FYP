library ieee;
use ieee.std_logic_1164.all;

entity tb_data_memory is
end tb_data_memory;

architecture tb of tb_data_memory is

    component data_memory
        port (clka      : in std_logic;
              rsta      : in std_logic;
              ena       : in std_logic;
              wea       : in std_logic_vector (3 downto 0);
              addra     : in std_logic_vector (31 downto 0);
              dina      : in std_logic_vector (31 downto 0);
              douta     : out std_logic_vector (31 downto 0);
              rsta_busy : out std_logic);
    end component;

    signal clka      : std_logic;
    signal rsta      : std_logic;
    signal ena       : std_logic;
    signal wea       : std_logic_vector (3 downto 0);
    signal addra     : std_logic_vector (31 downto 0);
    signal dina      : std_logic_vector (31 downto 0);
    signal douta     : std_logic_vector (31 downto 0);
    signal rsta_busy : std_logic;

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : data_memory
    port map (clka      => clka,
              rsta      => rsta,
              ena       => ena,
              wea       => wea,
              addra     => addra,
              dina      => dina,
              douta     => douta,
              rsta_busy => rsta_busy);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clka is really your main clock signal
    clka <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        ena <= '0';
        wea <= (others => '0');
        addra <= (others => '0');
        dina <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rsta is really your reset signal
        rsta <= '1';
        wait for 100 ns;
        rsta <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
