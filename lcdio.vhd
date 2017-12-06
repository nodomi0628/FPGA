library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lcdio is
	generic ( tickNum		: positive := 320);
	port (	clk			: in std_logic;
			charData	: in std_logic_vector( 319 downto 0 );
			-- LCD Interface
			lcdClk		: out std_logic;
			lcdData		: out std_logic_vector(7 downto 0);
			lcdRS		: out std_logic;
			lcdRW		: out std_logic;
			lcdON		: out std_logic;
			lcdEN		: out std_logic);
end lcdio;

architecture rtl of lcdio is
	subtype BIT07 is std_logic_vector(7 downto 0);
	type CHAR_RAM_TYPE is array(0 to 39) of BIT07;
	signal charRAM	: CHAR_RAM_TYPE := (others=>x"A0");

	signal reset			: std_logic :='0';

	-- LCD interface constants
	constant LCD_ON			: std_logic := '1';
	constant LCD_READ		: std_logic := '1';
	constant LCD_WRITE		: std_logic := '0';
	constant DATA_CODE		: std_logic := '1';
	constant INSN_CODE		: std_logic := '0';

	-- Tick Generation
	subtype TICK_COUNTER_TYPE is integer range 0 to tickNum;
	signal tick				: std_logic;

	constant WARMUP_DELAY	: integer := 2000;	-- 2000: 20ms
	constant INIT_DELAY		: integer := 500;	-- 500:	5ms
	constant CHAR_DELAY		: integer := 10;	-- 100:	100us

	subtype DELAY_TYPE is integer range 0 to WARMUP_DELAY;
	signal timer				: DELAY_TYPE;

	type INIT_ROM_TYPE is array (0 to 6) of std_logic_vector(7 downto 0);
	constant initROM			: INIT_ROM_TYPE := (	b"0011_0000",	-- Init
														b"0011_0000",	-- Init
														b"0011_0000",	-- Init
														b"0011_1000",	-- Function Set: 8 bit, 2 lines, 5x7 characters
														b"0000_1100",	-- Display On/Off Control: Display on, Cursor off, Blink off
														b"0000_0001",	-- Clear Display: Move cursor to home
														b"0000_0110");	-- Entry Mode Set: Auto increment cursor, don't shift display

	signal setLine				: std_logic;
	signal lineNum				: integer range 0 to 1;
	signal initialising		: std_logic;

	signal loc				: integer range 0 to 5 := 0;

	signal initROMPointer	: integer range 0 to INIT_ROM_TYPE'high;
	signal charRAMPointer	: integer range 0 to CHAR_RAM_TYPE'high;

signal div_counter : std_logic_vector(24 downto 0);
signal div_clk : std_logic;

	type STATE_TYPE is (WARMUP, STAGE1, STAGE2, STAGE3, DELAY);
	signal state				: STATE_TYPE;

begin

------------------------------------------
--  Process using LCD      ---------------
------------------------------------------

process(clk)
begin
	if(falling_edge(clk)) then
		for I in 0 to 39 loop
			charRAM(I) <= charData( (I+1)*8-1 downto I*8 );
		end loop;
	end if;
end process;


------------------------------------------
--  show character to LCD  ---------------
------------------------------------------
lcdRW	<= LCD_WRITE;
lcdON   <= LCD_ON;

TickGen : process(clk)
	variable tickCounter : TICK_COUNTER_TYPE;
begin
	if (clk'event and clk='1') then
		if (tickCounter = 0) then
			tickCounter := TICK_COUNTER_TYPE'high-1;
			tick <= '1';
		else
			tickCounter := tickCounter - 1;
			tick <= '0';
		end if;
	end if;
end process;

Controller : process (clk)
begin
	if (clk'event and clk='1') then

		if (reset='1') then
			timer				<= WARMUP_DELAY;
			initROMPointer <= 0;
			charRAMPointer <= 0;

			lcdRS				<= INSN_CODE;
			lcdEN				<= '0';
			lcdData			<= (others => '0');

			initialising	<= '1';
			setLine			<= '0';
			lineNum			<= 0;
			state				<= WARMUP;

		elsif (tick='1') then

			case state is 

				-- Perform initial long warmup delay
				when WARMUP =>
					if (timer=0) then
						state <= STAGE1;
					else
						timer <= timer - 1;
					end if;

				-- Set the LCD data
				-- Set the LCD RS
				-- Initialise the timer with the required delay
				when STAGE1 =>
					if (initialising='1') then
						timer		<= INIT_DELAY;
						lcdRS		<= INSN_CODE;
						lcdData	<= initROM(initROMPointer);

					elsif (setLine='1') then
						timer		<= CHAR_DELAY;
						lcdRS		<= INSN_CODE;
						case lineNum is
							when 0 => lcdData	<= b"1000_0000";	-- x00
							when 1 => lcdData	<= b"1100_0000";	-- x40
						end case;

					else
						timer		<= CHAR_DELAY;
						lcdRS		<= DATA_CODE;
						lcdData	<= charRAM(charRAMPointer);
					end if;

					state	<= STAGE2;

				-- Set lcdEN (latching RS and RW)
				when STAGE2 =>
					if (initialising='1') then
						if (initROMPointer=INIT_ROM_TYPE'high) then
							initialising <= '0';
						else
							initROMPointer	<= initROMPointer + 1;
						end if;

					elsif (setLine='1') then
						setLine <= '0';

					else

						if (charRAMPointer=19) then
							setLine <= '1';
							lineNum <= 1;

						elsif (charRAMPointer=39) then
							setLine <= '1';
							lineNum <= 0;
						end if;

						if (charRAMPointer=CHAR_RAM_TYPE'high) then
							charRAMPointer <= 0;
						else
							charRAMPointer <= charRAMPointer + 1;
						end if;

					end if;

					lcdEN	<= '1';
					state	<= STAGE3;

				-- Clear lcdEN (latching data)
				when STAGE3 =>
					lcdEN	<= '0';
					state	<= DELAY;

				-- Provide delay to allow instruciton to execute
				when DELAY =>
					if (timer=0) then
						state <= STAGE1;
					else
						timer <= timer - 1;
					end if;

			end case;
		end if;
	end if;
end process;

end rtl;