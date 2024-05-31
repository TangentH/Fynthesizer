library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.syn_parts.all;

entity operator3x is
    Port (
        clk: in std_logic;
        reset: in std_logic;
        nextSample: in std_logic;
        waveSel: in std_logic_vector(5 downto 0);
        base_phaseInc: in unsigned(15 downto 0);
        second_phaseInc: in unsigned(15 downto 0);
        third_phaseInc: in unsigned(15 downto 0);
        second_amplitude : in signed(7 downto 0);
        third_amplitude : in signed(7 downto 0);
        att, dec, sus, rel: in signed(7 downto 0);
        en: in std_logic;
        sigOut: out signed(15 downto 0)
    );
end operator3x;

architecture implementation of operator3x is
    signal oscOut1: signed(15 downto 0);
    signal oscOut2: signed(15 downto 0);
    signal oscOut3: signed(15 downto 0);
    signal oscOut2_resize: signed(15 downto 0);
    signal oscOut3_resize: signed(15 downto 0);

    signal oscOut_all : signed(15 downto 0);

begin

    osc_inst_1: oscillator
    port map (
        -- 100 MHz clk
        clk => clk,
        -- Active low reset, should be handled in sync with other OSCs
        reset => reset,
        -- sine, triangle, saw, square
        waveSel => waveSel(5 downto 4),
        -- Q9.7, adjust the increment for sample data
        phaseInc => base_phaseInc,
        -- read's next sample
        nextSample => nextSample,
        -- Signed PCM data
        wavformOut => oscOut1
    );

    
    osc_inst_2: oscillator
    port map (
        -- 100 MHz clk
        clk => clk,
        -- Active low reset, should be handled in sync with other OSCs
        reset => reset,
        -- sine, triangle, saw, square
        waveSel => waveSel(3 downto 2),
        -- Q9.7, adjust the increment for sample data
        phaseInc => second_phaseInc,
        -- read's next sample
        nextSample => nextSample,
        -- Signed PCM data
        wavformOut => oscOut2
    );

    osc_inst_3: oscillator
    port map (
        -- 100 MHz clk
        clk => clk,
        -- Active low reset, should be handled in sync with other OSCs
        reset => reset,
        -- sine, triangle, saw, square
        waveSel => waveSel(1 downto 0),
        -- Q9.7, adjust the increment for sample data
        phaseInc => third_phaseInc,
        -- read's next sample
        nextSample => nextSample,
        -- Signed PCM data
        wavformOut => oscOut3
    );

    mix_inst_2: mixer
    generic map (
        ACTIVE_CHANNELS => 1,
        DATA_WIDTH => 16
    )
    port map (
        clk => clk,
        reset => reset,
        amplitude => second_amplitude,
        ch1 => oscOut2,
        ch2 => (others => '0'),
        ch3 => (others => '0'),
        ch4 => (others => '0'),
        ch5 => (others => '0'),
        ch6 => (others => '0'),
        ch7 => (others => '0'),
        ch8 => (others => '0'),
        ch9 => (others => '0'),
        ch10 => (others => '0'),
        ch11 => (others => '0'),
        ch12 => (others => '0'),
        sigOut => oscOut2_resize
    );

    mix_inst_3: mixer
    generic map (
        ACTIVE_CHANNELS => 1,
        DATA_WIDTH => 16
    )
    port map (
        clk => clk,
        reset => reset,
        amplitude => third_amplitude,
        ch1 => oscOut3,
        ch2 => (others => '0'),
        ch3 => (others => '0'),
        ch4 => (others => '0'),
        ch5 => (others => '0'),
        ch6 => (others => '0'),
        ch7 => (others => '0'),
        ch8 => (others => '0'),
        ch9 => (others => '0'),
        ch10 => (others => '0'),
        ch11 => (others => '0'),
        ch12 => (others => '0'),
        sigOut => oscOut3_resize
    );

    mix_inst_all : mixer
    generic map (
        ACTIVE_CHANNELS => 3,
        DATA_WIDTH => 16
    )
    port map (
        clk => clk,
        reset => reset,
        amplitude => to_signed(127, 8),
        ch1 => oscOut1,
        ch2 => oscOut2_resize,
        ch3 => oscOut3_resize,
        ch4 => (others => '0'),
        ch5 => (others => '0'),
        ch6 => (others => '0'),
        ch7 => (others => '0'),
        ch8 => (others => '0'),
        ch9 => (others => '0'),
        ch10 => (others => '0'),
        ch11 => (others => '0'),
        ch12 => (others => '0'),
        sigOut => oscOut_all
    );
    
    
    adsr_inst: adsr
    generic map(16)
    port map (
        clk => clk,
        reset => reset,
        en => en,
        nextSample => nextSample,
        attack => att,
        decay => dec,
        sustain => sus,
        rel => rel,
        signalIn => oscOut_all,
        signalOut => sigOut
    );


end implementation;
