
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- EX_MEM_REG_OUT(39) -- MemToReg
-- EX_MEM_REG_OUT(38) -- MemWrite
-- EX_MEM_REG_OUT(37) -- RegWrite
-- EX_MEM_REG_OUT(36) -- RegDst
-- EX_MEM_REG_OUT(35 downto 20) -- Result
-- EX_MEM_REG_OUT(19 downto 4) -- Data2
-- EX_MEM_REG_OUT(3 downto 0) -- Imm

entity EX_MEM_REG is
    Port ( 
			  current_instruction: in STD_LOGIC_VECTOR(15 downto 0);
			  CLK: in std_logic;
			  MemToReg : in  STD_LOGIC;
           MemWrite : in  STD_LOGIC;
           RegWrite : in  STD_LOGIC;
           RegDst : in  STD_LOGIC;
           Result : in  STD_LOGIC_VECTOR (15 downto 0);
           Data2 : in  STD_LOGIC_VECTOR (15 downto 0);
           Imm : in  STD_LOGIC_VECTOR (3 downto 0);
           EX_MEM_REG_OUT : out  STD_LOGIC_VECTOR (55 downto 0)); --(39 downto 0);
end EX_MEM_REG;

architecture Behavioral of EX_MEM_REG is

begin
	process(clk)
	begin
		If clk'event and clk = '1' then
			EX_MEM_REG_OUT <= current_instruction & MemToReg & MemWrite & RegWrite & RegDst & Result & Data2 & Imm;			
		End if;
	end process;
end Behavioral;

