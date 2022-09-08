--=======================================================================
--company: Tomsk State University
--developer: Simon Razenkov
--e-mail: sirazenkov@stud.tsu.ru
--description: CRC (cyclic redundancy check) with x^7 + x^3 + 1 polynomial
--========================================================================

library ieee;
use ieee.std_logic_1164.all;

entity crc7 is
begin
	port(
		idata : in std_logic;
    		iclk : in std_logic;
		irst : in std_logic;
		ocrc : out std_logic_vector(6 downto 0); 	
	)
end crc7;

architecture Behavioral of crc7 is
	signal crc : std_logic_vector(6 downto 0);
	variable i : integer;
	signal main_xor : std_logic;
begin
	main_xor <= idata xor crc(6);

	process(iclk, irst) begin
		if(irst) then
			crc <= (others => '0');
		else begin
			for i in (0 to 7) loop
				if(i = 0) then 
					crc(i) <= main_xor;
				elsif(i = 3) then
					crc(i) <= main_xor xor crc(i-1);
				else
					crc(i) <= crc(i-1);
				end if;
			end loop;
		end
		end if
	end process;

	ocrc <= crc;
end architecture;
