library ieee;
use ieee.std_logic_1164.all;

entity crc7_tb is
begin
end crc7_tb;

architecture Behavioral of crc7_tb is
	subtype msg is std_logic_vector(39 downto 0);
	constant CMD0 : msg := "01" & "000000" & "00000000000000000000000000000000";	
	constant CMD17 : msg := "01" & "010001" &"00000000000000000000000000000000";
	constant RESP17 : msg := "00" & "010001" & "00000000000000000000100100000000";	
	constant period : time := 40 ns;
	constant half_period : time := period / 2;

	signal data, clk, rst: std_logic := '0';
	signal crc : std_logic_vector(6 downto 0);

	component crc7
		port(
			idata : in std_logic;
			iclk : in std_logic;
			irst : in std_logic;
			ocrc : out std_logic_vector(6 downto 0)
		    );
	end component;
begin
	clk <= not clk after half_period;

	dut : crc7 port map(
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
		
		-- Passing CMD0
		for i in msg'range loop
			data <= CMD0(i); 
			wait for period;	
		end loop;
		wait for period;		
		assert crc = "1001010"
		report "Wrong CMD0 checksum!" severity error;
		
		-- Reset
                rst <= '1';
                wait for period;
                rst <= '0';
		
		--Passing CMD17
		for i in msg'range loop
			data <= CMD17(i); 
			wait for period;	
		end loop;
		wait for period;		
		assert crc = "0101010"
		report "Wrong CMD17 checksum!" severity error;

		-- Reset
                rst <= '1';
                wait for period;
                rst <= '0';
		
		--Passing RESP17
		for i in msg'range loop
			data <= RESP17(i); 
			wait for period;	
		end loop;
		wait for period;		
		assert crc = "0110011"
		report "Wrong RESP17 checksum!" severity error;

		assert false report "End of test (Press Ctrl+C to exit)" severity note;
		wait;
	end process;
end Behavioral;
