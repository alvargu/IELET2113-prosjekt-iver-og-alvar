library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RX_tb is
end entity UART_RX_tb;


architecture SimulationModel of UART_RX_tb is

   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------
   constant CLK_PER  : time    := 20 ns;    -- 50 MHz
   constant NUM_BITS : integer := 8;


	component UART_RX is 
		port (
		------------------------------------------------------------------
		-- define inputs and outputs of system
		------------------------------------------------------------------
		seg_ut 	: out std_logic_vector(NUM_BITS-1 downto 0);
		clk 		: in std_logic;
		RX_sig 	: in std_logic
		);
	end component UART_RX;
	
	-----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
	
	signal 	seg_ut    : std_logic_vector(NUM_BITS-1 downto 0);
	signal	clk 		: std_logic;
	signal	RX_sig 	: std_logic;
	
begin 

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   i_UART_RX: component UART_RX
   port map (
      clk     => clk,
      RX_sig => RX_sig,
      seg_ut   => seg_ut
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
	-- purpose: Main process
	-- type   : sequential
	-- inputs : none
	-----------------------------------------------------------------------------
	p_main : process
	begin 
		RX_sig <= '1';
          wait for CLK_PER*5208;
          RX_sig <= '1';
          wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
          wait for CLK_PER*5208;
          RX_sig <= '1';
          wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
          wait for CLK_PER*5208;
          RX_sig <= '1';
          wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;
          RX_sig <= '1';
		wait for CLK_PER*5208;

		assert false report "Testbench finished" severity failure;
	end process p_main;

end architecture SimulationModel;