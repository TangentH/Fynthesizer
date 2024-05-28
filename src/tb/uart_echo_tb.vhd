library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart_echo is
end tb_uart_echo;

architecture Behavioral of tb_uart_echo is

    -- Component declaration for uart_echo
    component uart_echo
        Port (
            clk100mhz : in STD_LOGIC;
            uart_rxd_in : in STD_LOGIC;
            uart_txd_out : out STD_LOGIC
        );
    end component;

    -- Signals for testbench
    signal clk100mhz_tb : STD_LOGIC := '0';
    signal uart_rxd_in_tb : STD_LOGIC := '1';
    signal uart_txd_out_tb : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 10 ns;

    -- UART parameters
    constant baud_rate : integer := 9600;
    constant baud_period : time := 1 sec / baud_rate;

begin

    -- Instantiate the UART Echo module
    uut : uart_echo
        port map (
            clk100mhz => clk100mhz_tb,
            uart_rxd_in => uart_rxd_in_tb,
            uart_txd_out => uart_txd_out_tb
        );

    -- Clock generation process
    clk_gen : process
    begin
        while True loop
            clk100mhz_tb <= '0';
            wait for clk_period / 2;
            clk100mhz_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process clk_gen;

    -- Stimulus process to send and receive UART data
    stim_proc : process
    begin
        -- Wait for global reset
        wait for 100 ns;

        -- Send UART start bit (low)
        uart_rxd_in_tb <= '0';
        wait for baud_period;

        -- Send UART data bits for character 'A' (0x41)
        uart_rxd_in_tb <= '1'; -- bit 0
        wait for baud_period;
        uart_rxd_in_tb <= '0'; -- bit 1
        wait for baud_period;
        uart_rxd_in_tb <= '0'; -- bit 2
        wait for baud_period;
        uart_rxd_in_tb <= '0'; -- bit 3
        wait for baud_period;
        uart_rxd_in_tb <= '0'; -- bit 4
        wait for baud_period;
        uart_rxd_in_tb <= '0'; -- bit 5
        wait for baud_period;
        uart_rxd_in_tb <= '1'; -- bit 6
        wait for baud_period;
        uart_rxd_in_tb <= '0'; -- bit 7
        wait for baud_period;

        -- Send UART stop bit (high)
        uart_rxd_in_tb <= '1';
        wait for baud_period;

        -- Wait for the echoed data
        wait for 20 * baud_period;

        -- Stop simulation
        wait;
    end process stim_proc;

end Behavioral;
