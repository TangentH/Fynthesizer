LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY oscillator_tb IS
END oscillator_tb;

ARCHITECTURE behavior OF oscillator_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT oscillator
        PORT(
            clk : IN std_logic;
            reset : IN std_logic;
            nextSample : IN std_logic;
            waveSel : IN std_logic_vector(1 downto 0);
            phaseInc : in unsigned(15 downto 0);
            wavformOut : OUT signed(15 downto 0)
        );
    END COMPONENT;
    
    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal nextSample : std_logic := '0';
    signal waveSel : std_logic_vector(1 downto 0) := (others => '0');
    signal phaseInc : unsigned(15 downto 0) := (others => '0');

    -- Outputs
    signal wavformOut : signed(15 downto 0);

    -- Clock period definitions
    constant clk_period : time := 1 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: oscillator PORT MAP (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => waveSel,
        phaseInc => phaseInc,
        wavformOut => wavformOut
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin        
        -- Initialize Inputs
        reset <= '1';
        nextSample <= '0';
        phaseInc <= to_unsigned(1024, 16); -- A reasonable increment value
        
        -- Wait for global reset
        wait for 20 ns;
        reset <= '0';  -- Release the reset

        -- Generate Sine Wave
        waveSel <= "00";
        nextSample <= '1';
        wait for 1024 ns;  -- Enough time for one cycle
        
        -- Generate Triangle Wave
        waveSel <= "01";
        wait for 1024 ns;  -- Enough time for one cycle

        -- Generate Saw Wave
        waveSel <= "10";
        wait for 1024 ns;  -- Enough time for one cycle

        -- Generate Square Wave
        waveSel <= "11";
        wait for 1024 ns;  -- Enough time for one cycle

        -- Completion of Test
        nextSample <= '0'; -- Stop generating samples
        wait;
    end process;

END behavior;
