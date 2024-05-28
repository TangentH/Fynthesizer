library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_echo is
    Port (
        clk : in STD_LOGIC; -- 100 MHz system clock
        rst : in STD_LOGIC; -- reset
        uart_rxd_in : in STD_LOGIC; -- UART receive data (from external device)
        uart_txd_out : out STD_LOGIC -- UART transmit data (to external device)
    );
end uart_echo;

architecture Behavioral of uart_echo is

    -- Constants for UART configuration
    constant BAUD_RATE    : integer := 4800;
    constant CLK_FREQ     : integer := 100000000;
    constant DATA_BITS    : integer := 8;
    constant STOP_BITS    : integer := 1;

    -- Signals for UART receiver and transmitter
    signal rx_data        : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
    signal rx_data_valid  : STD_LOGIC;
    signal tx_ready       : STD_LOGIC;
    signal tx_start       : STD_LOGIC;

    signal tx_data        : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
    signal rstn           : STD_LOGIC;
    signal data_read      : STD_LOGIC;
begin
    rstn <= not rst;
    
    process(clk, rst)
    begin
        if rst = '1' then
            tx_start <= '0';
            tx_data <= (others => '0');
        elsif rising_edge(clk) then
            if rx_data_valid = '1' then
                tx_data <= rx_data;
                tx_start <= '1';
                data_read <= '1';
            elsif tx_ready = '1' then
                tx_start <= '0';
                data_read <= '0';
            end if;
        end if;
    end process;

    -- Instantiate the UART module
    UART_inst : entity work.UART
    generic map(
        BAUD        => BAUD_RATE,
        CLK_FREQ    => CLK_FREQ,
        DATA_BITS   => DATA_BITS,
        STOP_BITS   => STOP_BITS
    )
    port map(
        clk             => clk,
        rstn            => rstn,
        serial_data_in  => uart_rxd_in,
        data_out        => rx_data,
        data_out_valid  => rx_data_valid,
        data_read => data_read,
        serial_data_out => uart_txd_out,
        data_in         => tx_data,
        data_in_valid   => tx_start,
        tx_ready        => tx_ready
    );

end Behavioral;
