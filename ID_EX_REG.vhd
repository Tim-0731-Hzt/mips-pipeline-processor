
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--- ID_EX_REG_OUT(66 downto 51) -- CurrentInstruction
--- ID_EX_REG_OUT(50) -- MemToReg
--- ID_EX_REG_OUT(49) -- MemToWrite
--- ID_EX_REG_OUT(48) -- ALUsrc
--- ID_EX_REG_OUT(47) -- RegWrite
--- ID_EX_REG_OUT(46) -- BneSignal
--- ID_EX_REG_OUT(45) -- BneCmpSignal
--- ID_EX_REG_OUT(44) -- RegDst
--- ID_EX_REG_OUT(43 downto 28) -- Data1
--- ID_EX_REG_OUT(27 downto 12) -- Data2
--- ID_EX_REG_OUT(11 downto 8) -- Rs
--- ID_EX_REG_OUT(7 downto 4) -- Rt
--- ID_EX_REG_OUT(3 downto 0) -- Rd
entity ID_EX_REG is
    Port ( 
			  current_instruction: in STD_LOGIC_VECTOR(15 downto 0);
				-- 7 control signals
			  CLK:		in std_logic;
			  LD_Control_Signal: in std_logic;
			  MemToReg : in  STD_LOGIC;
           MemToWrite : in  STD_LOGIC;
           ALUsrc : in  STD_LOGIC;
           RegWrite : in  STD_LOGIC;
			  BneSignal: in STD_LOGIC;
			  BneCmpSignal: in STD_LOGIC;
           RegDst : in  STD_LOGIC;
			  -- 2 input data
           Data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           Data2 : in  STD_LOGIC_VECTOR (15 downto 0);
			  --3 register addresses
			  Rs	  : in  STD_LOGIC_VECTOR (3 downto 0);
			  Rt	  : in  STD_LOGIC_VECTOR (3 downto 0);
			  Rd	  : in STD_LOGIC_VECTOR  (3 downto 0);
			  -- stage register
           ID_EX_REG_OUT : out  STD_LOGIC_VECTOR (66 downto 0));
end ID_EX_REG;

architecture Behavioral of ID_EX_REG is

begin
	Process(clk)
	begin
		if clk'event and clk = '1' then
			if LD_Control_Signal = '1' then
				ID_EX_REG_OUT <= current_instruction & MemToReg & MemToWrite & ALUsrc & RegWrite & BneSignal & BneCmpSignal & RegDst & Data1 & Data2 & Rs & Rt &Rd;
			else
				ID_EX_REG_OUT <= current_instruction & '0' & '0' & '0' & '0' & '0' & '0' & '0' & Data1 & Data2 & Rs & Rt &Rd;
			end if;
		end if;
	end process;

end Behavioral;

