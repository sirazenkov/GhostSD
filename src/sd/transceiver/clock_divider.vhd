--=======================================================================
--company: Tomsk State University
--developer: Simon Razenkov
--e-mail: sirazenkov@stud.tsu.ru
--description: Clock divider for generating fast and slow SD clocks
--========================================================================

library ieee;
use ieee.std_logic_1164.all;

entity clock_divider is
	port(
		irst : std_logic;
		iclk : std_logic; 	-- Reference clock
		ofastclk : std_logic;	-- Divided by 4 clock
       		oslowclk : std_logic	-- Divided by 256 clock
	    );
end entity;

architecture Behavioral of clock_divider is
	signal counter : std_logic_vector(7 downto 0) := (others => '0'); 
begin
	process(iclk, irst) begin
		if(irst = '1') then
			counter <= (others => '0');
		elsif(rising_edge(iclk)) then
			counter <= counter + 1;	
		end if;
	end process;

	ofastclk <= counter(3);
	oslowclk <= counter(7);
end architecture;
