library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity core_top_tb is
end core_top_tb;

architecture test of core_top_tb is

    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant DATA_WIDTH : integer := 16;
    constant PHASE_CALC: integer := ((392 * 2**19) / 48000);

    -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal BTNU : std_logic := '0';
    signal BTND : std_logic := '0';
    signal BTNL : std_logic := '0';
    signal BTNR : std_logic := '0';
    signal commonPhaseInc : unsigned(15 downto 0) := to_unsigned(PHASE_CALC, 16);
    signal audio_out : signed(DATA_WIDTH-1 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.core_top
        port map (
            clk => clk,
            reset => reset,
            BTNU => BTNU,
            BTND => BTND,
            BTNL => BTNL,
            BTNR => BTNR,
            commonPhaseInc => commonPhaseInc,
            audio_out => audio_out
        );

    -- Clock generation
    clk_process :process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Simulate nextSample signal process
    nextSample_process : process
    begin
        while true loop
            wait for 3 * CLK_PERIOD;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Simulate button presses
        BTNU <= '1';
        wait for 10000 ns;
        BTNU <= '0';
        
        BTND <= '1';
        wait for 10000 ns;
        BTND <= '0';

        BTNL <= '1';
        wait for 100 ns;
        BTNL <= '0';

        BTNR <= '1';
        wait for 10000 ns;
        BTNR <= '0';

        -- Run for a while to observe waveform
        wait for 1 ms;

        -- End simulation
        wait;
    end process;

end test;
