library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity anode_driver is
    port (
        clk : in std_logic;
        en : in std_logic;
        rst : in std_logic;
        sel : out std_logic_vector(7 downto 0);
        cnt : out std_logic_vector(2 downto 0)
    );
end anode_driver;

architecture arch of anode_driver is
    signal q_reg, q_next : std_logic_vector(2 downto 0);
begin
    process (clk, rst) is
    begin
        if rst = '1' then
            q_reg <= "000";
        elsif clk'event and clk = '1' and en = '1' then
            q_reg <= q_next;
        end if;
    end process;

    q_next <= q_reg - 1;
    
    -- sel <= "00000001" when q_reg = "000" else
    --        "00000010" when q_reg = "001" else
    --        "00000100" when q_reg = "010" else
    --        "00001000" when q_reg = "011" else
    --        "00010000" when q_reg = "100" else
    --        "00100000" when q_reg = "101" else
    --        "01000000" when q_reg = "110" else
    --        "10000000" when q_reg = "111" else
    --        "00000000";
    sel <= "01111111" when q_reg = "111" else
           "10111111" when q_reg = "110" else
           "11011111" when q_reg = "101" else
           "11101111" when q_reg = "100" else
           "11110111" when q_reg = "011" else
           "11111011" when q_reg = "010" else
           "11111101" when q_reg = "001" else
           "11111110" when q_reg = "000" else
           "00000000";
    cnt <= q_reg;

end architecture;