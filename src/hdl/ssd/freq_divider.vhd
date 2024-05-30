library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;    -- for the "+" operator in std_logic_vector

entity freq_divider is
    port (
        clk100mhz : in std_logic;
        rst : in std_logic;
        pulse8khz : out std_logic
    );
end freq_divider;

architecture arch of freq_divider is
    constant cnt_max : integer := 12500 - 1;
    signal q_reg, q_next : integer range 0 to cnt_max;
begin
    process(clk100mhz, rst) is
    begin
        if rst = '1' then
            q_reg <= 0;
        elsif clk100mhz'event and clk100mhz = '1' then
            q_reg <= q_next;
        end if;
    end process;

    q_next <= q_reg + 1 when q_reg < cnt_max else 0;
    pulse8khz <= '1' when q_reg = cnt_max else '0';
end architecture;