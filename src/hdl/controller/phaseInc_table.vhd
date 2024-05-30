library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package phaseInc_package is
    type phaseInc_table is array (0 to 87) of unsigned(15 downto 0);
    constant phaseIncs : phaseInc_table := (
        x"0049",
        x"004E",
        x"0052",
        x"0057",
        x"005D",
        x"0062",
        x"0068",
        x"006E",
        x"0075",
        x"007C",
        x"0083",
        x"008B",
        x"0093",
        x"009C",
        x"00A5",
        x"00AF",
        x"00BA",
        x"00C5",
        x"00D0",
        x"00DD",
        x"00EA",
        x"00F8",
        x"0107",
        x"0116",
        x"0127",
        x"0138",
        x"014B",
        x"015F",
        x"0174",
        x"018A",
        x"01A1",
        x"01BA",
        x"01D4",
        x"01F0",
        x"020E",
        x"022D",
        x"024E",
        x"0271",
        x"0296",
        x"02BE",
        x"02E8",
        x"0314",
        x"0343",
        x"0374",
        x"03A9",
        x"03E1",
        x"041C",
        x"045A",
        x"049D",
        x"04E3",
        x"052D",
        x"057C",
        x"05D0",
        x"0628",
        x"0686",
        x"06E9",
        x"0752",
        x"07C2",
        x"0838",
        x"08B5",
        x"093A",
        x"09C6",
        x"0A5B",
        x"0AF9",
        x"0BA0",
        x"0C51",
        x"0D0C",
        x"0DD3",
        x"0EA5",
        x"0F84",
        x"1071",
        x"116B",
        x"1274",
        x"138D",
        x"14B7",
        x"15F2",
        x"1740",
        x"18A2",
        x"1A19",
        x"1BA6",
        x"1D4B",
        x"1F09",
        x"20E2",
        x"22D6",
        x"24E8",
        x"271A",
        x"296E",
        x"2BE4"
    );
end package phaseInc_package;
