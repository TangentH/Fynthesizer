library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

entity receiver is
    generic(
        BAUD        : integer := 115200;
        CLK_FREQ    : integer := 100000000;
        DATA_BITS   : integer := 8
        --STOP_BITS   : integer := 1
        );
    port ( 
        clk          : in STD_LOGIC;
        rstn         : in STD_LOGIC;
        rx           : in STD_LOGIC;
        data_out     : out STD_LOGIC_VECTOR (7 downto 0);
        byte_valid   : out STD_LOGIC;
        data_read   : in STD_LOGIC 
        );
end receiver;

architecture Behavioral of receiver is
    
    signal baud_counter_max : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(integer(round(real(CLK_FREQ)/(real(BAUD)))), 32));
    signal baud_counter     : std_logic_vector(31 downto 0);
    signal bit_counter      : integer range 0 to 10;
    signal rx_d             : std_logic;
    signal data_out_reg     : std_logic_vector (7 downto 0);

    type state_type is (sIDLE, sWAIT_HALF_SAMPLE, sREAD_BYTE, sHOLD);
    signal state, previous_state : state_type;

begin
    
    data_out <= data_out_reg;
    ---------------------------------------------------------------------------------
    -- Baud rate counter
    ---------------------------------------------------------------------------------
    process(clk) begin
        if (rising_edge (clk)) then
            if (rstn = '0') then
                baud_counter <= (others => '0');
            else
                previous_state <= state;
                if(previous_state /= state) then -- reset the baud rate counter whenever we change states
                    baud_counter <= (others => '0');
                else
                    if(baud_counter < baud_counter_max) then
                        baud_counter <= baud_counter + 1;
                    else
                        baud_counter <= (others => '0');
                    end if;
                end if;

            end if;
        end if;

    end process;

    ---------------------------------------------------------------------------------
    -- UART state machine
    ---------------------------------------------------------------------------------
    receiver_fsm : process(clk) begin
        if (rising_edge (clk)) then
            if (rstn = '0') then
                state <= sIDLE;
                bit_counter <= 0;
                data_out_reg <= (others => '0');
                byte_valid <= '0';
            else
                rx_d <= rx;
                case state is
                    when sIDLE =>
                        byte_valid <= '0';
                        if(rx_d = '1' and rx = '0') then  -- falling edge of start bit
                            state <= sWAIT_HALF_SAMPLE;
                        end if;

                    -- Start bit detected
                    -- Wait a half baud rate period so we can sample the bits in the middle of the window
                    when sWAIT_HALF_SAMPLE =>
                        byte_valid <= '0';
                        if(baud_counter = baud_counter_max(31 downto 1)) then
                            state <= sREAD_BYTE;
                        end if;

                    when sREAD_BYTE =>
                        if(baud_counter = baud_counter_max) then
                            if (bit_counter < DATA_BITS) then
                                -- right shift register:
                                data_out_reg(7) <= rx;
                                data_out_reg(6 downto 0) <= data_out_reg(7 downto 1);
                                bit_counter <= bit_counter + 1;
                                byte_valid <= '0';
                            else
                                byte_valid <= '0';
                                bit_counter <= 0;
                                -- Current byte is finished, go back to sIDLE state
                                state <= sHOLD;
                            end if;
                        end if;
                        
                    when sHOLD =>
                        byte_valid <= '1';
                        if data_read = '1' then
                            state <= sIDLE;
                        end if;

                end case ;
            end if;
        end if;

    end process;

end Behavioral;
