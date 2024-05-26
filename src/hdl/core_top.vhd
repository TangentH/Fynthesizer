library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity core_top is
  port (
        reset: in std_logic;
        BTNU: in std_logic;
        BTND: in std_logic;
        BTNL: in std_logic;
        BTNR: in std_logic;
        clk: in std_logic;
        commonPhaseInc: in unsigned(15 downto 0);
        audio_out: out signed(15 downto 0)
  );
end core_top;

architecture Behavioral of core_top is
    signal nextSample: std_logic := '0';
    signal opEnable: std_logic_vector(11 downto 0) := (others => '0');
    signal att, dec, sus, rel: signed(7 downto 0);
    signal ampl: signed(7 downto 0);
    signal opPhase: unsigned(191 downto 0);

    component skrach_core
      port (
            clk: in std_logic;
            reset: in std_logic;
            opPhase: in unsigned(191 downto 0);
            opEnable: in std_logic_vector(11 downto 0);
            att, dec, sus, rel: in signed(7 downto 0);
            ampl: in signed(7 downto 0);
            nextSample: in std_logic;
            audioOut: out signed(15 downto 0)
      );
    end component;

begin

    -- Set ADSR values
    att <= to_signed(1, 8);
    dec <= to_signed(1, 8);
    sus <= to_signed(50, 8);
    rel <= to_signed(1, 8);

    -- Set master amplitude to maximum value
    ampl <= to_signed(127, 8);

    -- Control operator enables with buttons

    opEnable(0) <= BTNU;
    opEnable(1) <= BTND;
    opEnable(2) <= BTNL;
    opEnable(3) <= BTNR;

    -- Set common phase increment values for the first 4 operators
    opPhase(15 downto 0) <= commonPhaseInc;
    opPhase(31 downto 16) <= commonPhaseInc;
    opPhase(47 downto 32) <= commonPhaseInc;
    opPhase(63 downto 48) <= commonPhaseInc;
    opPhase(191 downto 64) <= (others => '0');

    -- Generate nextSample signal, set to three clock cycles
    process(clk, reset)
        variable count: integer range 0 to 2 := 0;
    begin
        if reset = '1' then
            count := 0;
            nextSample <= '0';
        elsif rising_edge(clk) then
            if count = 2 then
                nextSample <= '1';
                count := 0;
            else
                nextSample <= '0';
                count := count + 1;
            end if;
        end if;
    end process;

    -- Instantiate skrach_core
    core_inst: skrach_core
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
        audioOut => audio_out
    );

end Behavioral;
