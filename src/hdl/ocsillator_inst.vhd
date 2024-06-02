library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.syn_parts.all;

entity oscillator_inst is
    Port (
        -- 100 MHz clk
        clk: in std_logic;
        -- Active high reset, should be handled in sync with other OSCs
        reset: in std_logic;
        -- sine, triangle, saw, square
        waveSel: in std_logic_vector(1 downto 0);
        -- Q9.7, adjust the increment for sample data
        phaseInc: in unsigned(15 downto 0);
        -- read's next sample
        nextSample: in std_logic;
        -- Signed PCM data
        wavformOut: out signed(15 downto 0)
    );
end oscillator_inst;

architecture implementation of oscillator_inst is
    signal LUTAddr: std_logic_vector(10 downto 0);
    signal sampleCount, counterPhase: unsigned(17 downto 0); -- Q11.7
    signal counterCtrl: std_logic_vector(1 downto 0);
    signal LUTPiano, LUTGuitar, LUTViolin, LUTKalimba: std_logic_vector(15 downto 0);
    signal piano, guitar, violin, kalimba: signed(15 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Waveform Mux: selects the desired waveform using 'waveSel' signal
    ----------------------------------------------------------------------------
    wavformOut <= 
        piano when waveSel = "00" else
        guitar when waveSel = "01" else
        violin when waveSel = "10" else
        kalimba when waveSel = "11" else
        (others => '0');
    
    ----------------------------------------------------------------------------
    -- Sample Counter: increments when nextSample is high by the phaseInc value.
    ----------------------------------------------------------------------------
    counterPhase <= "00" & phaseInc;
    counterCtrl <= nextSample & '0';
    sample_counter: counter
    generic map (
        WIDTH => 18 -- Q11.7
    )
    port map (
        clk => clk,
        reset => reset,
        cw => counterCtrl,
        D => counterPhase,
        count => sampleCount
    );
    LUTAddr <= std_logic_vector(sampleCount(17 downto 7)); 

    ----------------------------------------------------------------------------
    -- Piano wave: Grabs sample from look up table via sample count index
    ----------------------------------------------------------------------------
    piano_wave_generator: entity work.piano_lut
    generic map (
        DEPTH => 2048,
        WIDTH => 16
    )
    port map (
        clk => clk,
        addr => LUTAddr,
        dout => LUTPiano
    );

    guitar_wave_generator: entity work.guitar_lut
    generic map (
        DEPTH => 2048,
        WIDTH => 16
    )
    port map (
        clk => clk,
        addr => LUTAddr,
        dout => LUTGuitar
    );

    violin_wave_generator: entity work.violin_lut
    generic map (
        DEPTH => 2048,
        WIDTH => 16
    )
    port map (
        clk => clk,
        addr => LUTAddr,
        dout => LUTViolin
    );

    kalimba_wave_generator: entity work.kalimba_lut
    generic map (
        DEPTH => 2048,
        WIDTH => 16
    )
    port map (
        clk => clk,
        addr => LUTAddr,
        dout => LUTKalimba
    );

    piano <= signed(LUTPiano);
    guitar <= signed(LUTGuitar);
    violin <= signed(LUTViolin);
    kalimba <= signed(LUTKalimba);

end implementation;
