library ieee;
use ieee.std_logic_1164.all;

entity crc16_tb is
begin
end crc16_tb;

architecture Behavioral of crc16_tb is
	constant period : time := 40 ns;
	constant half_period : time := period / 2;

	signal data, clk, rst: std_logic := '0';
	signal crc : std_logic_vector(15 downto 0);

	component crc16
		port(
			idata : in std_logic;
			iclk : in std_logic;
			irst : in std_logic;
			ocrc : out std_logic_vector(15 downto 0)
		    );
	end component;
begin
	clk <= not clk after half_period;

	dut : crc16 port map(
		idata => data,
		iclk => clk,
		irst => rst,
		ocrc => crc
		);

	process 
	begin
		-- Reset
		wait for half_period;		
		rst <= '1';
		wait for period;		
		rst <= '0';

		data <= '1';

		-- Passing 512 bytes of 0xFF
		wait for period*(512*8 + 1);	
		assert crc = X"7FA1"
		report "Wrong checksum!" severity error;
	
		-- Reset
                rst <= '1';
                wait for period;
                rst <= '0';

		assert false report "End of test (Press Ctrl+C to exit)" severity note;
		wait;
	end process;
end Behavioral;
