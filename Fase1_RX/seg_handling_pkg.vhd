


---------------------------------------------------------------------------------------------------------
-- function that takes inn a logic vector of a number and outputs  chosen number
---------------------------------------------------------------------------------------------------------
function seg_display_num (signal show_num    	: in std_logic_vector; 
								  signal hex_display 	: out std_logic_vector) is 
	constant hex_show_0: std_logic_vector(7 downto 0) := "11000000";
	constant hex_show_1: std_logic_vector(7 downto 0) := "11111001";
	constant hex_show_2: std_logic_vector(7 downto 0) := "10100100";
	constant hex_show_3: std_logic_vector(7 downto 0) := "10110000";
	constant hex_show_4: std_logic_vector(7 downto 0) := "10011001";
	constant hex_show_5: std_logic_vector(7 downto 0) := "10010010";
	constant hex_show_6: std_logic_vector(7 downto 0) := "10000010";
	constant hex_show_7: std_logic_vector(7 downto 0) := "11111000";
	constant hex_show_8: std_logic_vector(7 downto 0) := "10000000";
	constant hex_show_9: std_logic_vector(7 downto 0) := "10010000";
	constant hex_show_A: std_logic_vector(7 downto 0) := "10010000";
	constant hex_show_B: std_logic_vector(7 downto 0) := "10010000";
	constant hex_show_C: std_logic_vector(7 downto 0) := "10010000";
	constant hex_show_D: std_logic_vector(7 downto 0) := "10010000";
	constant hex_show_E: std_logic_vector(7 downto 0) := "10010000";
	constant hex_show_F: std_logic_vector(7 downto 0) := "10010000";
begin
	if 	show_num = "00000000" 	then 	hex_display <= hex_show_0; -- 0
	elsif show_num = "00000001" 	then 	hex_display <= hex_show_1; -- 1
	elsif show_num = "00000010" 	then 	hex_display <= hex_show_2; -- 2
	elsif show_num = "00000011" 	then	hex_display <= hex_show_3; -- 3
	elsif show_num = "00000100" 	then	hex_display <= hex_show_4; -- 4
	elsif show_num = "00000101" 	then	hex_display <= hex_show_5; -- 5
	elsif show_num = "00000110" 	then	hex_display <= hex_show_6; -- 6
	elsif show_num = "00000111" 	then	hex_display <= hex_show_7; -- 7
	elsif show_num = "00001000" 	then	hex_display <= hex_show_8; -- 8
	elsif show_num = "00001001"	then	hex_display <= hex_show_9; -- 9
	elsif show_num = "00000000"	then	hex_display <= hex_show_A; -- A
	elsif show_num = "00000000"	then	hex_display <= hex_show_B; -- B
	elsif show_num = "00000000"	then	hex_display <= hex_show_C; -- C
	elsif show_num = "00000000"	then	hex_display <= hex_show_D; -- D
	elsif show_num = "00000000"	then	hex_display <= hex_show_E; -- E
	else 											hex_display <= hex_show_F; -- F
	end if;
	return hex_display;
end procedure;
-------------------------------------------------------------------------
-- ######################################################################
-------------------------------------------------------------------------	