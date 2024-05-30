library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multi_hex_decoder is
    port (
        sel : in std_logic_vector(2 downto 0);
        in_hex1, in_hex2, in_hex3, in_hex4, in_hex5, in_hex6, in_hex7, in_hex8 : in std_logic_vector(3 downto 0);
        cathode_out : out std_logic_vector(6 downto 0)
    );
end multi_hex_decoder;

architecture arch of multi_hex_decoder is
    component hex2seven_decoder is
        port (
            hex_in : in std_logic_vector(3 downto 0);
            cathode_out : out std_logic_vector(6 downto 0)
        );
    end component;
    signal hex_sel : std_logic_vector(3 downto 0);
begin
    HD: hex2seven_decoder port map(hex_in => hex_sel, cathode_out => cathode_out);
    hex_sel <= in_hex1 when sel = "111" else
               in_hex2 when sel = "110" else
               in_hex3 when sel = "101" else
               in_hex4 when sel = "100" else
               in_hex5 when sel = "011" else
               in_hex6 when sel = "010" else
               in_hex7 when sel = "001" else
               in_hex8;
end architecture;