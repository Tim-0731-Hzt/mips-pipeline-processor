---------------------------------------------------------------------------
-- single_cycle_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See single_cycle_core.pdf for the block diagram of this single
-- cycle processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity single_cycle_core is
    port ( reset  : in  std_logic;
           clk    : in  std_logic;
			  Result : out std_logic_vector(15 downto 0));
end single_cycle_core;

architecture structural of single_cycle_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           addr_out : out std_logic_vector(3 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end component;

component sign_extend_4to16 is
    port ( data_in  : in  std_logic_vector(3 downto 0);
           data_out : out std_logic_vector(15 downto 0) );
end component;
-----------------------------Muxes------------------------------
component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(3 downto 0);
           data_b     : in  std_logic_vector(3 downto 0);
           data_out   : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_16b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(15 downto 0);
           data_b     : in  std_logic_vector(15 downto 0);
           data_out   : out std_logic_vector(15 downto 0) );
end component;

component mux_3to1_16bits is
    Port ( Data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           Data2 : in  STD_LOGIC_VECTOR (15 downto 0);
           Data3 : in  STD_LOGIC_VECTOR (15 downto 0);
           sel : in  STD_LOGIC_VECTOR (1 downto 0);
           Output : out  STD_LOGIC_VECTOR (15 downto 0));
end component;
----------------------------------------------------------------------------
component control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic;
		   branch		 : out std_logic);
end component;

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector(3 downto 0);
           read_register_b : in  std_logic_vector(3 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(3 downto 0);
           write_data      : in  std_logic_vector(15 downto 0);
           read_data_a     : out std_logic_vector(15 downto 0);
           read_data_b     : out std_logic_vector(15 downto 0) );
end component;

component adder_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0);
           carry_out : out std_logic );
end component;

component adder_16b is
    port ( src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           sum       : out std_logic_vector(15 downto 0);
           carry_out : out std_logic );
end component;

