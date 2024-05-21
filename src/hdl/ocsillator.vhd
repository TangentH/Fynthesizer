library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Library UNISIM;
--use UNISIM.vcomponents.all;

--Library UNIMACRO;
--use UNIMACRO.vcomponents.all;

use work.skrach_parts.all;


entity oscillator is
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
end oscillator;

architecture implementation of oscillator is
    --signal reset: std_logic := not reset_n;
    signal LUTSine: std_logic_vector(15 downto 0);
    signal LUTAddr: std_logic_vector(10 downto 0);
    signal sine, saw, triangle, square: signed(15 downto 0) := to_signed(0, 16);
    signal sampleCount, counterPhase: unsigned(17 downto 0); -- Q11.7
    signal counterCtrl: std_logic_vector(1 downto 0);
    

begin

    ----------------------------------------------------------------------------
    -- Waveform Mux: selects the desired waveform using 'waveSel' signal
    ----------------------------------------------------------------------------
    wavformOut <= 
        sine when waveSel = "00" else
        triangle when waveSel = "01" else
        saw when waveSel = "10" else
        square when waveSel = "11" else
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
        --reset_n => reset_n,
        reset => reset,
        cw => counterCtrl,
        D => counterPhase,
        count => sampleCount
    );
    LUTAddr <= std_logic_vector(sampleCount(17 downto 7)); 
    ----------------------------------------------------------------------------
    -- Saw wave: Simply the sample counter's output 
    ----------------------------------------------------------------------------
    saw <= signed(sampleCount(17 downto 2) - 32768);
    
    ----------------------------------------------------------------------------
    -- Square wave: Low for 1024 samples, High for the other 1024
    ----------------------------------------------------------------------------
    -- if sample count < 1024, output min signed
    -- if sample count >= 1024. output max signed
    square <=
        to_signed(-32767, 16) when (sampleCount < 2**17) else
        to_signed(32767, 16);



    
    ----------------------------------------------------------------------------
    -- Triangle wave: 2 * phaseInc up for 1024 samples, down for the other 1024
    ----------------------------------------------------------------------------
       -- if sample count < 1024, increment
       -- if sample count >= 1024, decrement
    triangle <=
        (signed(sampleCount(16 downto 1) - 32767)) when sampleCount < 2**17 else
        (signed(32767 - sampleCount(16 downto 1)));


    ----------------------------------------------------------------------------
    -- Sine wave: Grabs sample from look up table via sample count index
    ----------------------------------------------------------------------------
   sine_wave_generator: entity work.sine_lut
    generic map (
        DEPTH => 2048,
        WIDTH => 16
    )
    port map (
        clk => clk,
        addr => LUTAddr,
        dout => LUTSine
    );

sine <= signed(LUTSine);
    
end implementation;
