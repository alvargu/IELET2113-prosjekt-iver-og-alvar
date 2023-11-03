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
	
   TX_byte 	: in std_logic_vector(NUM_BITS-1 downto 0);
   TX_on, clk 		: in std_logic;
   TX, TX_busy	: out std_logic;

   signal BAUD_clk: std_logic := '0'; 
   signal col_bits: std_logic_vector(N-1 downto 0) := "00000000";
	
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
   -- purpose: control the BAUD_clk-signal
   -- type   : sequential
   -- inputs : clk
   -----------------------------------------------------------------------------
	p_BAUD_clk : process(clk)
    constant M: integer := f_clk/f_BAUD;
    variable BAUD_cnt: integer := 0;
	begin 
		if rising_edge(clk) then
            if BAUD_cnt = M/2 then 
                BAUD_clk <= not BAUD_clk;
            end if;
            BAUD_cnt := BAUD_cnt + 1;
        end if;
	end process p_clk;

     -----------------------------------------------------------------------------
   -- purpose: control the input of the TX module.
   -- type   : sequential
   -- inputs : TX_byte
   -----------------------------------------------------------------------------
	p_tx_byte : process
	begin 
		TX_byte <= "00000000";          -- Sender en byte av null, passer å skru på
        TX_on <= '1';                   -- sendesignalet.
        wait for CLK_PER*5208*(10)

        TX_byte <= "00001111";          -- Sender en ny byte, men skrur av sendesignalet
        TX_on <= '0';                   -- etter den er sendt.
        wait for CLK_PER*5208*(10)


        TX_byte <= "11110000";          -- Denne byten skal ikke sendes fordi
        wait for CLK_PER*5208*(10+1)    -- sendesignalet er skrudd av.

        TX_on <= '1';                   
        TX_byte <= "10000001";          -- Signalet blir send fordi sendesignalet
        wait for CLK_PER*5208*(10+1)    -- er skrudd på. Signalet vil bli sendt
                                        -- på nytt fordi vi rekker ikke å skru
                                        -- av sendesignalet på grunn av wait.
        end process p_clk;

    -----------------------------------------------------------------------------
    -- purpose: Collecting bits into a byte
    -- type   : sequential
    --inputs  : BAUD_clk
    -----------------------------------------------------------------------------
    p_collecting_bits : process(BAUD_clk, TX, TX_on)
    variable bits_cnt: integer := 0; 
    begin
        if TX_on = 1 then                       Vet ikke helt enda, må se på denne på nytt. IKKE FERDIG!
            if rising_edge(BAUD_clk) then
                bits_cnt := bits_cnt + 1;
                x <= x(6 downto 0) & TX; -- Vet ikke hva x skal hete enda.
                if (bits_cnt = 10) then

                    bits_cnt := 0;
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
        
        assert ( ascii_display = "10000110") -- Test if recieved byte is displayed as E
			report "RX did not interprete the information correctly."
			severity error;
        

		assert false report "Testbench finished" severity failure;
	end process p_main;

end architecture SimulationModel;
