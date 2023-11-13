library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is 
	generic (
		constant f_clk: integer := 50_000_000;
		constant baud_rate: integer := 9600;
		constant time_led_on: integer := 50; /* 50 ms */
		constant o_smp_bits: integer := 8
		);
	port (
		clk: in std_logic;
		
		tx_byte: in std_logic_vector(7 downto 0);
		tx_on: in std_logic;
		tx : out std_logic;
		tx_busy: out std_logic;

		RX_sig : in std_logic;
		rx_busy_led: out std_logic;
		ascii_display: out std_logic_vector(7 downto 0)
		);
	

end entity;
		
architecture rtl of uart is 



begin 

     rx_module : entity work.uart_rx
          generic map (
               f_clk => f_clk,
               BAUD_RATE => BAUD_RATE,
               time_led_on => time_led_on,
               o_smp_bits => o_smp_bits
               )
          port map (
               RX_sig => RX_sig,
               clk => clk,
               rx_busy_led => rx_busy_led,
               ascii_display => ascii_display
               );

     tx_module : entity work.uart_tx
          generic map (
               f_clk => f_clk,
               baud_rate => baud_rate
               )
          port map (
               tx_byte => tx_byte,
               clk => clk,
               tx_on => tx_on,
               tx => tx,
               tx_busy => tx_busy
               );

     --------------------------------------------------------------------------
	-- Code to handle segment display
     -- Control module ############################
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
	-------------------------------------------------------------------------
	-- 
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
	-- 
	-------------------------------------------------------------------------
end architecture;