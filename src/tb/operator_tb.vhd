LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY operator_tb IS
END operator_tb;

ARCHITECTURE behavior OF operator_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT operator
    PORT(
        clk : IN  std_logic;
        reset : IN  std_logic;
        nextSample : IN  std_logic;
        waveSel : IN  std_logic_vector(1 downto 0);
        phaseInc : IN  unsigned(15 downto 0);
        att, dec, sus, rel : IN  signed(7 downto 0);
        en : IN  std_logic;
        sigOut : OUT  signed(15 downto 0)
        );
    END COMPONENT;
    
    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal nextSample : std_logic := '0';
    signal waveSel : std_logic_vector(1 downto 0) := "00";
    signal phaseInc : unsigned(15 downto 0) := (others => '0');
    signal att, dec, sus, rel : signed(7 downto 0) := (others => '0');
    signal en : std_logic := '0';

    -- Outputs
    signal sigOut : signed(15 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;  -- 100 MHz

    -- Sample period definitions
    constant sample_period : time := 1 us;  -- Update nextSample every 1 microsecond

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: operator PORT MAP (
        clk => clk,
        reset => reset,
        nextSample => nextSample,
        waveSel => waveSel,
        phaseInc => phaseInc,
        att => att,
        dec => dec,
        sus => sus,
        rel => rel,
        en => en,
        sigOut => sigOut
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
        wait for 100 ns;
        reset <= '0';
        waveSel <= "00";
        phaseInc <= to_unsigned(1024, 16); -- Moderate frequency
        
        -- Wait 100 ns for global reset to finish
        wait for 100 ns;

        -- Enable the ADSR with a sample input value
        en <= '1'; -- Note on
        att <= to_signed(1, 8); -- Attack duration
        dec <= to_signed(1, 8); -- Decay duration
        sus <= to_signed(60, 8); -- Sustain level
        rel <= to_signed(1, 8); -- Release duration
        
        -- Simulate key press duration
        wait for 5 ms;
        en <= '0'; -- Note off, triggering release phase
--        wait for 1ms;
--        -- Reset and disable
--        reset <= '1';
--        wait for 100 ns;
--        reset <= '0';
        wait;
    end process;

END behavior;
