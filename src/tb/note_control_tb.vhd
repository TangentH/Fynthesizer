library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_note_control is
end tb_note_control;

architecture Behavioral of tb_note_control is
    -- Component Declaration for the Unit Under Test (UUT)
    component note_control
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            note_on : in STD_LOGIC;
            note_off : in STD_LOGIC;
            note_value : in STD_LOGIC_VECTOR(7 downto 0);
            en : out STD_LOGIC_VECTOR(11 downto 0);
            note : out STD_LOGIC_VECTOR(95 downto 0)
        );
    end component;

    -- Inputs
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal note_on : STD_LOGIC := '0';
    signal note_off : STD_LOGIC := '0';
    signal note_value : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Outputs
    signal en : STD_LOGIC_VECTOR(11 downto 0);
    signal note : STD_LOGIC_VECTOR(95 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: note_control Port map (
        clk => clk,
        reset => reset,
        note_on => note_on,
        note_off => note_off,
        note_value => note_value,
        en => en,
        note => note
    );

    -- Clock process definitions
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        reset <= '1';
        wait for 100 ns;	
        reset <= '0';
        wait for clk_period*2;

        -- Apply test signals
        -- Test case 1: Note On
        note_value <= x"3C";  -- Note value 60 (Middle C)
        note_on <= '1';
        wait for clk_period;
        note_on <= '0';
        wait for clk_period*10;

        -- Test case 2: Note On another note
        note_value <= x"40";  -- Note value 64 (E4)
        note_on <= '1';
        wait for clk_period;
        note_on <= '0';
        wait for clk_period*10;

        -- Test case 3: Note On yet another note
        note_value <= x"43";  -- Note value 67 (G4)
        note_on <= '1';
        wait for clk_period;
        note_on <= '0';
        wait for clk_period*10;

        -- Test case 4: Note Off for the first note
        note_value <= x"3C";  -- Note value 60 (Middle C)
        note_off <= '1';
        wait for clk_period;
        note_off <= '0';
        wait for clk_period*10;

        -- Test case 5: Note Off for the second note
        note_value <= x"40";  -- Note value 64 (E4)
        note_off <= '1';
        wait for clk_period;
        note_off <= '0';
        wait for clk_period*10;

        -- Test case 6: Note Off for the third note
        note_value <= x"43";  -- Note value 67 (G4)
        note_off <= '1';
        wait for clk_period;
        note_off <= '0';
        wait for clk_period*10;

        -- Stop simulation
        wait;
    end process;
end Behavioral;
