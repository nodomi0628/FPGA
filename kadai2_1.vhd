library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity kadai2_1 is
port (
	clk			: in std_logic;
	seven		: out std_logic_vector(6 downto 0);
	key2 		: in std_logic;
	key3		: in std_logic);
end kadai2_1;

architecture rtl of kadai2_1 is
component seg7
	port (
		data_in : in std_logic_vector(3 downto 0);
		led_out : out std_logic_vector(6 downto 0));
	end component;
signal counter : std_logic_vector(3 downto 0);
signal key2_pre , key3_pre	: std_logic;

begin
process (clk)
	begin
	if rising_edge(clk) then
		if key2 = '0' and key2_pre = '0' then
			--pushed key2
			counter <= counter+1;
			key2_pre <= '1';
		end if;
		if key2 = '1' and key2_pre = '1' then
			key2_pre <= '0';
		end if;
		if key3 = '0' and key3_pre = '0' then
			--pushed key3
			counter <= counter-1;
			key3_pre <= '1';
		end if;
		if key3 = '1' and key3_pre = '1' then
			key3_pre <= '0';
		end if;
	end if;
end process;
	
	segcnt: seg7 port map (data_in => counter, led_out => seven);
	
end rtl;