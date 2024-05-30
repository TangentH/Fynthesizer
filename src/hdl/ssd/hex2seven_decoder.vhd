library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex2seven_decoder is
    port (
        hex_in : in std_logic_vector(3 downto 0);
        cathode_out : out std_logic_vector(6 downto 0)
    );
end hex2seven_decoder;

architecture arch of hex2seven_decoder is
begin
    process(hex_in) is
    begin
        case hex_in is
            when "0000" => 
                cathode_out <= "0000001"; -- 0
            when "0001" => 
                cathode_out <= "1001111"; -- 1
            when "0010" => 
                cathode_out <= "0010010"; -- 2
            when "0011" => 
                cathode_out <= "0000110"; -- 3
            when "0100" => 
                cathode_out <= "1001100"; -- 4
            when "0101" => 
                cathode_out <= "0100100"; -- 5
            when "0110" => 
                cathode_out <= "0100000"; -- 6
            when "0111" => 
                cathode_out <= "0001111"; -- 7
            when "1000" => 
                cathode_out <= "0000000"; -- 8
            when "1001" => 
                cathode_out <= "0000100"; -- 9
            when "1010" => 
                cathode_out <= "0001000"; -- A
            when "1011" => 
                cathode_out <= "1100000"; -- B
            when "1100" => 
                cathode_out <= "0110001"; -- C
            when "1101" => 
                cathode_out <= "1000010"; -- D
            when "1110" =>  
                cathode_out <= "0110000"; -- E
            when "1111" => 
                cathode_out <= "0111000"; -- F
            when others => 
                cathode_out <= "1111111"; -- OFF
        end case;
    end process;
end architecture;