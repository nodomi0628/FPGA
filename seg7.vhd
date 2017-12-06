library ieee;
use ieee.std_logic_1164.all;

entity seg7 is
	port (
		data_in	: in std_logic_vector(3 downto 0);
		led_out	: out std_logic_vector(6 downto 0));
end seg7;

architecture rtl of seg7 is
signal in_put : std_logic_vector(3 downto 0):= (others=>'0');

begin
	in_put <= data_in;
	process (in_put)
	begin
		case in_put is
			when "0000" =>
				led_out <= "1000000";
			when "0001" => 
				led_out <= "1111001";
			when "0010" =>
				led_out <= "0100100";
			when "0011" =>
				led_out <= "0110000";
			when "0100" =>
				led_out <= "0011001";
			when "0101" =>
				led_out <= "0010010";
			when "0110" =>
				led_out <= "0000010";
			when "0111" =>
				led_out <= "1011000";
			when "1000" =>
				led_out <= "0000000";
			when "1001" =>
				led_out <= "0011000";
			when "1010" =>
				led_out <= "0001000";
			when "1011" =>
				led_out <= "0000011";
			when "1100" =>
				led_out <= "0100111";
			when "1101" =>
				led_out <= "0100001";
			when "1110" =>
				led_out <= "0000110";
			when "1111" =>
				led_out <= "0001110";
			when others => null;
		end case;
	end process;
end rtl;				