library ieee ;
use ieee . std_logic_1164 . all ;

package types is
	type seg_array is array (0 to 2) of std_logic_vector (0 to 6) ;
end types ;
library ieee ;
use ieee . std_logic_1164 . all ;
use ieee . std_logic_unsigned . all ;
use ieee . std_logic_arith . all ;

use work . types . all ;

entity slot is
port (
	clk : in std_logic ;
	in_btn : in std_logic ;
	out_seg : out seg_array ;
	out_led : out std_logic_vector (17 downto 0) );
end slot ;

architecture rtl of slot is

component led7seg
port (
	number : in integer range 0 to 15;
	led : out std_logic_vector (0 to 6) );
end component ;

component count_up
generic (
	interval : integer ;
	max : integer );
port (
	clk : in std_logic ;
	be_continue : in std_logic ;
	counter : out integer );
end component ;

constant slot_digit : integer := 3;
type interval_type is array (0 to 2) of integer ;
constant interval : interval_type := (22 , 21 , 23) ;

signal be_continue : std_logic_vector (0 to 2) := "111";
type numbers_type is array (0 to 2) of integer ;
signal numbers : numbers_type := (0 , 0, 0) ;
signal pushing : std_logic := '0';
signal pushed : std_logic := '0';

signal stopped_counter : integer range 0 to slot_digit := 0;
signal led_counter : integer := 0;

begin
	count_up_gen0 : count_up generic map ( interval (0) , 9) port map ( clk , be_continue (0) , numbers (0) );
	count_up_gen1 : count_up generic map ( interval (1) , 9) port map ( clk , be_continue (1) , numbers (1) );
	count_up_gen2 : count_up generic map ( interval (2) , 9) port map ( clk , be_continue (2) , numbers (2) );

	count_up_gen_for_led : count_up generic map (21 , 17) port map ( clk , '1', led_counter );

	led7seg_gen0 : led7seg port map ( numbers (0) , out_seg (0) );
	led7seg_gen1 : led7seg port map ( numbers (1) , out_seg (1) );
	led7seg_gen2 : led7seg port map ( numbers (2) , out_seg (2) );

process ( clk )
begin
	if rising_edge ( clk ) then
		pushing <= not in_btn ;

	if pushing = '1' and pushed = '0' then
		if stopped_counter = slot_digit then
			be_continue <= "111";
			stopped_counter <= 0;
		else
			be_continue ( stopped_counter ) <= '0';
			stopped_counter <= stopped_counter + 1;
		end if ;

		pushed <= '1';
	elsif pushing = '0' and pushed = '1' then
		pushed <= '0';
	end if ;

	if stopped_counter = slot_digit and numbers (0) = numbers (1) and numbers (1) = numbers (2) then
		out_led ( led_counter ) <= '1';
		out_led ( led_counter - 1) <= '0';
	else
		out_led <= ( others => '0') ;
	end if ;
end if ;
end process ;
end rtl ;