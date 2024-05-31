library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.syn_parts.all;

entity syn_core3x is
port (
        -- 100 Mhz System Clock
        clk: in std_logic;
        reset: in std_logic;
        -- 12 16 bit signals LSB = op1
        opPhase1: in unsigned(191 downto 0);
        opPhase2 : in unsigned(191 downto 0);
        opPhase3 : in unsigned(191 downto 0);

        ampl2 : in signed(7 downto 0);
        ampl3 : in signed(7 downto 0);
        -- one hot encoding note on/off
        opEnable: in std_logic_vector(11 downto 0);
        -- ADSR for the operators
        att, dec, sus, rel: in signed(7 downto 0);
        -- Master amplitude
        ampl_master: in signed(7 downto 0);
        -- DAC Next Sample
        nextSample: in std_logic;
        -- 16 bit audio data
        audioOut: out signed(15 downto 0);
        waveSel: in std_logic_vector(5 downto 0)
);
end syn_core3x;

architecture implementation of syn_core3x is
    type signed_vector is array (0 to 11) of signed(15 downto 0);
    signal opSigOutVec: signed_vector;
begin

    gen_operators3x: for i in 0 to 11 generate
        operator_inst: entity work.operator3x
        port map (
            clk => clk,
            reset => reset,
            nextSample => nextSample,
            waveSel => waveSel,
            base_phaseInc => opPhase1(16*i+15 downto 16*i),
            second_phaseInc => opPhase2(16*i+15 downto 16*i),
            third_phaseInc => opPhase3(16*i+15 downto 16*i),
            second_amplitude => ampl2,
            third_amplitude => ampl3,
            att => att,
            dec => dec,
            sus => sus,
            rel => rel,
            en => opEnable(i),
            sigOut => opSigOutVec(i)
        );
    end generate;

    mix_inst: mixer
    generic map (
        ACTIVE_CHANNELS => 12,
        DATA_WIDTH => 16
    )
    port map (
        clk => clk,
        reset => reset,
        amplitude => ampl_master,
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
