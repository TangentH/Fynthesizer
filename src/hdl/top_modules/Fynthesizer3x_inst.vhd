library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fynthesizer3x_inst is
    port (
        clk : in std_logic;
        rst : in std_logic;
        uart_rxd_in : in std_logic;
        anode : out std_logic_vector(7 downto 0);
        cathode : out std_logic_vector(6 downto 0);
        volume_visualizer_out : out std_logic_vector(15 downto 0);
        -- phaseInc : out unsigned(15 downto 0);  -- New output port for phaseInc
        pwm_out : out std_logic;
        pwm_sd : out std_logic
    );
end Fynthesizer3x_inst;

architecture rtl of Fynthesizer3x_inst is
    -- Components declaration
    component midi_decoder is
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            uart_rxd : in STD_LOGIC;
            midi_data : out STD_LOGIC_VECTOR(23 downto 0);
            data_ready : out STD_LOGIC
        );
    end component;

    component sevenSegDisplay is
        port (
            clk : in std_logic;
            rst : in std_logic;
            midi_msg : in std_logic_vector(23 downto 0);
            anode : out std_logic_vector(7 downto 0);
            cathode : out std_logic_vector(6 downto 0)
        );
    end component;

    component note_control3x is
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            note_on : in STD_LOGIC;
            note_off : in STD_LOGIC;
            note_value : in STD_LOGIC_VECTOR(7 downto 0);
            note_offset2 : in SIGNED(7 downto 0);
            note_offset3 : in SIGNED(7 downto 0);
            en : out STD_LOGIC_VECTOR(11 downto 0);
            phaseInc_base : out UNSIGNED(191 downto 0);
            phaseInc_second : out UNSIGNED(191 downto 0);
            phaseInc_third : out UNSIGNED(191 downto 0)
        );
    end component;

    component syn_core3x_inst is
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
    end component;

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

    component audio_level_meter is
        generic (
            DATA_WIDTH : integer := 16
        );
        port (
            audio_in : in signed(DATA_WIDTH-1 downto 0);
            level_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;


    -- Internal signals
    signal midi_data : std_logic_vector(23 downto 0);
    signal note_on : std_logic;
    signal note_off : std_logic;
    signal note_offset2 : signed(7 downto 0);
    signal note_offset3 : signed(7 downto 0);
    signal note_value : std_logic_vector(7 downto 0);
    signal en_reg : std_logic_vector(11 downto 0);
    signal phaseInc_base_reg : unsigned(191 downto 0);
    signal phaseInc_second_reg : unsigned(191 downto 0);
    signal phaseInc_third_reg : unsigned(191 downto 0);
    signal ampl_second : signed(7 downto 0);
    signal ampl_third : signed(7 downto 0);
    signal nextSample : std_logic;
    signal counter: integer range 0 to 2**10-1 := 0;
    signal audio : signed(15 downto 0);
    signal midi_received : std_logic;
    signal att, dec, rel : signed(7 downto 0) := (to_signed(0,8));
    signal sus, master_volume : signed(7 downto 0) := (to_signed(90,8));
    signal wave_sel : std_logic_vector(5 downto 0) := (others => '0');


begin
    midi_decoder_inst : midi_decoder
        port map (
            clk => clk,
            reset => rst,
            uart_rxd => uart_rxd_in,
            midi_data => midi_data,
            data_ready => midi_received
        );

    sevenSegDisplay_inst : sevenSegDisplay
        port map (
            clk => clk,
            rst => rst,
            midi_msg => midi_data,
            anode => anode,
            cathode => cathode
        );

    note_control_inst : note_control3x
        port map (
            clk => clk,
            reset => rst,
            note_on => note_on,
            note_off => note_off,
            note_value => note_value,
            note_offset2 => note_offset2,
            note_offset3 => note_offset3,
            en => en_reg,
            phaseInc_base => phaseInc_base_reg,
            phaseInc_second => phaseInc_second_reg,
            phaseInc_third => phaseInc_third_reg
        );

    core_inst : syn_core3x_inst
        port map (
            clk => clk,
            reset => rst,
            opPhase1 => phaseInc_base_reg,
            opPhase2 => phaseInc_second_reg,
            opPhase3 => phaseInc_third_reg,

            ampl2 => ampl_second,
            ampl3 => ampl_third,

            opEnable => en_reg,
            att => att,
            dec => dec,
            sus => sus,
            rel => rel,
            ampl_master => master_volume,
            nextSample => nextSample,
            audioOut => audio,
            waveSel => wave_sel
        );

    audio_level_meter_inst : audio_level_meter
        generic map(
            DATA_WIDTH => 16
        )
        port map(
            audio_in => audio,
            level_out => volume_visualizer_out
        );

    pwm_enc_inst: pwm_enc
        generic map(
            pwm_period => to_unsigned(4096,16)
        )
        port map(
            clk => clk,
            rst => rst,
            audio_amplitude => audio,
            pwm_out => pwm_out
        );

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

    -- Signal assignment
    -- led_out <= audio;
    pwm_sd <= '1'; -- amplify the output audio

    process(clk, midi_received)
    begin
        if rising_edge(clk) then
            if midi_received = '1' then
                if midi_data(23 downto 16) = x"90" then
                    -- Note On
                    note_on <= '1';
                    note_off <= '0';
                    note_value <= midi_data(15 downto 8);
                elsif midi_data(23 downto 16) = x"80" then
                    -- Note Off
                    note_on <= '0';
                    note_off <= '1';
                    note_value <= midi_data(15 downto 8);
                elsif midi_data(23 downto 16) = x"B0" then
                    -- Control Change
                    note_on <= '0';
                    note_off <= '0';
                    case midi_data(15 downto 8) is
                        when x"01" =>
                        -- change master volume
                            master_volume <= signed(midi_data(7 downto 0));
                        when x"0E" =>
                        -- attack
                            att <= signed(midi_data(7 downto 0));
                        when x"0F" =>
                        -- decay
                            dec <= signed(midi_data(7 downto 0));
                        when x"10" =>
                        -- sustain
                            sus <= signed(midi_data(7 downto 0));
                        when x"11" =>
                        -- release
                            rel <= signed(midi_data(7 downto 0));
                        when x"12" => 
                        -- note offset for second oscillators
                            note_offset2 <= signed(midi_data(7 downto 0))+to_signed(-64,8);
                        when x"13" =>
                        -- amplitude for second oscillators
                            ampl_second <= signed(midi_data(7 downto 0));
                        when x"14" =>
                        -- note offset for third oscillators
                            note_offset3 <= signed(midi_data(7 downto 0))+to_signed(-64,8);
                        when x"15" => 
                        -- amplitude for third oscillators
                            ampl_third <= signed(midi_data(7 downto 0));
                        when x"16" =>
                        -- waveform for base oscillators
                            wave_sel(5 downto 4) <= midi_data(1 downto 0);
                        when x"17" => 
                        -- waveform for second oscillators
                            wave_sel(3 downto 2) <= midi_data(1 downto 0);
                        when x"18" => 
                        -- waveform for third oscillators
                            wave_sel(1 downto 0) <= midi_data(1 downto 0);
                        when others =>
                            null;
                    end case;
                end if;
            else
                note_on <= '0';
                note_off <= '0';
            end if;
        end if;
    end process;

end architecture;