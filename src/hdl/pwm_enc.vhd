library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_enc is
    generic (
        pwm_period : UNSIGNED(15 downto 0) := x"FFFF" -- Default period of the PWM signal in clock cycles
    );
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        audio_amplitude : in SIGNED(15 downto 0); -- Audio amplitude as a signed value
        pwm_out : out STD_LOGIC -- PWM output signal
    );
end pwm_enc;

architecture Behavioral of pwm_enc is
    constant OFFSET : SIGNED(16 downto 0) := to_signed(32768, 17); -- Offset to move the amplitude range to positive
    signal amplitude_shifted : SIGNED(16 downto 0); -- Shifted amplitude
    signal amplitude_unsigned : UNSIGNED(15 downto 0); -- Unsigned version of shifted amplitude
    signal duty_cycle : UNSIGNED(15 downto 0); -- Calculated duty cycle
    signal pwm_counter : UNSIGNED(15 downto 0); -- Counter for PWM period
begin

    process(clk, rst)
    begin
        if rst = '1' then
            amplitude_shifted <= (others => '0');
            amplitude_unsigned <= (others => '0');
            duty_cycle <= (others => '0');
            pwm_counter <= (others => '0');
            pwm_out <= '0';
        elsif rising_edge(clk) then
            -- Shift the amplitude by adding the OFFSET
            amplitude_shifted <= resize(audio_amplitude,17) + OFFSET;

            -- Convert shifted amplitude to unsigned
            amplitude_unsigned <= resize(unsigned(amplitude_shifted),16);

            -- Calculate duty cycle based on shifted and converted amplitude
            duty_cycle <= resize((resize(amplitude_unsigned, 16) * pwm_period) srl 16, 16); -- Equivalent to division by 65535

            -- PWM generation logic
            if pwm_counter < duty_cycle then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;

            -- Increment PWM counter
            if pwm_counter = pwm_period then
                pwm_counter <= (others => '0');
            else
                pwm_counter <= pwm_counter + 1;
            end if;
        end if;
    end process;
end Behavioral;
