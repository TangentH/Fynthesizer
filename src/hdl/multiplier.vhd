library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier is
    generic (
        WIDTH_A : integer := 16;  -- Width of input A
        WIDTH_B : integer := 8;   -- Width of input B
        WIDTH_P : integer := 24   -- Width of output P
    );
    port (
        A : in  signed(WIDTH_A-1 downto 0);
        B : in  signed(WIDTH_B-1 downto 0);
        P : out signed(WIDTH_P-1 downto 0);
        CLK : in std_logic;  -- Clock input
        RST : in std_logic   -- Reset input
    );
end Multiplier;

architecture Behavioral of Multiplier is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            P <= (others => '0');
        elsif rising_edge(CLK) then
            P <= A * B;
        end if;
    end process;
end Behavioral;
