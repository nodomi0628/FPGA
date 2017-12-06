library ieee ;
use ieee . std_logic_1164 . all ;

package types is
	type seg_array is array (0 to 2) of std_logic_vector (0 to 6) ;
end types ;

library ieee ;
use ieee . std_logic_1164 . all ;
use ieee . std_logic_unsigned . all ;
use ieee . std_logic_arith . all ;
use ieee . numeric_std . all ;

use work . types . all ;

entity lcd_slot is
port (
	clk : in std_logic ;
	in_btn : in std_logic ;
	out_seg : out seg_array ;
	lcdData : out std_logic_vector (7 downto 0) ;
	lcdRs : out std_logic ;
	lcdRw : out std_logic ;
	lcdOn : out std_logic ;
	lcdEn : out std_logic );
end lcd_slot ;

architecture rtl of lcd_slot is

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

component lcdio
port (
	clk : in std_logic ;
	charData : in std_logic_vector ( 319 downto 0 );
	lcdData : out std_logic_vector (7 downto 0) ;
	lcdRS : out std_logic ;
	lcdRW : out std_logic ;
	lcdON : out std_logic ;
	lcdEN : out std_logic );
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

signal data : std_logic_vector (319 downto 0) ;

type char_ram_type is array (0 to 39) of std_logic_vector (7 downto 0) ;
shared variable char_ram : char_ram_type := ( others => x"A0");

begin
	count_up_gen0 : count_up generic map ( interval (0) , 9) port map ( clk , be_continue (0) , numbers (0) );
	count_up_gen1 : count_up generic map ( interval (1) , 9) port map ( clk , be_continue (1) , numbers (1) );
	count_up_gen2 : count_up generic map ( interval (2) , 9) port map ( clk , be_continue (2) , numbers (2) );

	led7seg_gen0 : led7seg port map ( numbers (0) , out_seg (0) );
	led7seg_gen1 : led7seg port map ( numbers (1) , out_seg (1) );
	led7seg_gen2 : led7seg port map ( numbers (2) , out_seg (2) );

	lcdio_gen : lcdio port map ( clk , data , lcdData , lcdRs , lcdRw , lcdOn , lcdEn );

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
		-- display that :[ Congratu | lations !][ > < ]
		char_ram := (x"43" , x"6F" , x"6E" , x"67" , x"72" , x"61" , x"74" , x"75" ,
		x"6C" , x"61" , x"74" , x"69" , x"6F" , x"6E" , x"73" , x"21" , 26=> x"3E" , 28=> x"3C" , others =>x"A0");
	else
		-- display that :[ PUSH KEY TO STOP ]
		char_ram := (x"50" , x"55" , x"53" , x"48" , x"A0" , x"4B" , x"45" , x"59" ,
		x"A0" , x"54" , x"4F" , x"A0" , x"53" , x"54" , x"4F" , x"50" , others =>x"A0");
	end if ;

		for i in 0 to 39 loop
			data (( i *8) +7 downto i *8) <= char_ram (i);
		end loop ;
	end if ;
	end process ;
end rtl ;