component data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(3 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end component;

component is_equal is
    Port ( numA : in  STD_LOGIC_VECTOR (15 downto 0);
           numB : in  STD_LOGIC_VECTOR (15 downto 0);
           equal : out  STD_LOGIC);
end component;

------------------------------------------Pipeline register load -------------------------------------
component IF_ID_REG is
    Port ( 
			  CLK : in STD_LOGIC;
			  IF_ID_Write: in std_logic;
			  PC : in  STD_LOGIC_VECTOR (3 downto 0);
           Instruction : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg : out  STD_LOGIC_VECTOR (19 downto 0));
end component;

component ID_EX_REG is
    Port ( current_instruction: in STD_LOGIC_VECTOR(15 downto 0);
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
           ID_EX_REG_OUT : out  STD_LOGIC_VECTOR (66 downto 0)); --(50 downto 0);
end component;

component EX_MEM_REG is
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
end component;

component MEM_WB_REG is
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
end component;
----------------------------------------------------------------------------------------
component Hazard_Detection_Unit is
    Port ( ID_EX_MemRead : in  STD_LOGIC;
           PCWrite : out  STD_LOGIC;
           IF_ID_Write : out  STD_LOGIC;
           LD_Control_Signal : out  STD_LOGIC;
           ID_EX_Rt : in  STD_LOGIC_VECTOR (3 downto 0);
           IF_ID_Rs : in  STD_LOGIC_VECTOR (3 downto 0);
           IF_ID_Rt : in  STD_LOGIC_VECTOR (3 downto 0));
end component;

component forward_unit is
    Port ( ID_EX_Rs : in  STD_LOGIC_VECTOR (3 downto 0);
           ID_EX_Rt : in  STD_LOGIC_VECTOR (3 downto 0);
           EX_MEM_Rd : in  STD_LOGIC_VECTOR (3 downto 0);
           MEM_WB_Rd : in  STD_LOGIC_VECTOR (3 downto 0);
           EX_MEM_RegWrite : in  STD_LOGIC;
           MEM_WB_RegWrite : in  STD_LOGIC;
           ForwardA : out  STD_LOGIC_VECTOR (1 downto 0);
           ForwardB : out  STD_LOGIC_VECTOR (1 downto 0));
end component;


signal sig_next_pc              : std_logic_vector(3 downto 0);
signal sig_curr_pc              : std_logic_vector(3 downto 0);
signal sig_no_branch_pc			  : std_logic_vector(3 downto 0);
signal sig_one_4b               : std_logic_vector(3 downto 0);
signal sig_pc_carry_out         : std_logic;
signal sig_insn                 : std_logic_vector(15 downto 0);
signal sig_sign_extended_offset : std_logic_vector(15 downto 0);
signal sig_reg_dst              : std_logic;
signal sig_reg_write            : std_logic;
signal sig_alu_src              : std_logic;
signal sig_mem_write            : std_logic;
signal sig_mem_to_reg           : std_logic;
signal sig_write_register       : std_logic_vector(3 downto 0);
signal sig_write_data           : std_logic_vector(15 downto 0);
signal sig_read_data_a          : std_logic_vector(15 downto 0);
signal sig_read_data_b          : std_logic_vector(15 downto 0);

signal sig_alu_src_a_mux      : std_logic_vector(15 downto 0);
signal sig_alu_src_b_mux      : std_logic_vector(15 downto 0);


signal sig_alu_src_b            : std_logic_vector(15 downto 0);
signal sig_alu_result           : std_logic_vector(15 downto 0); 
signal sig_branch					  : std_logic;
signal sig_alu_carry_out        : std_logic;
signal sig_data_mem_out         : std_logic_vector(15 downto 0);
signal sig_equal					  : std_logic;
signal sig_branch_pc				  : std_logic_vector(3 downto 0);
signal sig_pc_select					: std_logic;

--- Pipeline registers --- 
signal pipeline_IF_ID				: std_logic_vector(19 downto 0);
signal pipeline_ID_EX				: std_logic_vector(66 downto 0);
signal pipeline_EX_MEM				: std_logic_vector(55 downto 0);
signal pipeline_MEM_WB				: std_logic_vector(54 downto 0);

--- Signal Forwarding ---
signal sig_forwardA: std_logic_vector(1 downto 0);
signal sig_forwardB: std_logic_vector(1 downto 0);
signal sig_forward_ex_mem_Rd: std_logic_vector(3 downto 0);
signal sig_forward_ID_EX_Rt: std_logic_vector(3 downto 0);
--- signal Hazard Detecting --- 
signal sig_PCWrite : STD_LOGIC;
signal sig_IF_ID_Write : STD_LOGIC;
signal sig_LD_Control_Signal :STD_LOGIC;
begin

    sig_one_4b <= "0001";
	 
	 
	 ---PC select: Branch PC or PC+ 4
	 pc_select_and: sig_pc_select<=not sig_equal AND sig_branch;
	 
	 mux_pc_select : mux_2to1_4b 
    port map ( mux_select 	=> sig_pc_select,
               data_a 		=>sig_no_branch_pc,
               data_b		=>sig_branch_pc,
               data_out		=>sig_next_pc );
					
	 -- PC------------
    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc );
					
	 -- PC + 1 -----------
    next_pc : adder_4b 
    port map ( src_a     => sig_curr_pc, 
               src_b     => sig_one_4b,
               sum       => sig_no_branch_pc,   
               carry_out => sig_pc_carry_out );
    
	 -- Instruction Memory ---
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_insn );
	 
	 ---Eextend sign ---
    sign_extend : sign_extend_4to16 
    port map ( data_in  => pipeline_IF_ID(3 downto 0),
               data_out => sig_sign_extended_offset );
	 
	 --- IF/ID Reg Load 
	 ----- pipeline_IF_ID(19 downto 16) -- PC
	 ----- pipeline_IF_ID(15 downto 0) -- Instruction 

	 IF_ID_REG_LOAD: IF_ID_REG
	 port map( 	CLK 			=> clk,
					IF_ID_Write => sig_IF_ID_Write,
					PC	 			=> sig_next_pc,
					Instruction => sig_insn,
					Reg			=> pipeline_IF_ID);
	 
	 --- Hazard detection unit ---
	 Hazard_detect_unit:  Hazard_Detection_Unit
    Port map ( 
			  ID_EX_MemRead => pipeline_ID_EX(50),
           PCWrite => sig_PCWrite,
           IF_ID_Write => sig_IF_ID_Write,
           LD_Control_Signal => sig_LD_Control_Signal,
           ID_EX_Rt => pipeline_ID_EX(7 downto 4),
           IF_ID_Rs => pipeline_IF_ID(11 downto 8),
           IF_ID_Rt => pipeline_IF_ID(7 downto 4));

	 --- Control-----------
    ctrl_unit : control_unit 
    port map ( opcode     => pipeline_IF_ID(15 downto 12),
               reg_dst    => sig_reg_dst,
               reg_write  => sig_reg_write,
               alu_src    => sig_alu_src,
               mem_write  => sig_mem_write,
               mem_to_reg => sig_mem_to_reg,
			   branch	  => sig_branch);
	 
	 
	 --- Mux before register file
    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => pipeline_MEM_WB(37),
               data_a     => pipeline_MEM_WB(46 downto 43),
               data_b     => pipeline_MEM_WB(3 downto 0),
               data_out   => sig_write_register );

    mux_reg_dst_EX_MEM: mux_2to1_4b
    port map ( mux_select => pipeline_EX_MEM(36),
               data_a     => pipeline_MEM_WB(47 downto 44),
               data_b     => pipeline_MEM_WB(3 downto 0),
               data_out   => sig_forward_ex_mem_Rd );
					
	mux_reg_dst_forward: mux_2to1_4b
    port map ( mux_select => sig_reg_dst,
               data_a     => pipeline_IF_ID(7 downto 4),
               data_b     => pipeline_IF_ID(3 downto 0),
               data_out   => sig_forward_ID_EX_Rt );
	 
	 --- Registers ------- 
    reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               read_register_a => pipeline_IF_ID(11 downto 8),
               read_register_b => pipeline_IF_ID(7 downto 4),
               write_enable    => pipeline_MEM_WB(36),
               write_register  => sig_write_register,
               write_data      => sig_write_data,
               read_data_a     => sig_read_data_a,
               read_data_b     => sig_read_data_b );
    
	 --- compare -------
	 compare: is_equal
	 port map ( numA => sig_read_data_a,
					numB => sig_read_data_b,
					equal => sig_equal); 
	 
	 
	 --- Mux between ALU and register file
    mux_alu_src : mux_2to1_16b 
    port map ( mux_select => sig_alu_src,
               data_a     => sig_read_data_b,
               data_b     => sig_sign_extended_offset,
               data_out   => sig_alu_src_b_mux );
	 
	 
	--- Branch adder ----------------				
	alu_branch: adder_4b
	port map (	src_a => pipeline_IF_ID(19 downto 16),
				src_b => pipeline_IF_ID(3 downto 0),
				sum	=>	 sig_branch_pc,
				carry_out => sig_alu_carry_out);
					
	--- ID_EX Register load----------
	--- pipeline_ID_EX(50) -- MemToReg
	--- pipeline_ID_EX(49) -- MemToWrite
	--- pipeline_ID_EX(48) -- ALUsrc
	--- pipeline_ID_EX(47) -- RegWrite
	--- pipeline_ID_EX(46) -- BneSignal
	--- pipeline_ID_EX(45) -- BneCmpSignal
	--- pipeline_ID_EX(44) -- RegDst
	--- pipeline_ID_EX(43 downto 28) -- Data1 signal a
	--- pipeline_ID_EX(27 downto 12) -- Data2 signal b
	--- pipeline_ID_EX(11 downto 8) -- Rs
	--- pipeline_ID_EX(7 downto 4) -- Rt
	--- pipeline_ID_EX(3 downto 0) -- Rd
	ID_EX_REG_LOAD: ID_EX_REG
	port map(
		Current_Instruction => pipeline_IF_ID(15 downto 0),
		LD_Control_Signal => sig_LD_Control_Signal,
		CLK 			=> clk,
		MemToReg 	=> sig_mem_to_reg,
		MemToWrite 	=> sig_mem_write,
		ALUsrc 		=> sig_alu_src,
		RegWrite 	=> sig_reg_write,
		BneSignal 	=> sig_branch,
		BneCmpSignal=> sig_equal,
		RegDst 		=> sig_reg_dst,
		Data1		=>	sig_read_data_a,
		Data2 		=> sig_alu_src_b_mux,
		Rs				=> pipeline_IF_ID(11 downto 8),
		Rt				=> pipeline_IF_ID(7 downto 4),
		Rd				=> pipeline_IF_ID(3 downto 0),
		ID_EX_REG_OUT => pipeline_ID_EX
	);
	
	
	 ----3 To 1 mux before ALU -------------
	 src_a_select: mux_3to1_16bits
	 port map(
		data1 => pipeline_ID_EX(43 downto 28),
		data2 => sig_write_data , 
		data3 => pipeline_EX_MEM(35 downto 20),
		sel	=> sig_forwardA,
		output => sig_alu_src_a_mux
	 );
	 
	 src_b_select: mux_3to1_16bits
	 port map(
		data1 => pipeline_ID_EX(27 downto 12),
		data2 => sig_write_data , 
		data3 => pipeline_EX_MEM(35 downto 20),
		sel	=> sig_forwardB,
		output => sig_alu_src_b
	 );
	 
	 ----ALU ----------
    alu : adder_16b 
    port map ( src_a     => sig_alu_src_a_mux,
               src_b     => sig_alu_src_b,
               sum       => sig_alu_result,
               carry_out => sig_alu_carry_out );
	
	-------Ex/MEM Register Load--------	
	-- pipeline_EX_MEM(39) -- MemToReg
	-- pipeline_EX_MEM(38) -- MemWrite
	-- pipeline_EX_MEM(37) -- RegWrite
	-- pipeline_EX_MEM(36) -- RegDst
	-- pipeline_EX_MEM(35 downto 20) -- Result
	-- pipeline_EX_MEM(19 downto 4) -- Data2
	-- pipeline_EX_MEM(3 downto 0) -- Imm
	Ex_MEM_REG_LOAD: 	EX_MEM_REG
	port map(
		Current_Instruction => pipeline_ID_EX(66 downto 51),
		CLK 			=> clk,
		MemToReg 	=> pipeline_ID_EX(50),
		MemWrite 	=> pipeline_ID_EX(49),
		RegWrite 	=> pipeline_ID_EX(47),
		RegDst 		=> pipeline_ID_EX(44),
		Result		=> sig_alu_result,
		Data2			=> sig_alu_src_b,
		Imm			=> pipeline_ID_EX(3 downto 0),
		EX_MEM_REG_OUT => pipeline_EX_MEM
	);
    
	 ----- Data Memory-------------
    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => pipeline_EX_MEM(38),
               write_data   => pipeline_EX_MEM(19 downto 4),
               addr_in      => pipeline_EX_MEM(23 downto 20),
               data_out     => sig_data_mem_out );
	
	-------MEM/WB Register Load--------	
   --- pipeline_MEM_WB(38) -- MemToReg
	--- pipeline_MEM_WB(37) -- RegDst
	--- pipeline_MEM_WB(36) -- RegWrite
	--- pipeline_MEM_WB(35 downto 20) -- Address
	--- pipeline_MEM_WB(19 downto 4) -- ReadData
	--- pipeline_MEM_WB(3 downto 0) -- Imm      
	MEM_WB_REG_LOAD: 	MEM_WB_REG
		port map(
			Current_Instruction => pipeline_EX_MEM(55 downto 40),
			CLK 			=> clk, 
			MemToReg 	=> pipeline_EX_MEM(39),
			RegWrite 	=> pipeline_EX_MEM(37),
			RegDst 		=> pipeline_EX_MEM(36),
			Address		=> pipeline_EX_MEM(35 downto 20),
			ReadData	=> sig_data_mem_out,
			Imm			=> pipeline_EX_MEM(3 downto 0),
			MEM_WB_REG_OUT => pipeline_MEM_WB
	);
	 ---- Mux after MEM/WB Register-----------
    mux_mem_to_reg : mux_2to1_16b 
    port map ( mux_select => pipeline_MEM_WB(38),
               data_a     => pipeline_MEM_WB(35 downto 20),
               data_b     => pipeline_MEM_WB(19 downto 4),
               data_out   => sig_write_data );
					
	 ---	Forwarding unit --------------
	 for_unit: forward_unit
    Port map( 
		   ID_EX_Rs 			=> pipeline_ID_EX(11 downto 8),
           ID_EX_Rt 			=>pipeline_ID_EX(7 downto 4),
           EX_MEM_Rd 		=> sig_forward_ex_mem_Rd,
           MEM_WB_Rd 		=> sig_write_register,
           EX_MEM_RegWrite => pipeline_EX_MEM(37),
           MEM_WB_RegWrite => pipeline_MEM_WB(36),
           ForwardA			=> sig_forwardA,
           ForwardB			=> sig_forwardB
		);
		output: result <= sig_write_data;
end structural;
