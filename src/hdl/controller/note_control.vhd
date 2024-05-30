library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity note_control is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        note_on : in STD_LOGIC;
        note_off : in STD_LOGIC;
        note_value : in STD_LOGIC_VECTOR(7 downto 0);
        en : out STD_LOGIC_VECTOR(11 downto 0);
        phaseInc : out UNSIGNED(191 downto 0)  -- New output port for phaseInc
    );
end note_control;

architecture Behavioral of note_control is
    signal en_reg : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal note_reg : STD_LOGIC_VECTOR(95 downto 0) := (others => '0');
    type phaseInc_array_type is array (0 to 11) of UNSIGNED(15 downto 0);  -- Define array type
    signal phaseInc_array : phaseInc_array_type := (others => (others => '0'));  -- Intermediate array for phaseInc
begin
    process(clk, reset)
    begin
        if reset = '1' then
            en_reg <= (others => '0');
            note_reg <= (others => '0');
            phaseInc <= (others => '0');  -- Reset phaseInc_array
        elsif rising_edge(clk) then
            if note_on = '1' then
                for i in 11 downto 0 loop
                    if en_reg(i) = '0' then
                        en_reg(i) <= '1';
                        note_reg((i+1)*8-1 downto i*8) <= note_value;
                        exit;
                    end if;
                end loop;
            elsif note_off = '1' then
                for i in 11 downto 0 loop
                    if note_reg((i+1)*8-1 downto i*8) = note_value then
                        en_reg(i) <= '0';
                        note_reg((i+1)*8-1 downto i*8) <= (others => '0');
                    end if;
                end loop;
            end if;
        end if;
    end process;

    -- Instantiate note2phaseInc for each note
    gen_phaseInc: for i in 0 to 11 generate
        phase_inc_inst: entity work.note2phaseInc
            port map (
                note => note_reg((i+1)*8-1 downto i*8),
                phaseInc => phaseInc_array(i) -- Map to the intermediate array
            );
    end generate;

    en <= en_reg;
    -- Concatenate phaseInc_array to form the phaseInc signal
    phaseInc <= phaseInc_array(11) & phaseInc_array(10) & phaseInc_array(9) & phaseInc_array(8) & 
                phaseInc_array(7) & phaseInc_array(6) & phaseInc_array(5) & phaseInc_array(4) & 
                phaseInc_array(3) & phaseInc_array(2) & phaseInc_array(1) & phaseInc_array(0);
end Behavioral;
