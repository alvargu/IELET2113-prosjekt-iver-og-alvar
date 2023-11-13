library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_pkg is 
	generic (
		constant f_clk: integer := 50_000_000;
		constant BAUD_RATE: integer := 9600;
		-- constant time_led_on: integer := 50; /* 50 ms */
		constant o_smp_bits: integer := 8
		);
	port (
		RX_sig 		: in std_logic;
		clk			: in std_logic;
		rx_n_rdy		: out std_logic;
		show_num 		: out std_logic_vector(7 downto 0)
		-- ascii_display	: out std_logic_vector(7 downto 0)
		);
end entity;		

		
architecture rtl of uart_rx_pkg is 
-------------------------------------------------------------------------------
-- Define internal signals of circuit
-------------------------------------------------------------------------------
-- clk signals
	signal baud_clk 		: std_logic := '1';
	signal o_smp_clk 		: std_logic := '1';
-- hold signals
	
-- data signals
	signal rx_bit 			: std_logic := '1';
	-- signal ascii_display 	: std_logic_vector(7 downto 0);
	
---------------------------------------------------------------------------------------------------------
-- Define functions of circuit
---------------------------------------------------------------------------------------------------------
	pure function majority_check(check_vector : std_logic_vector := "0000000") return std_logic is
		variable majority_val : std_logic;
		variable count_ones : integer := 0;
	begin
		/* Count number of ones in the vector */
		if check_vector(0) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(1) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(2) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(3) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(4) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(5) = '1' then count_ones := count_ones + 1;
		end if;
		if check_vector(6) = '1' then count_ones := count_ones + 1;
		end if;
		/* Return std_logic value 1 when most of the bits are 1 and 0 otherwise */
		if count_ones > 3 then majority_val := '1';
		else majority_val := '0';
		end if;
		return majority_val;
	end function;

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin
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
	p_data_sep_sm : process(baud_clk, rx_bit)
		type t_state is (n_data, r_data);
		variable state 		: t_state := n_data;
		variable cnt_data 	: integer := 0;
		variable v_rx_data 	: std_logic_vector(7 downto 0) := "00000000";
	begin
		if rising_edge(baud_clk) then
			case state is 
				when n_data =>
					if rx_bit = '0' then 
						state := r_data;
						rx_n_rdy <= '1';
					elsif rx_bit = '1' then 
						state := n_data;
					end if;
				when r_data =>
					if cnt_data < 8 then
						v_rx_data(7 - cnt_data) := rx_bit;
						cnt_data := cnt_data + 1;
						state := r_data;
					end if;
					if cnt_data >= 8 then
						state := n_data;
						show_num <= v_rx_data; 
						cnt_data := 0;
						rx_n_rdy <= '0';
					end if;						
			end case;
		end if;
	end process;
	
	--------------------------------------------------------------------------
	-- Process for reading RX_sig preforming 8 times oversampling and using 
	-- the 7 rightmost readings to decide value of the recieved bit.
	--------------------------------------------------------------------------
	p_read_bit_val :process (o_smp_clk, rx_sig)
		variable o_smp_cnt 		: integer range 0 to 8 := 0;
		variable rx_o_smp		: std_logic_vector(6 downto 0);
	begin
		if rising_edge(o_smp_clk) then 
					if o_smp_cnt > 0 then 
				RX_o_smp := RX_o_smp(5 downto 0) & RX_sig;
				if o_smp_cnt = 7 then 
					RX_bit <= majority_check(RX_o_smp);
				end if;
			end if;
			o_smp_cnt := o_smp_cnt + 1;
			if o_smp_cnt >= 8 then 	-- siden vi sjekker etter at vi har økt telleren må
				o_smp_cnt := 0;	-- vi øke med en når man skal sjekke for samme tall.
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------
	-- Set signals that go out equal to their inn system counterparts
	-------------------------------------------------------------------------
end architecture;
