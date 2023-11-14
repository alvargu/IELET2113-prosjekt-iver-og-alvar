-- Need to fil inn

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_tb is
end entity UART_tb;


architecture SimulationModel of UART_tb is

   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------
   constant CLK_PER  : time    := 20 ns;    -- 50 MHz
   constant NUM_BITS : integer := 8;

   constant f_clk: integer := 50_000_000;
   constant f_BAUD: integer := 9_600;

	component UART is 
		port (
		------------------------------------------------------------------
		-- define inputs and outputs of system
		------------------------------------------------------------------
		TX_byte : inout std_logic_vector(NUM_BITS-1 downto 0);
		TX_on : inout std_logic;
		clk, TX_button : in std_logic;
		TX, TX_busy	: out std_logic;
		
		RX_sig : in std_logic;
		RX_busy_led : out std_logic;
		ascii_display : out std_logic_vector(7 downto 0)
		);
	end component UART;
	
	-----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
	
   signal TX_byte: std_logic_vector(NUM_BITS-1 downto 0);
   signal TX_on, clk, TX_button: std_logic;
   signal TX, TX_busy: std_logic;

	signal RX_sig : std_logic;
	signal RX_busy_led : std_logic;
	signal ascii_display : std_logic_vector(7 downto 0);
	
   signal baud_clk_tb: std_logic := '0'; 
   signal col_bits: std_logic_vector(NUM_BITS-1 downto 0) := "00000000";
   -- signal cnt_test: integer := 0;

	
	
begin 

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   i_UART: component UART
   port map (
      clk     => clk,
      TX_byte => TX_byte,
      TX   => TX,
      TX_busy => TX_busy,
      TX_on => TX_on,
		TX_button => TX_button,
		
		RX_sig => RX_sig,
		RX_busy_led => RX_busy_led,
		ascii_display => ascii_display
		
		
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
    		constant M: integer := f_clk/f_BAUD;
    		variable BAUD_cnt: integer := 0;
	begin 
	    if rising_edge(clk) then
            	if BAUD_cnt = M/2 then 
                	baud_clk_tb <= not baud_clk_tb;
			BAUD_cnt := 0;
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
			wait for CLK_PER*5208*(45);
		TX_byte <= "00000000";          -- Sender en byte av null, passer Ã¥ skru pÃ¥
        TX_on <= '1';                   -- sendesignalet.
        wait for CLK_PER*5208*(10);

        TX_byte <= "00001111";          -- Sender en ny byte, men skrur av sendesignalet
        TX_on <= '0';                   -- etter den er sendt.
        wait for CLK_PER*5208*(10);


        TX_byte <= "11110000";          -- Denne byten skal ikke sendes fordi
        wait for CLK_PER*5208*(10);   -- sendesignalet er skrudd av.

        TX_on <= '1';
        TX_byte <= "10000001";
	wait for CLK_PER*5208*(1);
	TX_on <= '0';          		-- Signalet blir send fordi sendesignalet
        wait for CLK_PER*5208*(10+1);   -- er skrudd pÃ¥. Signalet vil bli sendt
                                        -- pÃ¥ nytt fordi vi rekker ikke Ã¥ skru
                                        -- av sendesignalet pÃ¥ grunn av wait.
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
        	if TX_on = '1' or tx_on_save = '1' then
           		tx_on_save := '1';
            		if bits_cnt > 0 AND bits_cnt < 9 then
                		col_bits <= col_bits(6 downto 0) & TX;
			end if;
			bits_cnt := bits_cnt + 1;
            		if (bits_cnt = 10) then
                		--col_bits <= "00000000";
                		bits_cnt := 0;
                		tx_on_save := '0';
           	 	end if;
       		end if;
	end if;
	-- cnt_test <= bits_cnt;
    end process p_collecting_bits;

	-----------------------------------------------------------------------------
	-- purpose: Main process
	-- type   : sequential
	-- inputs : none
	-----------------------------------------------------------------------------
	p_main : process
	begin 


	-----------------------------------------------------------------------------
	/* RX sin test */
	   RX_sig <= '1';				-- wait two periods
          wait for CLK_PER*5208*2;
		RX_sig <= '0';						-- start bit
          wait for CLK_PER*5208;
          RX_sig <= '0';				-- 1
          wait for CLK_PER*5208;
          RX_sig <= '0';				-- 2
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 3
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 4
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 5
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 6
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 7
		wait for CLK_PER*5208;
          RX_sig <= '0'; 				-- 8
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- stop bit
		wait for CLK_PER*5208;
			 
		assert ( ascii_display = "11000000") -- Test if recieved byte is displayed as 0
			report "RX did not interprete the information correctly."
			severity error;
		----------------------
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- start bit
          wait for CLK_PER*5208;
          RX_sig <= '0';				-- 1
          wait for CLK_PER*5208;
          RX_sig <= '0';				-- 2
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 3
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 4
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 5
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 6
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 7
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 8
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- stop bit
		wait for CLK_PER*5208;
		
		assert ( ascii_display = "11111000") -- Test if recieved byte is displayed as 7
			report "RX did not interprete the information correctly."
			severity error;
		----------------------
		wait for CLK_PER*5208*10;	-- Venter med å sende neste byte. 
								-- Kan prøve å forsinke utenfor CLK_PER med ns.
					
		assert ( ascii_display = "11111000")
			report "RX changed the information."
			severity error;
		----------------------

		RX_sig <= '0';				-- start bit
          wait for CLK_PER*5208;
          RX_sig <= '0';				-- 1
          wait for CLK_PER*5208;
          RX_sig <= '1';				-- 2
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 3
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 4
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 5
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 6
		wait for CLK_PER*5208;
          RX_sig <= '0';				-- 7
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- 8
		wait for CLK_PER*5208;
          RX_sig <= '1';				-- stop bit
		wait for CLK_PER*5208*3;
		
		assert ( ascii_display = "10000110") -- Test if recieved byte is displayed as E
			report "RX did not interprete the information correctly."
			severity error;
	
	-----------------------------------------------------------------------------
	
	
	-----------------------------------------------------------------------------
	/* TX sin test. MÅ OPPDATERE PORSESSEN p_tx_byte slik at det passer i tid. */
		wait for CLK_PER*5208*(10);
        assert ( col_bits = "00000000") -- 
			report "TX did not send the information correctly."
			severity error;

      wait for CLK_PER*5208*(10);
        assert ( col_bits = "00001111") -- 
			report "TX did not send the information correctly."
			severity error;

      wait for CLK_PER*5208*(10);
        assert ( col_bits = "11110000") -- 
			report "TX did not send the information correctly."
			severity error;

      wait for CLK_PER*5208*(10+2);
        assert ( col_bits = "10000001") -- 
			report "TX did not send the information correctly."
			severity error;
	
      wait for CLK_PER*5208*(10+2);
        assert ( col_bits = "10000001") -- 
			report "TX did not send the information correctly."
			severity error;

			
	-----------------------------------------------------------------------------		


	-----------------------------------------------------------------------------
	/* Helheten sin test */
	
	-- TX_button
	
		TX_button <= '1';
		
		wait for CLK_PER*5208*(10);
        assert ( col_bits = "00111001") -- 
			report "TX_button did not send the information correctly."
			severity error;
		
		
	-----------------------------------------------------------------------------
	

		assert false report "Testbench finished" severity failure;
	end process p_main;

end architecture SimulationModel;