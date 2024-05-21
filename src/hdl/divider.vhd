library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Divider is
    Generic (
        DIVISOR: integer := 4 -- Default divisor value
    );
    Port (
        clk: in std_logic;
        reset: in std_logic;
        enable: in std_logic;
        count_in: in unsigned(17 downto 0);
        count_out: out unsigned(17 downto 0)
    );
end Divider;

architecture Behavioral of Divider is
    signal internal_count: unsigned(17 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            internal_count <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                if internal_count = DIVISOR - 1 then
                    internal_count <= (others => '0');
                else
                    internal_count <= internal_count + 1;
                end if;
            end if;
        end if;
    end process;
    count_out <= count_in when internal_count = 0; 
end Behavioral;
