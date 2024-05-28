

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.skrach_parts.all;

entity skrach_core is
port (
        -- 100 Mhz System Clock
        clk: in std_logic;
        -- Active low reset
        reset: in std_logic;
        -- 12 16 bit signals LSB = op1
        opPhase: in unsigned(191 downto 0);
        -- one hot encoding note on/off
        opEnable: in std_logic_vector(11 downto 0);
        -- ADSR for the operators
        att, dec, sus, rel: in signed(7 downto 0);
        -- Master amplitude
        ampl: in signed(7 downto 0);
        -- DAC Next Sample
        nextSample: in std_logic;
        -- 16 bit audio data
        audioOut: out signed(15 downto 0);
        opWaveSel: in std_logic_vector(23 downto 0)
);
end skrach_core;

architecture implementation of skrach_core is
    type signed_vector is array (0 to 11) of signed(15 downto 0);
    signal opSigOutVec: signed_vector;
begin

     op1 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(1 downto 0),
        phaseInc => opPhase(15 downto 0),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(0),
        sigOut => opSigOutVec(0)
    );
    
    op2 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(3 downto 2),
        phaseInc => opPhase(31 downto 16),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(1),
        sigOut => opSigOutVec(1)
    );
    
    op3 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(5 downto 4),
        phaseInc => opPhase(47 downto 32),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(2),
        sigOut => opSigOutVec(2)
    );
    
    op4 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(7 downto 6),
        phaseInc => opPhase(63 downto 48),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(3),
        sigOut => opSigOutVec(3)
    );
    
    op5 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(9 downto 8),
        phaseInc => opPhase(79 downto 64),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(4),
        sigOut => opSigOutVec(4)
    );
    
    op6 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(11 downto 10),
        phaseInc => opPhase(95 downto 80),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(5),
        sigOut => opSigOutVec(5)
    );
    
    op7 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(13 downto 12),
        phaseInc => opPhase(111 downto 96),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(6),
        sigOut => opSigOutVec(6)
    );
    
    op8 : operator
    port map (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => opWaveSel(15 downto 14),
        phaseInc => opPhase(127 downto 112),
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => opEnable(7),
        sigOut => opSigOutVec(7)
    );
    
   op9 : operator
   port map (
       clk => clk,
       reset => reset,
       nextSample => nextSample,
       waveSel => opWaveSel(17 downto 16),
       phaseInc => opPhase(143 downto 128),
       att => att,
       dec => dec,
       sus => sus,
       rel => rel,
       en => opEnable(8),
       sigOut => opSigOutVec(8)
   );
    
   op10 : operator
   port map (
       clk => clk,
       reset => reset,
       nextSample => nextSample,
       waveSel => opWaveSel(19 downto 18),
       phaseInc => opPhase(159 downto 144),
       att => att,
       dec => dec,
       sus => sus,
       rel => rel,
       en => opEnable(9),
       sigOut => opSigOutVec(9)
   );
    
   op11 : operator
   port map (
       clk => clk,
       reset => reset,
       nextSample => nextSample,
       waveSel => opWaveSel(21 downto 20),
       phaseInc => opPhase(175 downto 160),
       att => att,
       dec => dec,
       sus => sus,
       rel => rel,
       en => opEnable(10),
       sigOut => opSigOutVec(10)
   );
    
   op12 : operator
   port map (
       clk => clk,
       reset => reset,
       nextSample => nextSample,
       waveSel => opWaveSel(23 downto 22),
       phaseInc => opPhase(191 downto 176),
       att => att,
       dec => dec,
       sus => sus,
       rel => rel,
       en => opEnable(11),
       sigOut => opSigOutVec(11)
 );
    mix_inst: mixer
    generic map (
        ACTIVE_CHANNELS => 1,
        DATA_WIDTH => 16
    )
    port map (
        clk => clk,
        reset => reset,
        amplitude => ampl,
        ch1 => opSigOutVec(0),
        ch2 => opSigOutVec(1),
        ch3 => opSigOutVec(2),
        ch4 => opSigOutVec(3),
        ch5 => opSigOutVec(4),
        ch6 => opSigOutVec(5),
        ch7 => opSigOutVec(6),
        ch8 => opSigOutVec(7),
        ch9 => opSigOutVec(8),
        ch10 => opSigOutVec(9),
        ch11 => opSigOutVec(10),
        ch12 => opSigOutVec(11),
        sigOut => audioOut
    );


end implementation;
