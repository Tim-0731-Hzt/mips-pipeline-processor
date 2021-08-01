library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- REG(19 downto 16) -- PC
-- REG(15 downto 0) -- Instruction 

entity IF_ID_REG is
    Port ( 
			  CLK : in STD_LOGIC;
			  IF_ID_Write: in STD_LOGIC;
			  PC : in  STD_LOGIC_VECTOR (3 downto 0);
           Instruction : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg : out  STD_LOGIC_VECTOR (19 downto 0));
end IF_ID_REG;

architecture Behavioral of IF_ID_REG is
begin
	process(clk,IF_ID_Write)
	begin
		if clk'event and clk = '1' then
			if IF_ID_Write = '1' then
				Reg <= PC & Instruction;
			else
				Reg <= (others=>'0');
			end if;
		end if;
	end process;
end Behavioral;

