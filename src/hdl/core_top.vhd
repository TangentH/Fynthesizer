library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.syn_parts.all;

entity core_top is
    port (
        clk: in std_logic;
        reset: in std_logic;
        BTNU, BTND, BTNL, BTNR: in std_logic; -- Buttons for enabling operators
        commonPhaseInc: in unsigned(15 downto 0); -- Common phase increment for all operators
        audio_out: out signed(15 downto 0); -- Output audio signal
        pwm_out : out std_logic; -- Output PWM signal
        pwm_sd : out std_logic -- amplify
    );
end core_top;

architecture behavior of core_top is
    -- Internal signals
    signal fullPhaseInc: unsigned(191 downto 0); -- For 12 operators
    signal opEnable: std_logic_vector(11 downto 0) := (others => '0');
    signal nextSample: std_logic;
    signal att, dec, sus, rel: signed(7 downto 0);
    signal ampl: signed(7 downto 0);
    signal opWaveSel: std_logic_vector(23 downto 0);
    signal counter: integer := 0;
    signal audio : signed(15 downto 0);

    component pwm_enc is
        generic(
            pwm_period : UNSIGNED(15 downto 0) := x"FFFF"
        );
        port(
            clk: in std_logic;
            rst : in std_logic;
            audio_amplitude : in signed(15 downto 0);
            pwm_out : out std_logic
        );
    end component;

begin

    -- Manually assign commonPhaseInc to each 16-bit segment of fullPhaseInc for the first 4 operators
    fullPhaseInc(15 downto 0)   <= commonPhaseInc;
    fullPhaseInc(31 downto 16)  <= commonPhaseInc;
    fullPhaseInc(47 downto 32)  <= commonPhaseInc;
    fullPhaseInc(63 downto 48)  <= commonPhaseInc;
    fullPhaseInc(79 downto 64)  <= (others => '0');
    fullPhaseInc(95 downto 80)  <= (others => '0');
    fullPhaseInc(111 downto 96) <= (others => '0');
    fullPhaseInc(127 downto 112) <= (others => '0');
    fullPhaseInc(143 downto 128) <= (others => '0');
    fullPhaseInc(159 downto 144) <= (others => '0');
    fullPhaseInc(175 downto 160) <= (others => '0');
    fullPhaseInc(191 downto 176) <= (others => '0');

    -- Set wave selection for 4 operators: 00, 01, 10, 11
    opWaveSel <= "000000000000000011100100";

    -- ADSR values
    att <= to_signed(64, 8);
    dec <= to_signed(64, 8);
    sus <= to_signed(64, 8);
    rel <= to_signed(127, 8);

    -- Maximum amplitude
    ampl <= to_signed(127, 8);

    -- Control enable signals for operators based on button inputs
    process (BTNU, BTND, BTNL, BTNR)
    begin
        opEnable(0) <= BTNU;
        opEnable(1) <= BTND;
        opEnable(2) <= BTNL;
        opEnable(3) <= BTNR;
        for i in 4 to 11 loop
            opEnable(i) <= '0';
        end loop;
    end process;

    -- Generate nextSample signal
    process (clk)
    begin
        if rising_edge(clk) then
            if counter = 2**10-1 then
                nextSample <= '1';
                counter <= 0;
            else
                nextSample <= '0';
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Instantiate syn_core with the newly generated fullPhaseInc and control signals
    core_inst: entity work.syn_core
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
            audioOut => audio,
            opWaveSel => opWaveSel
        );

    pwm_enc_inst: pwm_enc
        generic map(
            pwm_period => to_unsigned(4096,16)
        )
        port map(
            clk => clk,
            rst => reset,
            audio_amplitude => audio,
            pwm_out => pwm_out
        );

    audio_out <= audio;
    pwm_sd <= '1';

end behavior;

