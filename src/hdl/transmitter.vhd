library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

entity transmitter is
    generic(
        BAUD        : integer := 115200;
        CLK_FREQ    : integer := 100000000;
        DATA_BITS   : integer := 8;
        STOP_BITS   : integer := 1
        --PARITY_BITS : integer := 0
        );
    port (
        clk         : in STD_LOGIC;
        rstn        : in STD_LOGIC;
        data_in     : in STD_LOGIC_VECTOR(7 downto 0);  -- byte to be serialized out
        data_valid  : in STD_LOGIC;                     -- indicates data_in is valid
        tx_ready    : out STD_LOGIC;                    -- indicates the transmitter is ready for another byte
        tx          : out STD_LOGIC
        );
end transmitter;

architecture Behavioral of transmitter is

    signal uart_clk : std_logic;
    signal baud_counter : std_logic_vector(31 downto 0);
    signal byte_out : std_logic_vector(7 downto 0);
    signal ready : STD_LOGIC;
    signal data_latched : STD_LOGIC;
    signal send_start_bit, send_stop_bit, send_stop_bit_d, send_data : STD_LOGIC;
    signal bit_counter : integer range 0 to 10;
    signal stop_bit_counter : integer range 0 to 10;

    signal rstn_d : std_logic;
    
    constant baud_counter_max : integer := integer(ceil(real(CLK_FREQ)/(real(2*BAUD))));


    type state_type is (sIDLE, sSTART_BIT, sSEND_BYTE, sSTOP_BIT);
    signal state : state_type;

begin
    tx_ready <= ready;
    
    ---------------------------------------------------------------------------------
    -- UART CLK divider, frequency determined by the BAUD rate parameter
    ---------------------------------------------------------------------------------
    uart_clk_div : process(clk) begin
        if (rising_edge (clk)) then
            if (rstn = '0') then
                uart_clk <= '0';
                baud_counter <= (others => '0');
            else
                if(baud_counter < std_logic_vector(to_unsigned(baud_counter_max, baud_counter'length))) then
                    baud_counter <= baud_counter + 1;
                else
                    baud_counter <= (others => '0');
                    uart_clk <= not uart_clk;
                end if;
            end if;        
        end if;
    end process;
    
    ---------------------------------------------------------------------------------
    -- Flop the data_in when ready and valid
    ---------------------------------------------------------------------------------
    data_latch : process(clk) begin
        if (rising_edge (clk)) then
            rstn_d <= rstn;

            if (rstn = '0') then
                byte_out <= (others => '0');
                ready <= '0';
                data_latched <= '0';
            else
                if(rstn_d = '0' and rstn = '1') then -- set ready as soon as we come out of reset
                    ready <= '1'; 
                end if;
                
                if(data_valid = '1' and ready = '1') then
                    byte_out <= data_in;
                    ready <= '0';
                    data_latched <= '1';
                end if;
                
                send_stop_bit_d <= send_stop_bit;
                if(send_stop_bit_d = '0' and send_stop_bit = '1') then -- finished sending the current byte, ready to accept a new one
                    ready <= '1';
                    data_latched <= '0';
                end if;

            end if;        
        end if;
    end process;
    
    ---------------------------------------------------------------------------------
    -- Shift serial data out, controlled by the FSM
    ---------------------------------------------------------------------------------
    shift_reg : process(uart_clk, rstn) begin
        if (rstn = '0') then
            tx <= '1';
            bit_counter <= 0;

        elsif (rising_edge(uart_clk)) then

            if(send_start_bit = '1') then
                tx <= '0';
                bit_counter <= 0;
            elsif(send_data = '1') then
                tx <= byte_out(bit_counter);
                if(bit_counter = DATA_BITS-1) then
                    bit_counter <= 0;
                else
                    bit_counter <= bit_counter + 1;
                end if; 
            elsif(send_stop_bit = '1') then
                tx <= '1';
                bit_counter <= 0;
            else -- sIDLE state
                tx <= '1';
                bit_counter <= 0;
            end if;      
        end if;
    end process;

    ---------------------------------------------------------------------------------
    -- UART state machine
    ---------------------------------------------------------------------------------
    next_state_logic : process(uart_clk) begin
        if (rising_edge (uart_clk)) then
            if (rstn = '0') then
                state <= sIDLE;
                stop_bit_counter <= 0;
            else
                case state is
                    when sIDLE =>
                        if(data_valid = '1') then
                            state <= sSTART_BIT;
                        end if;

                    when sSTART_BIT =>
                        state <= sSEND_BYTE;

                    when sSEND_BYTE =>
                        if(bit_counter = DATA_BITS-1) then
                            state <= sSTOP_BIT;
                        end if;

                    when sSTOP_BIT =>
                        if (stop_bit_counter < STOP_BITS-1) then
                            stop_bit_counter <= stop_bit_counter + 1;
                        else
                            if(data_latched = '1') then -- if we have more valid data, start sending it right away
                                state <= sSTART_BIT;
                            else
                                state <= sIDLE;
                            end if;
                        end if;

                    when OTHERS =>
                        state <= sIDLE;

                end case;
            end if;        
        end if;
    end process;
    
    fsm_output_logic : process(state) begin
       case state is
            when sIDLE =>
                send_start_bit  <= '0';
                send_data       <= '0';
                send_stop_bit   <= '0';
                --ready           <= '1';
            
            when sSTART_BIT =>
                send_start_bit  <= '1';
                send_data       <= '0';
                send_stop_bit   <= '0';
                --ready           <= '0';
            
            when sSEND_BYTE =>
                send_start_bit  <= '0';
                send_data       <= '1';
                send_stop_bit   <= '0';
                --ready           <= '0';
            
            when sSTOP_BIT =>
                send_start_bit  <= '0';
                send_data       <= '0';
                send_stop_bit   <= '1';
                --ready           <= '1';
            
        end case;
    end process;

end Behavioral;
