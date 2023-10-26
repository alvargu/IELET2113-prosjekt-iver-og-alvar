library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RX is 
	generic (
		BAUD_RATE 
		);
	port (
		RX_sig : in std_logic;
		
		);
		
		
		
architecture rtl of UART_RX is 
---------------------------------------------------------------------------------------------------------
-- Define internal signals of circuit
---------------------------------------------------------------------------------------------------------
-- clk signals
	signal BAUD_clk 		: std_logic := '0';
	signal o_smp_clk 		: std_logic := '0';
-- counter signals
	
-- data signals
	signal RX_bit 		: std_logic := '1';
	-- signal RX_bit_rdy : std_logic := '0';
	signal RX_o_smp	: std_logic_vector(6 downto 0);
	signal v_RX_data 	: std_logic_vector(7 downto 0);
	
---------------------------------------------------------------------------------------------------------
-- Define functions of circuit
---------------------------------------------------------------------------------------------------------
	pure function majority_check(check_vector : std_logic_vector := "0000000") return std_logic is;
		variable majority_val : std_logic;
		variable count_ones : integer := 0;
	begin
		if 	check_vector(0) = '1' then count_ones := count_ones + 1;
		elsif check_vector(1) = '1' then count_ones := count_ones + 1;
		elsif check_vector(2) = '1' then count_ones := count_ones + 1;
		elsif check_vector(3) = '1' then count_ones := count_ones + 1;
		elsif check_vector(4) = '1' then count_ones := count_ones + 1;
		elsif check_vector(5) = '1' then count_ones := count_ones + 1;
		elsif check_vector(6) = '1' then count_ones := count_ones + 1;
		end if;
		if count_ones > 3 then majority_val := '1';
		else majority_val := '0';
		end if;
		return majority_val;
	end function;
	
begin
	p_seg_handler : process ()
		
		
	end process;
	
	p_BAUD_clk : process ()
		
		begin
		
	end process;
		
	p_oversampling_clk : process ()
		
		begin
		
	end process;
		
	p_data_seperation_SM : process ()
		
		begin
		
	end process;
		
	p_receiving_LED : process ()
		
		begin
		
	end process;
	---------------------------------------------------------------------------------------------------------
	-- Process for reading RX_sig preforming 8 times oversampling and using 
	-- the 7 rightmost readings to decide value of the recieved bit.
	---------------------------------------------------------------------------------------------------------
	p_read_bit_val :process (RX_bit, RX_o_smp)
		variable o_smp_cnt : integer range 0 to 8;
	begin
		if rising_edge(o_smp_clk) then 
			if o_smp_cnt > 0 then 
				shift_left(RX_o_smp, 1);
				RX_o_smp(0) <= RX_sig;
				if o_smp_cnt = 7 then 
					RX_bit <= majority_check(RX_o_smp);
				end if;
			end if;
			o_smp_cnt := o_smp_cnt + 1;
			if o_smp_cnt >= 8 then 
				o_smp_cnt := 0;
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- ######################################################################
	-------------------------------------------------------------------------
end architecture;
		