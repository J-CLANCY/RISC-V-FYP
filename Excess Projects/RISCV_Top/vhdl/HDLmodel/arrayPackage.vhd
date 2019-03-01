-- Package defining array type
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package arrayPackage is

type 	array8x4     is array (7  downto 0)   of std_logic_vector(3 downto 0);
type 	array8x8     is array (7  downto 0)   of std_logic_vector(7 downto 0);
type 	array32x16   is array (31  downto 0)  of std_logic_vector(15 downto 0);
type 	array128x16  is array (255  downto 0) of std_logic_vector(15 downto 0);
type 	array256x16  is array (255  downto 0) of std_logic_vector(15 downto 0);
type 	array200x16  is array (199  downto 0) of std_logic_vector(15 downto 0);
type 	array512x16  is array (511  downto 0) of std_logic_vector(15 downto 0);
type 	array1024x16 is array (1023 downto 0) of std_logic_vector(15 downto 0);

type 	array4x32    is array (3 downto 0)    of std_logic_vector(31 downto 0);
type 	array128x32  is array (127 downto 0)  of std_logic_vector(31 downto 0);
type 	array16x32   is array (15 downto 0)   of std_logic_vector(31 downto 0);

type 	array4x33    is array (3 downto 0)    of std_logic_vector(32 downto 0);

type    array8x17    is array (7  downto 0)   of std_logic_vector(16 downto 0);
type    array56x17   is array (55 downto 0)   of std_logic_vector(16 downto 0);
type    array32x17   is array (31 downto 0)   of std_logic_vector(16 downto 0);
type    array31x33   is array (30 downto 0)   of std_logic_vector(32 downto 0);


type    regType8x12  is array (7 downto 0)    of std_logic_vector(11 downto 0);

end 	arrayPackage;

package body arrayPackage is
end arrayPackage;