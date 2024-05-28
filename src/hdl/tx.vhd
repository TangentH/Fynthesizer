library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity tx is
	 generic ( N_bit : integer; 	 -- number of bits to read
				  N_sampl : integer); -- oversampling rate

    Port ( clk100mhz : in  STD_LOGIC;
			  uart_rxd_out : out std_logic; -- Tx line to DTE
			  din : in std_logic_vector (N_bit-1 downto 0); -- data to write to UART (from FuncGen)
			  b_tick : in std_logic;    -- Baud tick
			  wrt_done : out std_logic; -- done write UART (to FuncGen)
			  st_write : in std_logic); -- start write UART (from FuncGen)
end tx;

architecture Behavioral of tx is
-- state machine for Tx block
type state_type is (idle, func, transmit, pause);
signal state : state_type := idle;
-- Tx block signals
signal data2wrt : std_logic_vector (N_bit-1 downto 0) := (others => '0'); -- signal to store data to write to UART (data from ADC)
signal tick_count : integer range 0 to N_sampl-1 := 0; -- counter for the baud ticks
signal bit_count : integer range 0 to N_bit-1 := 0;    -- counter for the number of bits received

begin

	transmitter: process (clk100mhz, b_tick, st_write)
	begin
		if(st_write='0') then -- st_write acts as internal Reset for Tx module
			state <= idle;
		elsif (rising_edge(clk100mhz) and (b_tick = '1')) then
			case state is
			
			-- Tx stays in idle mode until receives command from upper level
			-- module (FuncGen) to start writing UART
			when idle =>
				tick_count <= 0;
				bit_count <= 0;
				-- keep UART_RXD_OUT HIGH, 
				-- as HIGH-TO-LOW transition indicates START bit
				uart_rxd_out <= '1'; 
				wrt_done <= '0';
				state <= func;
			
			-- updates inner signal to be written to UART Tx with external one,
			-- received fro FuncGen
			when func =>
				tick_count <= 0;
				bit_count <= 0;
				uart_rxd_out <= '1';
				wrt_done <= '0';
				data2wrt <= din; -- update signal to write to Tx
				state <= transmit;
			
			-- Transmits 20 bits to DTE: 2 START bits, 2 STOP bits and 16-bit signal
			when transmit =>
				uart_rxd_out <= data2wrt(bit_count);
				tick_count <= tick_count+1;
				if (tick_count = N_sampl-1) then
					tick_count <= 0;
					bit_count <= bit_count+1;
					if(bit_count = N_bit-1) then
						bit_count <= 0;
						wrt_done <= '1'; -- the flag, indicating end of transmission is set
						state <= pause;
					else
						wrt_done <= '0';
						state <= transmit;
					end if;
				else
					wrt_done <= '0';
					state <= transmit;
				end if;
			
			-- in this state the flag, indicating end of transmission is cleared
			when pause =>
				wrt_done <= '0';
				uart_rxd_out <= '1';
				state <= idle;
				
			
			end case;
		end if;
	end process transmitter;

end Behavioral;

