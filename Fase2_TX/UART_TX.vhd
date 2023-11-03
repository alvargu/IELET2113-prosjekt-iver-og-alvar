library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is 
	generic (
		constant f_clk: integer := 50_000_000;
		constant BAUD_RATE: integer := 9600;
		constant time_led_on: integer := 50; /* 50 ms */
		);
	port (
		tx_sig : in std_logic;
		clk: in std_logic;
		tx_busy_led: out std_logic;
		ascii_display: out std_logic_vector(7 downto 0)
		);
end entity;		

		
architecture rtl of uart_tx is 
-------------------------------------------------------------------------------
-- Define internal signals of circuit
-------------------------------------------------------------------------------
-- clk signals
	signal baud_clk 		: std_logic := '1';
	signal o_smp_clk 		: std_logic := '1';
-- hold signals
	signal tx_n_rdy		: std_logic := '0';
-- data signals
	signal tx_bit 			: std_logic := '1';
	signal show_num 		: std_logic_vector(7 downto 0);
	-- signal ascii_display 	: std_logic_vector(7 downto 0);
	
---------------------------------------------------------------------------------------------------------
-- Define functions of circuit
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
	-- Use system clock to generate oversampling clock and clk for baud rate.
	-------------------------------------------------------------------------
	p_clock_division: process(clk)
		constant o_smp_factor: integer := f_clk/(baud_rate * o_smp_bits);
		variable o_smp_clk_cnt: integer := 0;
		variable baud_clk_cnt: integer := 0;
	begin
		if rising_edge(clk) then
			o_smp_clk_cnt := o_smp_clk_cnt + 1;
			if (o_smp_clk_cnt >= o_smp_factor / 2) then 	-- Man deler på to fordi man endrer klokka etter en
				o_smp_clk_cnt := 0;					-- periode, men man jo endre to ganger i løpe av en
				o_smp_clk <= not o_smp_clk;			-- periode for å skape en puls.
				
				BAUD_clk_cnt := BAUD_clk_cnt + 1; 
				if (BAUD_clk_cnt >= o_smp_bits) then 	-- Baud rate clk sjekkes her for å effektivisere 
					BAUD_clk_cnt := 0; 				-- programmet. Man unngår å sjekke hver eneste gang.
					BAUD_clk <= not BAUD_clk;
				end if;
			end if;
		end if;	
	end process;
	
	-------------------------------------------------------------------------
	-- Seperates data bits from stop and start bits
	-------------------------------------------------------------------------
	p_data_tx : process(baud_clk, rx_bit)
		type t_state is (n_data, r_data);
		variable state 		: t_state := n_data;
		variable cnt_data 	: integer := 0;
		variable v_rx_data 	: std_logic_vector(7 downto 0) := "00000000";
	begin
		if rising_edge(baud_clk) then
			case state is 
				when n_data =>
					if tx_bit = '0' then 
						state := r_data;
						tx_n_rdy <= '1';
					elsif tx_bit = '1' then 
						state := n_data;
					end if;
				when t_data =>
					if cnt_data < 8 then
						v_tx_data(7 - cnt_data) := tx_bit;
						cnt_data := cnt_data + 1;
						state := r_data;
					end if;
					if cnt_data >= 8 then
						state := n_data;
						show_num <= v_tx_data; 
						cnt_data := 0;
						tx_n_rdy <= '0';
					end if;						
			end case;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- 
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- 
	-------------------------------------------------------------------------
	p_indicate_tx : process (rx_n_rdy)
		variable tx_led_cnt : integer;
		variable tx_led_on : std_logic := '0';
	begin
		if rising_edge(tx_n_rdy) then 
			tx_led_on := '1';
		end if;
		if tx_led_on = '1' then
			if rising_edge(clk) then
				tx_led_cnt := tx_led_cnt + 1;
				tx_busy_led <= '1';
				if tx_led_cnt >= time_led_on /* 50 ms */ then 
					tx_led_cnt := 0;
					tx_busy_led <= '0';
				end if;
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- 
	-------------------------------------------------------------------------
	
	-- seg_ut <= ascii_display;
end architecture;
