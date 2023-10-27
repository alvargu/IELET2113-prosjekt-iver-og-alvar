library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exercise5_tb is
end entity exercise5_tb;


architecture SimulationModel of exercise5_tb is

   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------
   constant CLK_PER  : time    := 20 ns;    -- 50 MHz
   constant NUM_BITS : integer := 3;


	component exercise5 is 
		port (
		------------------------------------------------------------------
		-- define inputs and outputs of system
		------------------------------------------------------------------
		duty 		: in std_logic_vector(NUM_BITS-1 downto 0);
		clk 		: in std_logic;
		rstn 		: in std_logic;
		pwm_out 	: out std_logic
		);
	end component exercise5;
	
	-----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
	
	signal 	duty 		: std_logic_vector(NUM_BITS-1 downto 0);
	signal	clk 		: std_logic;
	signal	rstn 		: std_logic;
	signal	pwm_out 	: std_logic;
	
begin 

	-----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   i_exercise5: component exercise5
   port map (
      clk     => clk,
      rstn     => rstn,
      pwm_out => pwm_out,
      duty   => duty
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
   -- purpose: control the rst-signal
   -- type   : sequential
   -- inputs : none
   -----------------------------------------------------------------------------
	p_rstn : process
	begin 
		rstn <= '0';
		wait for 3*CLK_PER;
		rstn <= '1';
		wait;
	end process p_rstn;

	-----------------------------------------------------------------------------
	-- purpose: Main process
	-- type   : sequential
	-- inputs : none
	-----------------------------------------------------------------------------
	p_main : process
	begin 
		duty <= "000";
		wait for 80*CLK_PER;
		duty <= "001";
		wait for 80*CLK_PER;
		duty <= "010";
		wait for 80*CLK_PER;
		duty <= "011";
		wait for 80*CLK_PER;
		duty <= "100";
		wait for 80*CLK_PER;
		duty <= "101";
		wait for 80*CLK_PER;
		duty <= "110";
		wait for 80*CLK_PER;
		duty <= "111";
		wait for 80*CLK_PER;
		
		assert false report "Testbench finished" severity failure;
	end process p_main;

end architecture SimulationModel;