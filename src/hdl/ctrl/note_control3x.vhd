library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity note_control3x is
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
end note_control3x;

architecture Behavioral of note_control3x is
    signal en_reg : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal note_reg : STD_LOGIC_VECTOR(95 downto 0) := (others => '0');
    signal note2_reg : STD_LOGIC_VECTOR(95 downto 0) := (others => '0');
    signal note3_reg : STD_LOGIC_VECTOR(95 downto 0) := (others => '0');
    type phaseInc_array_type is array (0 to 11) of UNSIGNED(15 downto 0);  -- Define array type
    signal phaseInc_array_base : phaseInc_array_type := (others => (others => '0'));  -- Intermediate array for phaseInc
    signal phaseInc_array_second : phaseInc_array_type := (others => (others => '0'));
    signal phaseInc_array_third : phaseInc_array_type := (others => (others => '0'));
begin
    process(clk, reset)
    begin
        if reset = '1' then
            en_reg <= (others => '0');
            note_reg <= (others => '0');
            phaseInc_base <= (others => '0');  -- Reset phaseInc_array
            phaseInc_second <= (others => '0'); 
            phaseInc_third <= (others => '0'); 
        elsif rising_edge(clk) then
            if note_on = '1' then
                if en_reg(11) = '0' then
                    en_reg(11) <= '1';
                    note_reg(95 downto 88) <= note_value;
                elsif en_reg(10) = '0' then
                    en_reg(10) <= '1';
                    note_reg(87 downto 80) <= note_value;
                elsif en_reg(9) = '0' then
                    en_reg(9) <= '1';
                    note_reg(79 downto 72) <= note_value;
                elsif en_reg(8) = '0' then
                    en_reg(8) <= '1';
                    note_reg(71 downto 64) <= note_value;
                elsif en_reg(7) = '0' then
                    en_reg(7) <= '1';
                    note_reg(63 downto 56) <= note_value;
                elsif en_reg(6) = '0' then
                    en_reg(6) <= '1';
                    note_reg(55 downto 48) <= note_value;
                elsif en_reg(5) = '0' then
                    en_reg(5) <= '1';
                    note_reg(47 downto 40) <= note_value;
                elsif en_reg(4) = '0' then
                    en_reg(4) <= '1';
                    note_reg(39 downto 32) <= note_value;
                elsif en_reg(3) = '0' then
                    en_reg(3) <= '1';
                    note_reg(31 downto 24) <= note_value;
                elsif en_reg(2) = '0' then
                    en_reg(2) <= '1';
                    note_reg(23 downto 16) <= note_value;
                elsif en_reg(1) = '0' then
                    en_reg(1) <= '1';
                    note_reg(15 downto 8) <= note_value;
                elsif en_reg(0) = '0' then
                    en_reg(0) <= '1';
                    note_reg(7 downto 0) <= note_value;
                end if;
            elsif note_off = '1' then
                if note_reg(95 downto 88) = note_value then
                    en_reg(11) <= '0';
                    -- note_reg(95 downto 88) <= (others => '0');
                elsif note_reg(87 downto 80) = note_value then
                    en_reg(10) <= '0';
                    -- note_reg(87 downto 80) <= (others => '0');
                elsif note_reg(79 downto 72) = note_value then
                    en_reg(9) <= '0';
                    -- note_reg(79 downto 72) <= (others => '0');
                elsif note_reg(71 downto 64) = note_value then
                    en_reg(8) <= '0';
                    -- note_reg(71 downto 64) <= (others => '0');
                elsif note_reg(63 downto 56) = note_value then
                    en_reg(7) <= '0';
                    -- note_reg(63 downto 56) <= (others => '0');
                elsif note_reg(55 downto 48) = note_value then
                    en_reg(6) <= '0';
                    -- note_reg(55 downto 48) <= (others => '0');
                elsif note_reg(47 downto 40) = note_value then
                    en_reg(5) <= '0';
                    -- note_reg(47 downto 40) <= (others => '0');
                elsif note_reg(39 downto 32) = note_value then
                    en_reg(4) <= '0';
                    -- note_reg(39 downto 32) <= (others => '0');
                elsif note_reg(31 downto 24) = note_value then
                    en_reg(3) <= '0';
                    -- note_reg(31 downto 24) <= (others => '0');
                elsif note_reg(23 downto 16) = note_value then
                    en_reg(2) <= '0';
                    -- note_reg(23 downto 16) <= (others => '0');
                elsif note_reg(15 downto 8) = note_value then
                    en_reg(1) <= '0';
                    -- note_reg(15 downto 8) <= (others => '0');
                elsif note_reg(7 downto 0) = note_value then
                    en_reg(0) <= '0';
                    -- note_reg(7 downto 0) <= (others => '0');
                end if;
            end if;
            -- Concatenate phaseInc_array to form the phaseInc signal
            -- Need to concatenate it in the process to avoid multiple drivers (another driver is in reset = '1' branch)
            phaseInc_base <= phaseInc_array_base(11) & phaseInc_array_base(10) & phaseInc_array_base(9) & phaseInc_array_base(8) & 
            phaseInc_array_base(7) & phaseInc_array_base(6) & phaseInc_array_base(5) & phaseInc_array_base(4) & 
            phaseInc_array_base(3) & phaseInc_array_base(2) & phaseInc_array_base(1) & phaseInc_array_base(0);

            phaseInc_second <= phaseInc_array_second(11) & phaseInc_array_second(10) & phaseInc_array_second(9) & phaseInc_array_second(8) & 
            phaseInc_array_second(7) & phaseInc_array_second(6) & phaseInc_array_second(5) & phaseInc_array_second(4) & 
            phaseInc_array_second(3) & phaseInc_array_second(2) & phaseInc_array_second(1) & phaseInc_array_second(0);

            phaseInc_third <= phaseInc_array_third(11) & phaseInc_array_third(10) & phaseInc_array_third(9) & phaseInc_array_third(8) & 
            phaseInc_array_third(7) & phaseInc_array_third(6) & phaseInc_array_third(5) & phaseInc_array_third(4) & 
            phaseInc_array_third(3) & phaseInc_array_third(2) & phaseInc_array_third(1) & phaseInc_array_third(0);
        end if;
    end process;

    -- Instantiate note2phaseInc for each note
    gen_phaseInc_base: for i in 0 to 11 generate
        phase_inc_inst: entity work.note2phaseInc
            port map (
                note => note_reg((i+1)*8-1 downto i*8),
                phaseInc => phaseInc_array_base(i) -- Map to the intermediate array
            );
    end generate;

    -- We only use the 6 Most Significant Bits of note_offset (regulate it between -32 to 31)
    note2_reg_gen: for i in 0 to 11 generate
        note2_reg((i+1)*8-1 downto i*8) <= std_logic_vector(signed(note_reg((i+1)*8-1 downto i*8))+resize(note_offset2(7 downto 2),8));
    end generate;

    gen_phaseInc_second: for i in 0 to 11 generate
        phase_inc_inst: entity work.note2phaseInc
            port map (
                note => note2_reg((i+1)*8-1 downto i*8),
                phaseInc => phaseInc_array_second(i) -- Map to the intermediate array
            );
    end generate;

    note3_reg_gen: for i in 0 to 11 generate
        note3_reg((i+1)*8-1 downto i*8) <= std_logic_vector(signed(note_reg((i+1)*8-1 downto i*8))+resize(note_offset3(7 downto 2),8));
    end generate;

    gen_phaseInc_third: for i in 0 to 11 generate
        phase_inc_inst: entity work.note2phaseInc
            port map (
                note => note3_reg((i+1)*8-1 downto i*8),
                phaseInc => phaseInc_array_third(i) -- Map to the intermediate array
            );
    end generate;

    en <= en_reg;
    
end Behavioral;
