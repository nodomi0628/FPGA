library IEEE ;
use IEEE . std_logic_1164 . all ;
use IEEE . std_logic_unsigned . all ;

entity led7seg is
port (
	number : in integer range 0 to 15;
	led : out std_logic_vector (0 to 6) );
end led7seg ;

architecture rtl of led7seg is
type pat_array is array (0 to 15) of std_logic_vector (6 downto 0) ;
constant patterns : pat_array
	 := ( "1111110" , "0110000" , "1101101" , "1111001" , "0110011" , "1011011" , "0011111" , "1110000"
		, "1111111" , "1110011" , "1110111" , "0011111" , "1001110" , "0111101" , "1001111" , "1000111" );
begin
	led <= not patterns ( number );
end rtl ;