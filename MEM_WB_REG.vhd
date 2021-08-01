
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--- MEM_WB_REG_OUT(38) -- MemToReg
--- MEM_WB_REG_OUT(37) -- RegDst
--- MEM_WB_REG_OUT(36) -- RegWrite
--- MEM_WB_REG_OUT(35 downto 20) -- Address
--- MEM_WB_REG_OUT(19 downto 4) -- ReadData
--- MEM_WB_REG_OUT(3 downto 0) -- Imm
entity MEM_WB_REG is
    Port ( 
			  Current_Instruction: in std_logic_vector(15 downto 0);

			  CLK: in STD_LOGIC;
			  MemToReg : in  STD_LOGIC;
           RegDst : in  STD_LOGIC;
           RegWrite : in  STD_LOGIC;
           Address : in  STD_LOGIC_VECTOR (15 downto 0);
           ReadData : in  STD_LOGIC_VECTOR (15 downto 0);
           Imm : in  STD_LOGIC_VECTOR (3 downto 0);
           MEM_WB_REG_OUT : out  STD_LOGIC_VECTOR (54 downto 0)); -- (38 downto 0);
end MEM_WB_REG;

architecture Behavioral of MEM_WB_REG is

begin
		Process(clk)
		begin
			If clk'event and clk = '1' then
				MEM_WB_REG_OUT <= Current_Instruction & MemToReg & RegDst & RegWrite & Address & ReadData & Imm;
			end if;	
		end process;
end Behavioral;

