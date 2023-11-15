library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is 
	generic (
		constant f_clk: integer := 50_000_000;
		constant BAUD_RATE: integer := 9600;
		constant time_led_on: integer := 50; /* 50 ms */
		constant o_smp_bits: integer := 8
		);
	port (
		RX_sig : in std_logic;
		clk: in std_logic;
		rx_busy_led: out std_logic;
		ascii_display: out std_logic_vector(7 downto 0)
		);
end entity;		

		
architecture rtl of uart_rx is 
-------------------------------------------------------------------------------
-- Define internal signals of circuit
-------------------------------------------------------------------------------
-- clk signals
	signal baud_clk 		: std_logic := '1';
	signal o_smp_clk 		: std_logic := '1';
-- hold signals
	signal rx_n_rdy		: std_logic := '0';
-- data signals
	signal rx_bit 			: std_logic := '1';
	signal show_num 		: std_logic_vector(7 downto 0);
	-- signal ascii_display 	: std_logic_vector(7 downto 0);
-------------------------------------------------------------------------------
###############################################################################
-------------------------------------------------------------------------------
	
---------------------------------------------------------------------------------------------------------
-- Define functions of circuit
---------------------------------------------------------------------------------------------------------
	pure function majority_check(check_vector : std_logic_vector := "0000000") return std_logic is
		variable majority_val : std_logic;
		variable count_ones : integer := 0;
	begin
		/* Count number of ones in the vector */
		if check_vector(0) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(1) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(2) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(3) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(4) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(5) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(6) = '1' then count_ones := count_ones + 1;
		end if;
		/* Return std_logic value 1 when most of the bits are 1 and 0 otherwise */
		if count_ones > 3 then majority_val := '1';
		else majority_val := '0';
		end if;
		return majority_val;
	end function;
---------------------------------------------------------------------------------------------------------
#########################################################################################################
---------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
	
	--------------------------------------------------------------------------
	-- Code to handle segment display
	--------------------------------------------------------------------------
	with show_num select
	ascii_display <= "11111001" when "00110001", -- 1
				"10100100" when "00110010", -- 2
				"10110000" when "00110011", -- 3
				"10011001" when "00110100", -- 4
				"10010010" when "00110101", -- 5
				"10000010" when "00110110", -- 6
				"11111000" when "00110111", -- 7
				"10000000" when "00111000", -- 8
				"10010000" when "00111001", -- 9
				"10001000" when "01000001", -- A
				"10000011" when "01000010", -- B
				"11000110" when "01000011", -- C
				"10000000" when "01000100", -- D
				"10000110" when "01000101", -- E
				"10001110" when "01000110", -- F
				"11000000" when others; -- 0
	/*
	ascii_display <= "11111001" when show_num = "00110001" else
				"10100100" when show_num = "00110010" else
				"10110000" when show_num = "00110011" else
				"10011001" when show_num = "00110100" else
				"10010010" when show_num = "00110101" else
				"10000010" when show_num = "00110110" else
				"11111000" when show_num = "00110111" else
				"10000000" when show_num = "00111000" else
				"10010000" when show_num = "00111001" else
				"10001000" when show_num = "01000001" else
				"10000011" when show_num = "01000010" else
				"11000110" when show_num = "01000011" else
				"10000000" when show_num = "01000100" else
				"10000110" when show_num = "01000101" else
				"10001110" when show_num = "01000110" else
				"00110000";
	*/
	-------------------------------------------------------------------------
	#########################################################################
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
	-- Use system clock to generate oversampling clock and clk for baud rate.
	-------------------------------------------------------------------------
	p_clock_division: process(clk)
		constant o_smp_factor: integer := f_clk/(baud_rate * o_smp_bits);
		variable o_smp_clk_cnt: integer := 0;
		variable baud_clk_cnt: integer := 0;
	begin
		if rising_edge(clk) then
			o_smp_clk_cnt := o_smp_clk_cnt + 1;
			if (o_smp_clk_cnt >= o_smp_factor / 2) then 	-- Dividing by two because one
				o_smp_clk_cnt := 0;					-- have to change the signal twice within a 
				o_smp_clk <= not o_smp_clk;			-- period to make a pulse.
				
				BAUD_clk_cnt := BAUD_clk_cnt + 1; 
				if (BAUD_clk_cnt >= o_smp_bits) then 	-- Baud rate clk ia checked here for effiency.
					BAUD_clk_cnt := 0; 				-- Avoids checking every single time.
					BAUD_clk <= not BAUD_clk;
				end if;
			end if;
		end if;	
	end process;
	-------------------------------------------------------------------------
	#########################################################################
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- Seperates data bits from stop and start bits
	-------------------------------------------------------------------------
	p_data_sep_sm : process(baud_clk, rx_bit)
		type t_state is (n_data, r_data);
		variable state 		: t_state := n_data;
		variable cnt_data 	: integer := 0;
		variable v_rx_data 	: std_logic_vector(7 downto 0) := "00000000";
	begin
		if rising_edge(baud_clk) then
			case state is	-- State machine in RX. Purpose is to seperate data bits
				when n_data => -- from stop and start bit. The functionality
					if rx_bit = '0' then	-- also gatherts the bits into one
						state := r_data;	-- vector and sends it to the output.
						rx_n_rdy <= '1';
					elsif rx_bit = '1' then 
						state := n_data;
					end if;
				when r_data =>
					if cnt_data < 8 then
						v_rx_data(7 - cnt_data) := rx_bit;
						cnt_data := cnt_data + 1;
						state := r_data;
					end if;
					if cnt_data >= 8 then
						state := n_data;
						show_num <= v_rx_data; 
						cnt_data := 0;
						rx_n_rdy <= '0';
					end if;						
			end case;
		end if;
	end process;
	-------------------------------------------------------------------------
	#########################################################################
	-------------------------------------------------------------------------
	
	--------------------------------------------------------------------------
	-- Process for reading RX_sig preforming 8 times oversampling and using 
	-- the 7 rightmost readings to decide value of the recieved bit.
	--------------------------------------------------------------------------
	p_read_bit_val :process (o_smp_clk, rx_sig)
		variable o_smp_cnt 		: integer range 0 to 8 := 0;
		variable rx_o_smp		: std_logic_vector(6 downto 0);
	begin
		if rising_edge(o_smp_clk) then 
					if o_smp_cnt > 0 then 
				RX_o_smp := RX_o_smp(5 downto 0) & RX_sig;
				if o_smp_cnt = 7 then 
					RX_bit <= majority_check(RX_o_smp);
				end if;
			end if;
			o_smp_cnt := o_smp_cnt + 1;
			if o_smp_cnt >= 8 then 	-- Since we check after the counter has increased
				o_smp_cnt := 0;	-- we havce to increase the condition with one too.
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- ######################################################################
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- Purpose of process is to manage the indicating signals.
	-------------------------------------------------------------------------
	p_indicate_rx : process (rx_n_rdy)
		variable rx_led_cnt : integer;
		variable rx_led_on : std_logic := '0';
	begin
		if rising_edge(rx_n_rdy) then 
			rx_led_on := '1';
		end if;
		if rx_led_on = '1' then
			if rising_edge(clk) then
				rx_led_cnt := rx_led_cnt + 1;
				rx_busy_led <= '1';
				if rx_led_cnt >= time_led_on /* 50 ms */ then 
					rx_led_cnt := 0;
					rx_busy_led <= '0';
				end if;
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- ######################################################################
	-------------------------------------------------------------------------
	
	-- seg_ut <= ascii_display;
end architecture;
