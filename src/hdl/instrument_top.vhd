library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.syn_parts.all;

entity instrument_top is
    port (
        clk: in std_logic;
        reset: in std_logic;
        BTNU, BTND, BTNL, BTNR: in std_logic; -- Buttons for enabling operators and adjusting ADSR values
        commonPhaseInc: in unsigned(15 downto 0); -- Common phase increment for all operators
        audio_out: out signed(15 downto 0); -- Output audio signal
        pwm_out : out std_logic; -- Output PWM signal
        pwm_sd : out std_logic -- amplify
    );
end instrument_top;

architecture behavior of instrument_top is
    -- Internal signals
    signal fullPhaseInc: unsigned(191 downto 0); -- For 12 operators
    signal opEnable: std_logic_vector(11 downto 0) := (others => '0');
    signal nextSample: std_logic;
    signal att, dec, sus, rel: signed(7 downto 0);
    signal att_BTNU, dec_BTNU, sus_BTNU, rel_BTNU: signed(7 downto 0);
    signal att_BTND, dec_BTND, sus_BTND, rel_BTND: signed(7 downto 0);
    signal att_BTNL, dec_BTNL, sus_BTNL, rel_BTNL: signed(7 downto 0);
    signal att_BTNR, dec_BTNR, sus_BTNR, rel_BTNR: signed(7 downto 0);
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

    -- Default ADSR values for each button
    att_BTNU <= to_signed(4, 8);
    dec_BTNU <= to_signed(5, 8);
    sus_BTNU <= to_signed(32, 8);
    rel_BTNU <= to_signed(64, 8);

    att_BTND <= to_signed(2, 8);
    dec_BTND <= to_signed(1, 8);
    sus_BTND <= to_signed(32, 8);
    rel_BTND <= to_signed(127, 8);

    att_BTNL <= to_signed(96, 8);
    dec_BTNL <= to_signed(16, 8);
    sus_BTNL <= to_signed(32, 8);
    rel_BTNL <= to_signed(127, 8);

    att_BTNR <= to_signed(10, 8);
    dec_BTNR <= to_signed(16, 8);
    sus_BTNR <= to_signed(32, 8);
    rel_BTNR <= to_signed(96, 8);

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

    -- Update ADSR values based on button inputs
    process (clk)
    begin
        if rising_edge(clk) then
            -- Check and update ADSR values independently for each button
            if BTNU = '1' then
                att <= att_BTNU;
                dec <= dec_BTNU;
                sus <= sus_BTNU;
                rel <= rel_BTNU;
            end if;

            if BTND = '1' then
                att <= att_BTND;
                dec <= dec_BTND;
                sus <= sus_BTND;
                rel <= rel_BTND;
            end if;

            if BTNL = '1' then
                att <= att_BTNL;
                dec <= dec_BTNL;
                sus <= sus_BTNL;
                rel <= rel_BTNL;
            end if;

            if BTNR = '1' then
                att <= att_BTNR;
                dec <= dec_BTNR;
                sus <= sus_BTNR;
                rel <= rel_BTNR;
            end if;
        end if;
    end process;

    -- Maximum amplitude
    ampl <= to_signed(127, 8);

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
