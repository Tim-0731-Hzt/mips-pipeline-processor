----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:42:56 03/25/2019 
-- Design Name: 
-- Module Name:    forward_unit - Behavioral 
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

entity forward_unit is
    Port ( ID_EX_Rs : in  STD_LOGIC_VECTOR (3 downto 0);
           ID_EX_Rt : in  STD_LOGIC_VECTOR (3 downto 0);
           EX_MEM_Rd : in  STD_LOGIC_VECTOR (3 downto 0);
           MEM_WB_Rd : in  STD_LOGIC_VECTOR (3 downto 0);
           EX_MEM_RegWrite : in  STD_LOGIC;
           MEM_WB_RegWrite : in  STD_LOGIC;
           ForwardA : out  STD_LOGIC_VECTOR (1 downto 0);
           ForwardB : out  STD_LOGIC_VECTOR (1 downto 0));
end forward_unit;

architecture Behavioral of forward_unit is

begin 
	--process(MEM_WB_RegWrite)
	--begin
	--if MEM_WB_RegWrite = '1' and Not(MEM_WB_Rd = "0000") and not(EX_MEM_RegWrite = '1' and not(EX_MEM_RD = "0000") and not(EX_MEM_Rd = ID_EX_Rs)) and (MEM_WB_Rd = ID_EX_Rs) then
	--	ForwardA	 <= "01";
		
	--elsif EX_MEM_RegWrite = '1'  and Not(EX_MEM_Rd = "0000") and not(MEM_WB_RegWrite = '1' and not(MEM_WB_RD = "0000") and not(MEM_WB_Rd = ID_EX_Rs)) and (EX_MEM_Rd = ID_EX_Rs) then
		--ForwardA	 <= "10";
	--else
		--ForwardA	 <= "00";
	--end if;
	--end process;
	
	--process(MEM_WB_RegWrite)
	--begin
	--if MEM_WB_RegWrite = '1' and Not(MEM_WB_Rd = "0000") and not(EX_MEM_RegWrite = '1' and not(EX_MEM_RD = "0000") and not(EX_MEM_Rd = ID_EX_Rt)) and (MEM_WB_Rd = ID_EX_Rt) then
		--ForwardB	 <= "01";
	--elsif EX_MEM_RegWrite = '1' and Not(MEM_WB_Rd = "0000") and not(MEM_WB_RegWrite ='1' and not(MEM_WB_RD = "0000") and not(MEM_WB_Rd = ID_EX_Rt)) and (EX_MEM_Rd = ID_EX_Rt) then
		--ForwardB <= "10";
	--else
		--ForwardB <= "00";
	--end if;
	--end process;
	Process(EX_MEM_RegWrite,EX_MEM_Rd,ID_EX_Rs,MEM_WB_RegWrite,MEM_WB_Rd)
	begin
		if EX_MEM_RegWrite = '1' and not (EX_MEM_Rd = "0000") and EX_MEM_Rd = ID_EX_Rs then
			forwardA <= "10";
		elsif MEM_WB_RegWrite = '1' and Not(MEM_WB_Rd = "0000") and (MEM_WB_Rd = ID_EX_Rs) then
			forwardA <= "01";
		else
			forwardA <= "00";
		end if;

	end process;

	Process(EX_MEM_RegWrite,EX_MEM_Rd,ID_EX_Rt,MEM_WB_RegWrite,MEM_WB_Rd)
	begin
		if EX_MEM_RegWrite = '1' and not (EX_MEM_Rd = "0000") and EX_MEM_Rd = ID_EX_Rt then
			forwardB <= "10";
		elsif MEM_WB_RegWrite = '1' and Not(MEM_WB_Rd = "0000") and (MEM_WB_Rd = ID_EX_Rt) then
			forwardB <= "01";
		else
			forwardB <= "00";
		end if;

	end process;
end Behavioral;

