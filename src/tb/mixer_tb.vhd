library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mixer_tb is
end mixer_tb;

architecture test of mixer_tb is

    constant DATA_WIDTH : integer := 16;
    constant CLK_PERIOD : time := 1 ns;

    signal clk : std_logic := '0';
    --signal reset : std_logic := '0';
    signal amplitude : signed(7 downto 0) := (others => '0');
    signal ch1, ch2, ch3 : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ch4, ch5, ch6, ch7, ch8, ch9, ch10, ch11, ch12 : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal sigOut : signed(DATA_WIDTH-1 downto 0);

    -- Instantiate the mixer
    component mixer is
        generic (
            ACTIVE_CHANNELS : integer := 10;
            DATA_WIDTH: integer := 16
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            amplitude: in signed(7 downto 0);
            ch1, ch2, ch3, ch4,
            ch5, ch6, ch7, ch8,
            ch9, ch10, ch11, ch12 : in signed(DATA_WIDTH-1 downto 0);
            sigOut : out signed(DATA_WIDTH-1 downto 0)
        );
    end component;

begin

    uut: mixer
        generic map (
            ACTIVE_CHANNELS => 3,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            --reset_n => reset_n,
            amplitude => amplitude,
            ch1 => ch1,
            ch2 => ch2,
            ch3 => ch3,
            ch4 => ch4,
            ch5 => ch5,
            ch6 => ch6,
            ch7 => ch7,
            ch8 => ch8,
            ch9 => ch9,
            ch10 => ch10,
            ch11 => ch11,
            ch12 => ch12,
            sigOut => sigOut
        );

    -- Clock generation
    clk_process :process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Reset process and waveform generation
    stim_proc: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        amplitude <= to_signed(127, 8);  -- Set amplitude to 127 (max value for 8-bit signed number)
        wait for 20 ns;

        -- Generate test waveforms with shorter periods and multiple cycles
        for j in 0 to 4 loop  -- Loop to create multiple cycles
            for i in 0 to 63 loop  -- Shorter period
                -- Triangle wave for ch1
                if i < 32 then
                    ch1 <= to_signed(i * 1024, DATA_WIDTH);
                else
                    ch1 <= to_signed((63 - i) * 1024, DATA_WIDTH);
                end if;

                -- Sawtooth wave for ch2
                ch2 <= to_signed(i * 1024, DATA_WIDTH);

                -- Square wave for ch3
                if i < 32 then
                    ch3 <= to_signed(32767, DATA_WIDTH);  -- Max positive value for 16-bit signed number
                else
                    ch3 <= to_signed(-32768, DATA_WIDTH); -- Max negative value for 16-bit signed number
                end if;

                wait for CLK_PERIOD;
            end loop;
        end loop;

        wait;
    end process;

end architecture test;
