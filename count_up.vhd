library IEEE ;
use IEEE . std_logic_1164 . all ;
use IEEE . std_logic_unsigned . all ;

entity count_up is
generic (
	interval : integer ;
	max : integer );
port (
	clk : in std_logic ;
	be_continue : in std_logic ;
	counter : out integer );
end count_up ;

architecture rtl of count_up is
signal buf_clk : std_logic_vector ( interval downto 0) ;
signal div_clk : std_logic ;
signal local_counter : integer := 0;
begin
	div_clk <= buf_clk ( interval );

	process ( clk )
	begin
	if be_continue = '1' and rising_edge ( clk ) then
		buf_clk <= buf_clk + 1;
	end if ;
	end process ;

	process ( div_clk )
	begin
	if rising_edge ( div_clk ) then
		local_counter <= local_counter + 1;
		counter <= local_counter mod max +1;
	end if ;
end process ;
end rtl ;