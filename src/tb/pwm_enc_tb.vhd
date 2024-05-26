library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity pwm_enc_tb is
end pwm_enc_tb;

architecture sim of pwm_enc_tb is

    constant clk_hz : integer := 1e8;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal audio_amplitude_tb : signed(15 downto 0) := (others => '0');
    signal pwm_out_tb : std_logic := '0';
    signal count : integer := 0;
begin

    clk <= not clk after clk_period / 2;
    count <=  count + 1 after clk_period;

    DUT : entity work.pwm_enc(Behavioral)
    generic map (
        pwm_period => to_unsigned(15,16)
    )
    port map (
        clk => clk,
        rst => rst,
        audio_amplitude => audio_amplitude_tb,
        pwm_out => pwm_out_tb
    );

    SEQUENCER_PROC : process
    begin
        wait for 2 ns;

        rst <= '0';

        wait for clk_period * 20;
        audio_amplitude_tb <= to_signed(2**15 - 1, 16);
        wait for clk_period * 20;
        audio_amplitude_tb <= to_signed(2**13 - 1, 16);
        wait for clk_period * 20;
        audio_amplitude_tb <= to_signed(-2**15, 16);
        wait for clk_period * 20;
        audio_amplitude_tb <= to_signed(-2**13, 16);
        wait for clk_period * 20;
        audio_amplitude_tb <= to_signed(2**14, 16);


    end process;

end architecture;