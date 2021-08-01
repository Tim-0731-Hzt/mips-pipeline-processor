----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:51:12 03/18/2019 
-- Design Name: 
-- Module Name:    is_equal - Behavioral 
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
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity is_equal is
    Port ( numA : in  STD_LOGIC_VECTOR (15 downto 0);
           numB : in  STD_LOGIC_VECTOR (15 downto 0);
           equal : out  STD_LOGIC);
end is_equal;

architecture Behavioral of is_equal is

begin
	equal <= '1' when numA = numB
					 else '0';


end Behavioral;

