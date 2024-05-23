library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity skrach_core_tb is
end skrach_core_tb;

architecture test of skrach_core_tb is

    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant DATA_WIDTH : integer := 16;
    constant PHASE_CALC: integer := ((392 * 2**19) / 48000);
    constant PHASE_CALC_2: integer := ((373 * 2**19) / 48000);

    -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal opPhase : unsigned(191 downto 0) := (others => '0');
    signal opEnable : std_logic_vector(11 downto 0) := (others => '0');
    signal att, dec, sus, rel : signed(7 downto 0) := (others => '0');
    signal ampl : signed(7 downto 0) := (others => '0');
    signal nextSample : std_logic := '0';
    signal audioOut : signed(DATA_WIDTH-1 downto 0);
    signal phaseInc : unsigned(15 downto 0) := to_unsigned(PHASE_CALC, 16);
    signal phaseInc2 : unsigned(15 downto 0) := to_unsigned(PHASE_CALC_2, 16);
    signal opWaveSel: std_logic_vector(23 downto 0):= (others => '0');
    
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.skrach_core
        port map (
            clk => clk,
            reset => reset,
            opPhase => opPhase,
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
            nextSample <= '0';
            wait for 100 ns;
            nextSample <= '1';
            wait for 100 ns;
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

        -- Set initial test conditions
        opEnable <= "000000000111";
        att <= to_signed(1, 8);
        dec <= to_signed(1, 8);
        sus <= to_signed(50, 8);
        rel <= to_signed(1, 8);
        ampl <= to_signed(127, 8);
        opPhase(15 downto 0) <= phaseInc;
        opPhase(31 downto 16) <= phaseInc2;

        -- Simulate key press duration
        wait for 8 us;
        opEnable <= "000000000000"; -- Note off, triggering release phase
        
        wait for 2 us;
        
        -- Disable the operator and finish the simulation
        opEnable <= (others => '0');
        wait for 100 ns;

        wait;
    end process;

end test;
