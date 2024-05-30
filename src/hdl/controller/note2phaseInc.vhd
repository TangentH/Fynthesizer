library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.phaseInc_package.all;

entity note2phaseInc is
    Port (
        note : in  std_logic_vector(7 downto 0);
        phaseInc : out unsigned(15 downto 0)
    );
end note2phaseInc;

architecture Behavioral of note2phaseInc is
begin
    process(note)
        variable note_index : integer;
    begin
        -- Convert note from std_logic_vector to integer
        note_index := to_integer(unsigned(note));
        
        -- Check if the note is within the valid range of 21 to 108 (MIDI notes for piano)
        if note_index >= 21 and note_index <= 108 then
            phaseInc <= phaseIncs(note_index - 21); -- Adjust for 0-based array indexing
        else
            phaseInc <= (others => '0'); -- Default phaseInc if note is out of range
        end if;
    end process;
end Behavioral;
