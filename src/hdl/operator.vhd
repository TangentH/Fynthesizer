library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.syn_parts.all;

entity operator is
    Port (
        clk: in std_logic;
        reset: in std_logic;
        nextSample: in std_logic;
        waveSel: in std_logic_vector(1 downto 0);
        phaseInc: in unsigned(15 downto 0);
        att, dec, sus, rel: in signed(7 downto 0);
        en: in std_logic;
        sigOut: out signed(15 downto 0)
    );
end operator;

architecture implementation of operator is
    signal oscOut: signed(15 downto 0);
begin

    osc_inst: oscillator
    port map (
        -- 100 MHz clk
        clk => clk,
        -- Active low reset, should be handled in sync with other OSCs
        reset => reset,
        -- sine, triangle, saw, square
        waveSel => waveSel,
        -- Q9.7, adjust the increment for sample data
        phaseInc => phaseInc,
        -- read's next sample
        nextSample => nextSample,
        -- Signed PCM data
        wavformOut => oscOut
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
        signalIn => oscOut,
        signalOut => sigOut
    );


end implementation;
