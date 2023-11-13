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

end architecture;