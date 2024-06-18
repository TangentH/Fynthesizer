library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_level_meter is
    generic (
        DATA_WIDTH : integer := 16
    );
    port (
        audio_in : in signed(DATA_WIDTH-1 downto 0);
        level_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end audio_level_meter;

architecture rtl of audio_level_meter is
    signal level : signed(DATA_WIDTH-1 downto 0);
begin
    process(audio_in)
    begin
        if audio_in > 0 then
            level <= audio_in;
        else
            level <= -audio_in;
        end if;
    end process;

    level_out <= std_logic_vector(level);
end architecture;