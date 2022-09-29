--=======================================================================
--company: Tomsk State University
--developer: Simon Razenkov
--e-mail: sirazenkov@stud.tsu.ru
--description: CMD line driver
--========================================================================

library ieee;
use ieee.std_logic_1164.all;

entity line_driver is
	port(
	irst : in std_logic;	-- Global reset
	iclk : in std_logic;	-- System clock

	icmd_index : in std_logic;	-- Command index
	icmd_arg : in std_logic;	-- Command argument
	oresp : out std_logic_vector(0 to 135); -- Received response

	iocmd_sd : inout std_logic;		-- CMD line
	
	isend : in std_logic;	-- Send command
	ircv : in std_logic;	-- Receive response
	);
end entity;

architecture Mixed of cmd_driver is
begin
	process(iclk, irst) is
	begin
	end process;
end architeciture;
