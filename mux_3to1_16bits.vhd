----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:21:12 03/25/2019 
-- Design Name: 
-- Module Name:    mux_3to1_16bits - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux_3to1_16bits is
    Port ( Data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           Data2 : in  STD_LOGIC_VECTOR (15 downto 0);
           Data3 : in  STD_LOGIC_VECTOR (15 downto 0);
           sel : in  STD_LOGIC_VECTOR (1 downto 0);
           Output : out  STD_LOGIC_VECTOR (15 downto 0));
end mux_3to1_16bits;

architecture Behavioral of mux_3to1_16bits is

begin
	Output <= data1 when sel = "00" else
			  data2 when sel = "01" else
			  data3 when sel = "10" else
              (others=>'1');

end Behavioral;

