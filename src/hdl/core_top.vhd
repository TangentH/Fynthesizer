library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.skrach_parts.all;

entity core_top is
    port (
        clk: in std_logic;
        reset: in std_logic;
        commonPhaseInc: in unsigned(15 downto 0); -- Common phase increment for all operators
        opEnable: in std_logic_vector(11 downto 0);
        att, dec, sus, rel: in signed(7 downto 0);
        ampl: in signed(7 downto 0);
        nextSample: in std_logic;
        audioOut: out signed(15 downto 0);
        opWaveSel: in std_logic_vector(23 downto 0)
    );
end core_top;

architecture behavior of core_top is
    -- Internal signals
    signal fullPhaseInc: unsigned(191 downto 0);
begin

    -- Generate full phase increment signal by replicating commonPhaseInc
    gen_fullPhaseInc: for i in 0 to 11 generate
        fullPhaseInc((i+1)*16-1 downto i*16) <= commonPhaseInc;
    end generate;

    -- Instantiate skrach_core with the newly generated fullPhaseInc
    core_inst: entity work.skrach_core
        port map (
            clk => clk,
            reset => reset,
            opPhase => fullPhaseInc,  -- Using the replicated phase increments
            opEnable => opEnable,
            att => att,
            dec => dec,
            sus => sus,
            rel => rel,
            ampl => ampl,
            nextSample => nextSample,
            audioOut => audioOut,
            opWaveSel => opWaveSel
        );

end behavior;
