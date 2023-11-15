library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TX_tb is
end entity UART_TX_tb;


architecture SimulationModel of UART_TX_tb is

   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------
   constant CLK_PER  : time    := 20 ns;    -- 50 MHz
   constant NUM_BITS : integer := 8;

   constant f_clk: integer := 50_000_000;
   constant f_BAUD: integer := 9_600;

	component UART_TX is 
		port (
		------------------------------------------------------------------
		-- define inputs and outputs of system
		------------------------------------------------------------------
		TX_byte 	: in std_logic_vector(NUM_BITS-1 downto 0);
		TX_on, clk 		: in std_logic;
		TX, TX_busy	: out std_logic
		);
	end component UART_TX;
	
	-----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
	
   signal TX_byte: std_logic_vector(NUM_BITS-1 downto 0);
   signal TX_on, clk: std_logic;
   signal TX, TX_busy: std_logic;

   signal baud_clk_tb: std_logic := '0'; 
   signal col_bits: std_logic_vector(NUM_BITS-1 downto 0) := "00000000";
	
begin 

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   i_UART_TX: component UART_TX
   port map (
      clk     => clk,
      TX_byte => TX_byte,
      TX   => TX,
      TX_busy => TX_busy,
      TX_on => TX_on
   );

   -----------------------------------------------------------------------------
   -- purpose: control the clk-signal
   -- type   : sequential
   -- inputs : none
   -----------------------------------------------------------------------------
	p_clk : process
	begin 
		clk <= '1';
		wait for CLK_PER/2;
		clk <= '0';
		wait for CLK_PER/2;
	end process p_clk;

       -----------------------------------------------------------------------------
   -- purpose: control the baud_clk_tb-signal
   -- type   : sequential
   -- inputs : clk
   -----------------------------------------------------------------------------
	p_baud_clk_tb : process(clk)
    		constant M: integer := f_clk/f_BAUD; -- Factor that determines how many times
    		variable BAUD_cnt: integer := 0;	-- one should count to get the baud_clk
	begin                                       -- from the system clk.
	    if rising_edge(clk) then
            	if BAUD_cnt = M/2 then	-- Divide by two because the time before
                	baud_clk_tb <= not baud_clk_tb; -- "not baud_clk" equals half a
			BAUD_cnt := 0;                          -- period.
            	end if;
            	BAUD_cnt := BAUD_cnt + 1;
        	end if;
	end process p_baud_clk_tb;

     -----------------------------------------------------------------------------
   -- purpose: control the input of the TX module.
   -- type   : sequential
   -- inputs : TX_byte
   -----------------------------------------------------------------------------
	p_tx_byte : process
	begin 
        -----------------------------------------------------------------------
		TX_byte <= "00000000";          -- Sending a byte of zeros, makes sure that the
        TX_on <= '1';                   -- sendingsignal is active.            
        wait for CLK_PER*5208*(10);

        -----------------------------------------------------------------------
        TX_byte <= "00001111";          -- Not sending a byte, because the sending signal
        TX_on <= '0';                   -- is turned of at the same time.
        wait for CLK_PER*5208*(10);

        -----------------------------------------------------------------------
        TX_byte <= "11110000";          -- This byte is not sent baecause the
        wait for CLK_PER*5208*(10);   -- sending signal is turned off.
        
        -----------------------------------------------------------------------
        TX_on <= '1';
        TX_byte <= "10000001";
	    wait for CLK_PER*5208*(1);
	    TX_on <= '0';          		-- The signal is sent beacuse the sending signal is on.
        wait for CLK_PER*5208*(10+1);   -- The sending signal is turned off so
                                        -- pÃ¥ nytt fordi vi rekker ikke Ã¥ skru
                                        -- no more bytes will be sent.
        end process p_tx_byte;

    -----------------------------------------------------------------------------
    -- purpose: Collecting bits into a byte
    -- type   : sequential
    --inputs  : baud_clk_tb
    -----------------------------------------------------------------------------
    p_collecting_bits : process(baud_clk_tb, TX, TX_on)
        variable bits_cnt: integer := 0; 
        variable tx_on_save: std_logic := '0';
    begin
        if rising_edge(baud_clk_tb) then
            if TX_on = '1' or tx_on_save = '1' then	-- We are not interested in collecting
                tx_on_save := '1';						-- bits if the TX is turned off.
                if bits_cnt > 1 AND bits_cnt < 9 then	-- Not interested in collecing stop and start bit.
                    col_bits <= col_bits(6 downto 0) & TX; -- Shift register.
                end if;
                bits_cnt := bits_cnt + 1;
                if (bits_cnt = 10) then
                    bits_cnt := 0;
                    tx_on_save := '0';
                end if;
            end if;
        end if;
    end process p_collecting_bits;

	-----------------------------------------------------------------------------
	-- purpose: Main process
	-- type   : sequential
	-- inputs : none
	-----------------------------------------------------------------------------
	p_main : process
	begin 
        -----------------------------------------------------------------------
        wait for CLK_PER*5208*(10);
        assert ( col_bits = "00000000") -- 
			report "TX did not send the information correctly."
			severity error;

        wait for CLK_PER*5208*(10);
        assert ( col_bits = "00000000") -- 
			report "TX did not send the information correctly."
			severity error;

        wait for CLK_PER*5208*(10);
        assert ( col_bits = "00000000") -- 
			report "TX did not send the information correctly."
			severity error;

        -----------------------------------------------------------------------
        wait for CLK_PER*5208*(10+2);
        assert ( col_bits = "10000001") -- 
			report "TX did not send the information correctly."
			severity error;
        

		assert false report "Testbench finished" severity failure;
	end process p_main;

end architecture SimulationModel;