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
	istart_transaction : in std_logic;
	odone : out std_logic;
	
	isel_clk : in std_logic; -- Select CLK frequency: '1' - 18 MHz, '0'- 281.25 kHz

	-- Received/Sent Data
	icmd_index : in std_logic_vector(5 downto 0);	-- Command index
	icmd_arg : in std_logic_vector(31 downto 0);	-- Command argument 
	ioblock : inout std_logic_vector(127 downto 0); -- GOST cipher block (128 bits)
	oresp : out std_logic_vector(135 downto 0);	-- Received response
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

	component crc16 is
		port(
               	idata : in std_logic;
               	iclk : in std_logic;
               	irst : in std_logic;
               	ocrc : out std_logic_vector(15 downto 0)
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
	type transceiver_state is (IDLE, BARE_CMD, CMD_RESP, CMD_READ, CMD_WRITE, DONE);
	signal current_state : transceiver_state := IDLE;

	type line_state is (IDLE, WAITING_START, RECEIVING, SENDING, DONE);
	signal CMD_state : line_state := IDLE;
	signal D_state : line_state := IDLE;

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
					if(istart_transaction) then
						case (icmd_index) is
							when 6D"0" => current_state <= BARE_CMD;
							when 6D"8" | 6D"41" | 6D"2" | 6D"3" | 6D"7" | 6D"16"=> 
								current_state <= CMD_RESP;
							when 6D"17" => current_state <= CMD_READ;
							when 6D"24" => current_state <= CMD_WRITE;
						end case;
					end if;
				when BARE_CMD => current_state <= DONE when CMD_state = DONE else BARE_CMD;
				when CMD_RESP => current_state <= DONE when CMD_state = DONE else CMD_RESP;
				when CMD_READ => current_state <= DONE when D_state = DONE else CMD_READ;
				when CMD_WRITE => current_state <= DONE when D_state = DONE else CMD_WRITE;
				when others => current_state <= IDLE;
			end case;			
		end if;
	end process;

	process(iclk, irst) is begin
		if(irst) then
			CMD_state <= IDLE;
		elsif(rising_edge(iclk)) then
			case CMD_state is
				when IDLE =>
					if(current_state != IDLE) then
						CMD_state <= SENDING;
					end if;
				when SENDING => 
					if(counter = D"48")
						CMD_state <= IDLE when (current_state = BARE_CMD) 
							     else WAITING_START;
					end if;
				when WAITING_START => if(iocmd_sd = '0') then CMD_STATE <= RECEIVING; 
				when RECEIVEING => 
				when others => CMD_state <= IDLE;
			end case;	
		end if;
	end process;

	process(iclk, irst) is begin
		if(irst) then
			D_state <= IDLE;
		elsif(rising_edge(iclk)) then
			case D_state is
				when IDLE => 
				when SENDING => 
				when WAITING_START => 
				when RECEIVEING => 
				when others => CMD_state <= IDLE;
			end case;	
		end if;
	end process;

	odone <= current_state = DONE;
end architecture;
