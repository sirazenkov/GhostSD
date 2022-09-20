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
	irst : in std_logic; -- Global reset
	iclk : in std_logic; -- System clock (72 MHz)

	-- SD Bus
	iocmd_sd : inout std_logic;			-- CMD line
	iodata_sd : inout std_logic_vector(3 downto 0); -- D[3:0] line
	oclk_sd : out std_logic;			-- CLK line

	-- Control ports
		-- Actions
	isend_cmd : in std_logic;	-- Send command
	ircv_resp : in std_logic;	-- Receive response
	isend_block : in std_logic;	-- Send block
	ircv_block : in std_logic;	-- Receive block
		-- Response
	odone : out std_logic;
	
	isel_clk : in std_logic; -- Select CLK frequency: '1' - 18 MHz, '0'- 281.25 kHz

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

	component clock_divider is
		port(
		irst : in std_logic;
		iclk : in std_logic;
		ofastclk : in std_logic;	
		oslowclk : in std_logic
		);
	end component;
	type state is (IDLE, SEND_CMD, SEND_BLOCK, RECV_RESP, RCV_BLOCK);
	signal current_state : state := IDLE;
	signal clk_18MHz, clk_281kHz : std_logic;
	signal data_bit_counter, cmd_bit_counter : std_logic_vector;
begin
	clk_div : clock_divider
	port map(
		irst => irst,
		iclk => iclk,
		ofastclk => clk_18MHz,
		oslowclk => clk_281kHz
	);

	oclk_sd <= clk_18MHz when isel_clk else clk_281kHz;

	process(iclk, irst) is begin
		if(irst) then
			odone <= '0';	

			data_bit_counter <= (others => '0');
			cmd_bit_counter <= (others => '0');
		elsif(rising_edge(iclk)) then
			case current_state is
				when IDLE =>
					if(isend_cmd) then
						current_state <= SEND_CMD;
					elsif(isend_block) then
						current_state <= SEND_BLOCK;
					elsif(ircv_resp) then
						current_state <= RCV_RESP;
					elsif(ircv_block) then
						current_state <= RCV_BLOCK;
					end if;
				when SEND_CMD =>
				when SEND_BLOCK =>
				when RCV_RESP =>
				when RCV_BLOCK =>
				when others => current_state <= IDLE;
			end case;			
		end if;
	end process;
end architecture;
