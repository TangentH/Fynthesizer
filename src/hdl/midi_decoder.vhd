library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity midi_decoder is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        uart_rxd : in STD_LOGIC;
        midi_data : out STD_LOGIC_VECTOR(23 downto 0);
        data_ready : out STD_LOGIC
    );
end midi_decoder;

architecture Behavioral of midi_decoder is
    component UART is
        Generic (
            CLK_FREQ : integer := 50e6;
            BAUD_RATE : integer := 115200;
            PARITY_BIT : string := "none";
            USE_DEBOUNCER : boolean := True
        );
        Port (
            CLK : in std_logic;
            RST : in std_logic;
            UART_TXD : out std_logic;
            UART_RXD : in std_logic;
            DIN : in std_logic_vector(7 downto 0);
            DIN_VLD : in std_logic;
            DIN_RDY : out std_logic;
            DOUT : out std_logic_vector(7 downto 0);
            DOUT_VLD : out std_logic;
            FRAME_ERROR : out std_logic;
            PARITY_ERROR : out std_logic
        );
    end component;

    signal uart_dout : std_logic_vector(7 downto 0);
    signal uart_dout_vld : std_logic;
    signal byte_count : integer range 0 to 2 := 0;
    signal midi_data_reg : std_logic_vector(23 downto 0) := (others => '0');
    signal data_ready_reg : std_logic := '0';

begin
    uart_inst : UART
        generic map(
            CLK_FREQ => 1e8,
            BAUD_RATE => 115200,
            PARITY_BIT => "none",
            USE_DEBOUNCER => True
        )
        port map (
            CLK => clk,
            RST => reset,
            UART_TXD => open,
            UART_RXD => uart_rxd,
            DIN => (others => '0'),
            DIN_VLD => '0',
            DIN_RDY => open,
            DOUT => uart_dout,
            DOUT_VLD => uart_dout_vld,
            FRAME_ERROR => open,
            PARITY_ERROR => open
        );

    process(clk, reset)
    begin
        if reset = '1' then
            byte_count <= 0;
            midi_data_reg <= (others => '0');
            data_ready_reg <= '0';
        elsif rising_edge(clk) then
            if uart_dout_vld = '1' then
                case byte_count is
                    when 0 =>
                        midi_data_reg(23 downto 16) <= uart_dout;
                        byte_count <= 1;
                    when 1 =>
                        midi_data_reg(15 downto 8) <= uart_dout;
                        byte_count <= 2;
                    when 2 =>
                        midi_data_reg(7 downto 0) <= uart_dout;
                        data_ready_reg <= '1';
                        byte_count <= 0;
                end case;
            end if;
            if data_ready_reg = '1' then
                data_ready_reg <= '0';
            end if;
        end if;
    end process;

    midi_data <= midi_data_reg;
    data_ready <= data_ready_reg;
end Behavioral;
