library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is 
	generic (
		constant f_clk: integer := 50_000_000;
		constant baud_rate: integer := 9600;
		constant time_led_on: integer := 50 /* 50 ms */
		);
	port (
		tx_byte: in std_logic_vector(7 downto 0);
		clk: in std_logic;
		tx_on: in std_logic;
		tx : out std_logic;
		tx_busy: out std_logic
		-- ascii_display: out std_logic_vector(7 downto 0)
		);
end entity;		

		
architecture rtl of uart_tx is 
-------------------------------------------------------------------------------
-- Define internal signals of circuit
-------------------------------------------------------------------------------
-- clk signals
	signal baud_clk 	: std_logic := '1';
-- hold signals
	signal tx_rdy		: std_logic := '0';
-- data signals
	
	
-------------------------------------------------------------------------------
-- Define functions of circuit
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
	-------------------------------------------------------------------------
	-- Use system clock to generate oversampling clock and clk for baud rate.
	-------------------------------------------------------------------------
	p_baud_clk: process(clk)
		constant baud_factor : integer := f_clk/baud_rate;
		variable baud_clk_cnt: integer := 0;
	begin
		if rising_edge(clk) then
		baud_clk_cnt := baud_clk_cnt + 1; 
			if (baud_clk_cnt >= baud_factor / 2) then 	-- baud rate clk sjekkes her for å effektivisere 
				baud_clk_cnt := 0; 				-- programmet. Man unngår å sjekke hver eneste gang.
				baud_clk <= not baud_clk;
			end if;
		end if;	
	end process;
	-------------------------------------------------------------------------
	-- ######################################################################
	-------------------------------------------------------------------------

	-------------------------------------------------------------------------
	-- Seperates data bits from stop and start bits
	-------------------------------------------------------------------------
	p_data_tx : process(baud_clk, tx_byte, tx_on)
		type t_state is (no_tx, t_start, t_byte, t_stop);
		variable state 	: t_state := no_tx;
		variable cnt_data 	: integer := 0;
		variable tx_bit 	: std_logic := '1';
	begin
		if rising_edge(baud_clk) then
			case state is 
				when no_tx =>
					if tx_on = '0' then 
						state := no_tx;
						tx_rdy <= '0';
					elsif tx_on = '1' then 
						state := t_start;
					end if;
				when t_start =>
					if tx_bit = '0' then 
						state := t_start;
						tx_rdy <= '0';
					elsif tx_bit = '1' then 
						if tx_on = '0' then 
							state := no_tx;
							tx_rdy <= '0';
						elsif tx_on = '1' then 
							state := t_start;
						end if;
					end if;
				when t_byte =>
					if cnt_data < 8 then
						tx_bit := tx_byte(7 - cnt_data);

						cnt_data := cnt_data + 1;
						state := t_byte;
					end if;
					if cnt_data >= 8 then
						state := t_stop;
						cnt_data := 0;
						tx_rdy <= '1';
					end if;
					tx <= tx_bit;
				when t_stop =>
					tx <= '1';
					state := no_tx;						
			end case;
		end if;
	end process;
	/* 
	p_data_tx : process(baud_clk, tx_byte, tx_on)
		type t_state is (no_tx, t_start, t_byte, t_stop);
		variable state 	: t_state := no_tx;
		variable cnt_data 	: integer := 0;
		variable tx_bit 	: std_logic := '1';
	begin
		if rising_edge(baud_clk) then
			case state is 
				when no_tx =>
					if tx_on = '0' then 
						state := no_tx;
						tx_rdy <= '0';
					elsif tx_on = '1' then 
						state := t_start;
					end if;
				when t_start =>
					if tx_bit = '0' then 
						state := t_start;
						tx_rdy <= '0';
					elsif tx_bit = '1' then 
						if tx_on = '0' then 
							state := no_tx;
							tx_rdy <= '0';
						elsif tx_on = '1' then 
							state := t_start;
						end if;
					end if;
				when t_byte =>
					if cnt_data < 8 then
						tx_bit := tx_byte(7 - cnt_data);

						cnt_data := cnt_data + 1;
						state := t_byte;
					end if;
					if cnt_data >= 8 then
						state := t_stop;
						cnt_data := 0;
						tx_rdy <= '1';
					end if;
					tx <= tx_bit;
				when t_stop =>
					tx <= '1';
					state := no_tx;						
			end case;
		end if;
	end process;
	 */
	-------------------------------------------------------------------------
	-- ######################################################################
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	-- 
	-------------------------------------------------------------------------
	p_indicate_tx : process (tx_rdy)
		variable tx_led_cnt : integer;
		variable tx_led_on : std_logic := '0';
	begin
		if rising_edge(tx_rdy) then 
			tx_led_on := '1';
		end if;
		if tx_led_on = '1' then
			if rising_edge(clk) then
				tx_led_cnt := tx_led_cnt + 1;
				tx_busy <= '1';
				if tx_led_cnt >= time_led_on /* 50 ms */ then 
					tx_led_cnt := 0;
					tx_busy <= '0';
				end if;
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- ######################################################################
	-------------------------------------------------------------------------
end architecture;