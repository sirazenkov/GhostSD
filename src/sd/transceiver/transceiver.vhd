--=======================================================================
--company: Tomsk State University
--developer: Simon Razenkov
--e-mail: sirazenkov@stud.tsu.ru
--description: SD interface transceiver top module
--========================================================================

library ieee;
use ieee.std_logic_1164.all;

entity transceiver is
	port(
	irst : in std_logic;
	iclk : in std_logic;

	-- SD Bus
	icmd_sd : in std_logic;				-- CMD line
	iodata_sd : inout std_logic_vector(3 downto 0); -- D[3:0] line

	-- Control ports
	isend_cmd : in std_logic;
	ircv_resp : in std_logic;
	isend_block : in std_logic;
	ircv_block : in std_logic;	

	-- Received/Sent Data
	icmd : in std_logic_vector(47 downto 0);	-- Command for SD
	ioblock : inout std_logic_vector(127 downto 0); -- GOST cipher block (128 bits)
	oresp : out std_logic_vector(135 downto 0);	-- SD response
	ovalid : out std_logic				-- Block or response valid
    	);
end entity;

architecture Mixed of transceiver is
	component crc7 is
		port(
               	idata : in std_logic;
               	iclk : in std_logic;
               	irst : in std_logic;
               	ocrc : out std_logic_vector(6 downto 0)
        	);
	end component;
begin
	
end architecture;
