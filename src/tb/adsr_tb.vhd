LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adsr_tb IS
END adsr_tb;

ARCHITECTURE behavior OF adsr_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT adsr
    PORT(
        clk : IN  std_logic;
        reset : IN  std_logic;
        en : IN  std_logic;
        nextSample : IN  std_logic;
        attack : IN  signed(7 downto 0);
        decay : IN  signed(7 downto 0);
        sustain : IN  signed(7 downto 0);
        rel : IN  signed(7 downto 0);
        signalIn : IN  signed(15 downto 0);
        signalOut : OUT  signed(15 downto 0)
        );
    END COMPONENT;
    
    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal en : std_logic := '0';
    signal nextSample : std_logic := '0';
    signal attack : signed(7 downto 0) := (others => '0');
    signal decay : signed(7 downto 0) := (others => '0');
    signal sustain : signed(7 downto 0) := (others => '0');
    signal rel : signed(7 downto 0) := (others => '0');
    signal signalIn : signed(15 downto 0) := (others => '0');

    -- Outputs
    signal signalOut : signed(15 downto 0);

    -- Clock period definitions
    constant clk_period : time := 1 ns;

    -- Sample period definitions
    constant sample_period : time := 2 ns;  -- Update nextSample every 1 microsecond

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: adsr PORT MAP (
        clk => clk,
        reset => reset,
        en => en,
        nextSample => nextSample,
        attack => attack,
        decay => decay,
        sustain => sustain,
        rel => rel,
        signalIn => signalIn,
        signalOut => signalOut
    );

    -- Clock process definitions
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Simulate nextSample signal process
    nextSample_process : process
    begin
        while true loop
            nextSample <= '0';
            wait for sample_period/2;
            nextSample <= '1';
            wait for sample_period/2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin        
        -- initialize inputs
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        
        -- Wait 100 ns for global reset to finish
        --wait for 100 ns;

        -- Enable the ADSR with a sample input value
        signalIn <= to_signed(32767, 16); -- Maximum amplitude of input signal
        en <= '1'; -- Note on
        attack <= to_signed(1, 8); -- Attack duration
        decay <= to_signed(1, 8); -- Decay duration
        sustain <= to_signed(50, 8); -- Sustain level
        rel <= to_signed(1, 8); -- Release duration
        
        -- Simulate key press duration
        wait for 4 us;
        en <= '0'; -- Note off, triggering release phase
--        wait for 500 ns; -- Allow time for the release phase to complete
        
--        -- Reset and disable
--        reset <= '1';
--        wait for 100 ns;
--        reset <= '0';
        wait;
    end process;

END;
