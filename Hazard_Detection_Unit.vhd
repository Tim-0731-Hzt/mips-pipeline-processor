----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:47 03/25/2019 
-- Design Name: 
-- Module Name:    Hazard_Detection_Unit - Behavioral 
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

entity Hazard_Detection_Unit is
    Port ( ID_EX_MemRead : in  STD_LOGIC;
           PCWrite : out  STD_LOGIC;
           IF_ID_Write : out  STD_LOGIC;
           LD_Control_Signal : out  STD_LOGIC;
           ID_EX_Rt : in  STD_LOGIC_VECTOR (3 downto 0);
           IF_ID_Rs : in  STD_LOGIC_VECTOR (3 downto 0);
           IF_ID_Rt : in  STD_LOGIC_VECTOR (3 downto 0));
end Hazard_Detection_Unit;

architecture Behavioral of Hazard_Detection_Unit is

begin

	process(ID_EX_MemRead,ID_EX_Rt,IF_ID_Rs,IF_ID_Rt)
	begin
		If (ID_EX_MemRead = '1') and ((ID_EX_Rt = IF_ID_Rs) or (ID_EX_Rt = IF_ID_Rt)) then
			PCWrite <= '0';
			IF_ID_Write <= '0';
			LD_Control_Signal <= '0';
		else
			PCWrite <= '1';
			IF_ID_Write <= '1';
			LD_Control_Signal <= '1';		
		end if;
	end process;
end Behavioral;

