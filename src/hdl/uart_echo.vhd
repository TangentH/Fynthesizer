library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_echo is
    generic (
        clk_freq : integer := 100000000; -- System clock frequency (default: 100MHz)
        baud_rate : integer := 9600;    -- Baud rate
        data_bits : integer := 8        -- Number of data bits (5, 6, 7, or 8)
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        rx : in std_logic;
        tx : out std_logic
    );
end uart_echo;

architecture behavioral of uart_echo is

    constant bit_period : integer := clk_freq / baud_rate;

    type state_type is (idle, start, data, stop);
    signal rx_state : state_type := idle;
    signal tx_state : state_type := idle;

    signal rx_bit_count : integer range 0 to data_bits-1 := 0;
    signal tx_bit_count : integer range 0 to data_bits-1 := 0;
    signal rx_clk_count : integer := 0;
    signal tx_clk_count : integer := 0;
    signal rx_reg : std_logic_vector(data_bits-1 downto 0);
    signal tx_reg : std_logic_vector(data_bits-1 downto 0);
    signal tx_data : std_logic := '1';
    signal rx_ready : std_logic := '0';

begin

    -- Combined Receive and Transmit process
    process(clk, rst)
    begin
        if rst = '1' then
            rx_state <= idle;
            tx_state <= idle;
            rx_bit_count <= 0;
            tx_bit_count <= 0;
            rx_clk_count <= 0;
            tx_clk_count <= 0;
            rx_reg <= (others => '0');
            tx_reg <= (others => '0');
            tx_data <= '1';
            rx_ready <= '0';
        elsif rising_edge(clk) then
            -- Receive State Machine
            case rx_state is
                when idle =>
                    if rx = '0' then
                        rx_state <= start;
                        rx_clk_count <= 0;
                    end if;
                when start =>
                    if rx_clk_count = bit_period/2 then
                        if rx = '0' then
                            rx_state <= data;
                            rx_clk_count <= 0;
                            rx_bit_count <= 0;
                        else
                            rx_state <= idle;
                        end if;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;
                when data =>
                    if rx_clk_count = bit_period then
                        rx_clk_count <= 0;
                        rx_reg(rx_bit_count) <= rx;
                        if rx_bit_count = data_bits-1 then
                            rx_state <= stop;
                        else
                            rx_bit_count <= rx_bit_count + 1;
                        end if;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;
                when stop =>
                    if rx_clk_count = bit_period then
                        rx_state <= idle;
                        rx_ready <= '1';
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;
            end case;

            -- Transmit State Machine
            case tx_state is
                when idle =>
                    if rx_ready = '1' then
                        tx_reg <= rx_reg;
                        tx_state <= start;
                        tx_clk_count <= 0;
                        tx_bit_count <= 0;
                        rx_ready <= '0';
                    end if;
                when start =>
                    if tx_clk_count = bit_period then
                        tx_data <= '0';
                        tx_clk_count <= 0;
                        tx_state <= data;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;
                when data =>
                    if tx_clk_count = bit_period then
                        tx_data <= tx_reg(tx_bit_count);
                        tx_clk_count <= 0;
                        if tx_bit_count = data_bits-1 then
                            tx_state <= stop;
                        else
                            tx_bit_count <= tx_bit_count + 1;
                        end if;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;
                when stop =>
                    if tx_clk_count = bit_period then
                        tx_data <= '1';
                        tx_state <= idle;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;
            end case;
        end if;
    end process;

    tx <= tx_data;

end behavioral;
