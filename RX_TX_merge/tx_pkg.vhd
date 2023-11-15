library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_module is 
	generic (
		constant f_clk: integer := 50_000_000;
		constant baud_rate: integer := 9600
		-- constant time_led_on: integer := 50 /* 50 ms */
		);
	port (
		tx_byte: in std_logic_vector(7 downto 0);
		clk: in std_logic;
		tx_on: in std_logic;
		tx : out std_logic := '1';
		tx_busy: out std_logic := '0'
		-- ascii_display: out std_logic_vector(7 downto 0)
		);
end entity;		

		
architecture rtl of uart_tx_module is 
-------------------------------------------------------------------------------
-- Define internal signals of circuit
-------------------------------------------------------------------------------
-- clk signals
	signal baud_clk 	: std_logic := '1';

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
			if (baud_clk_cnt >= baud_factor / 2) then
				baud_clk_cnt := 0; 				
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
		type t_state is (t_start, t_byte, t_stop);
		variable state 	: t_state := t_start; -- starting state is t_start
		variable cnt_data 	: integer := 0; -- used to determine which bit of the byte to send
		variable tx_bit 	: std_logic := '1'; -- used to be able to change transmitting byte (possible unnecesary)
		variable transmiting_byte : std_logic_vector(7 downto 0) := "00000000"; -- used to save the byte to transmit
		variable tx_on_save : std_logic := '0'; -- used to hold transmition until transmition is finnished
	begin
		-- Only transmit on baud clock
		if rising_edge(baud_clk) then
			if tx_on = '0' then 
				tx_busy <= '0'; -- Set tx_busy to 0 to indicate system not sending byte
				if tx_on_save = '0' then -- if not transmiting and not told to do so
					tx <= '1'; -- set tx to 1 because transmition is inactive high
				end if;
			-- when told to transmit
			elsif tx_on = '1' then 
				tx_on_save := '1'; -- set to transmit until full byte has been transmited
			end if;
			if (tx_on = '1' or tx_on_save = '1') then -- state machine will only process if transmition has been started
				tx_busy <= '1'; -- set tx_busy to 1 to indicate system sending byte
				case state is
					when t_start => -- state for startup of transmition
						tx <= '0'; -- tx port sett to 0 to initiate transmition
						state := t_byte; -- next state will be  transmitting state
						transmiting_byte := tx_byte; -- Save the byte to not change trasnmition half way through
					when t_byte =>-- state for transmition of byte
						if cnt_data <= 7 then
							-- Send every bit in byte starting with MSB going down to LSB
							tx_bit := transmiting_byte(7 - cnt_data);
							cnt_data := cnt_data + 1;
							-- and keep current state
							state := t_byte;
						end if;
						if cnt_data >= 8 then -- When all 8 bits have been transmited 
							state := t_stop; -- set the next state to stop transmiting 
							cnt_data := 0; -- and reset the counter of which bit is transmited
						end if;
						tx <= tx_bit;
					when t_stop => -- state for ending of transmition
						tx <= '1'; -- tx port sett to 1 for stopbit
						state := t_start; -- next time transmition start at t_start state
						tx_on_save := '0'; -- set to not transmit unless tx_on is 1
				end case;
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- ######################################################################
	-------------------------------------------------------------------------
end architecture;
