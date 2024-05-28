library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART is
    generic(
        BAUD        : integer := 115200;
        CLK_FREQ    : integer := 100000000;
        DATA_BITS   : integer := 8;
        STOP_BITS   : integer := 1
    );
    port( 
        clk             : in STD_LOGIC;
        rstn            : in STD_LOGIC;
        -- Receiver ports:
        serial_data_in  : in STD_LOGIC;
        data_out        : out STD_LOGIC_VECTOR (7 downto 0);
        data_out_valid  : out STD_LOGIC;
        data_read       : in STD_LOGIC;
        -- Transmitter ports:
        serial_data_out : out STD_LOGIC;
        data_in         : in STD_LOGIC_VECTOR(7 downto 0);  -- byte to be serialized out
        data_in_valid   : in STD_LOGIC;                     -- indicates data_in is valid
        tx_ready        : out STD_LOGIC                     -- indicates the transmitter is ready for another byte
    );
end UART;

architecture Behavioral of UART is
    ----------------------------------------------------------------------------------
    -- COMPONENTS
    ----------------------------------------------------------------------------------
    component receiver is
        generic(
            BAUD        : integer := 115200;
            CLK_FREQ    : integer := 100000000;
            DATA_BITS   : integer := 8
            );
        port ( 
            clk          : in STD_LOGIC;
            rstn         : in STD_LOGIC;
            rx           : in STD_LOGIC;
            data_out     : out STD_LOGIC_VECTOR (7 downto 0);
            byte_valid   : out STD_LOGIC;
            data_read    : in STD_LOGIC
            );
    end component;

    component transmitter is
        generic(
            BAUD        : integer := 115200;
            CLK_FREQ    : integer := 100000000;
            DATA_BITS   : integer := 8;
            STOP_BITS   : integer := 1
            );
        port (
            clk         : in STD_LOGIC;
            rstn        : in STD_LOGIC;
            data_in     : in STD_LOGIC_VECTOR(7 downto 0);  -- byte to be serialized out
            data_valid  : in STD_LOGIC;                     -- indicates data_in is valid
            tx_ready    : out STD_LOGIC;                    -- indicates the transmitter is ready for another byte
            tx          : out STD_LOGIC
            );
    end component;
    
    ----------------------------------------------------------------------------------
    -- SIGNALS
    ----------------------------------------------------------------------------------

begin

    UART_receiver : receiver
    generic map(
        BAUD        => BAUD,
        CLK_FREQ    => CLK_FREQ,
        DATA_BITS   => DATA_BITS
    )
    port map( 
        clk         => clk,
        rstn        => rstn,
        rx          => serial_data_in,
        data_out    => data_out,
        byte_valid  => data_out_valid,
        data_read => data_read
    );

    UART_transmitter : transmitter
    generic map(
        BAUD        => BAUD,
        CLK_FREQ    => CLK_FREQ,
        DATA_BITS   => DATA_BITS,
        STOP_BITS   => STOP_BITS
    )
    port map( 
        clk         => clk,
        rstn        => rstn,
        data_in     => data_in,
        data_valid  => data_in_valid,
        tx_ready    => tx_ready,
        tx          => serial_data_out
    );


end Behavioral;
