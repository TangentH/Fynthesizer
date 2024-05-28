library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rx is
	 generic ( N_bit : integer; 	 -- number of bits to read
				  N_sampl : integer); -- oversampling rate
    Port ( clk100mhz : in  STD_LOGIC;
			  uart_txd_in : in  STD_LOGIC; -- Tx line from DTE
			  dout : out std_logic_vector (11 downto 0); -- data read from UART Rx to inner module
			  b_tick : in std_logic;   -- Baud tick
			  rd_done : out std_logic; -- done read UART (to inner module)
			  st_read : in std_logic   -- start read UART (from inner module)
			  );
end rx;

architecture Behavioral of rx is
-- state machine for Rx block
type state_type is (idle, receive, pause);
signal state : state_type := idle;
-- Rx block signals
signal tick_count : integer range 0 to N_sampl-1 := 0;-- counter for the baud ticks
signal bit_count : integer range 0 to N_bit-1 := 0;-- counter for the number of bits received
signal din : std_logic_vector (N_bit-1 downto 0) := (others => '0'); -- data received from UART Rx
signal temp : std_logic_vector (11 downto 0) := (others => '0'); -- temporary storage for the data received from UART Rx
signal mid : integer range 6 to 7; -- value to sample the first START bit, its value
-- depends on the actual oversampling rate used (16 or 13 (N_sampl))

begin

	receiver: process (clk100mhz, b_tick, uart_txd_in, st_read)
	begin
		if (st_read = '0') then -- st_read acts as internal Reset for Rx module
			tick_count <= 0;
			bit_count <= 0;
			state <= idle;
		elsif (rising_edge(clk100mhz) and (b_tick = '1')) then
			case state is
			
			-- Rx stays in idle mode until receives command from upper level
			-- module (inner module) to start reading UART
			when idle =>
				rd_done <= '0';
				tick_count <= 0;
				bit_count <= 0;
				-- HIGH-TO-LOW transition of UART_TXD_IN indicates the START bit
				if (uart_txd_in = '1') then  
					state <= idle;
				else
					state <= receive;
				end if;
			
			-- Receive mode, the command signal received from DTE is read
			-- and stored into "din"
			when receive =>
				if (b_tick = '1') then
					if (tick_count < mid and bit_count = 0) then -- 1st start bit
						tick_count <= tick_count+1;
						rd_done <= '0';
						state <= receive;
					elsif (tick_count = mid and bit_count = 0) then
						tick_count <= 0;
						din(bit_count) <= uart_txd_in;
						bit_count <= bit_count+1;
						rd_done <= '0';
						state <= receive;
					elsif (tick_count < N_sampl-1 and (bit_count > 0 and bit_count < N_bit-1)) then
						tick_count <= tick_count+1;
						rd_done <= '0';
						state <= receive;
					elsif (tick_count = N_sampl-1 and (bit_count > 0 and bit_count < N_bit-1)) then
						tick_count <= 0;
						din(bit_count) <= uart_txd_in;
						bit_count <= bit_count+1;
						rd_done <= '0';
						state <= receive;
					elsif (tick_count < N_sampl-1 and bit_count = N_bit-1) then
						tick_count <= tick_count+1;
						rd_done <= '0';
						state <= receive;
					elsif (tick_count = N_sampl-1 and bit_count = N_bit-1) then
						tick_count <= 0;
						bit_count <= 0;
						din(bit_count) <= uart_txd_in;
						-- once the last bit is read out from UART Rx, the data is
						-- stored into intermediate signal "temp" (start, stop and meaningless
						-- zeroes are discarded here)
						temp <= din(14 downto 11) & din(8 downto 1);
						rd_done <= '1'; -- flag indicating the end of reading is set
						state <= pause;
					end if;
				else
					rd_done <= '0';
					state <= receive;
				end if;
			
			-- finalizing reception, pass the data to inner module
			when pause =>
				rd_done <= '0'; -- flag indicating the end of reading is cleared
				dout <= temp;   -- data read from UART is supplied to the upper level module (inner module)
				state <= idle;

			end case;
		end if;
	end process receiver;
	
	-- this process determines value of "mid" signal, based on the 
	-- actual oversampling rate used. In turn, "mid" defines the number
	-- of samples for the first received bit.
	aux: process(clk100mhz)
	begin
	if ((N_sampl mod 2) = 0) then
			mid <= N_sampl/2-1;
	else
			mid <= ((N_sampl-1)/2);
	end if;
	end process aux;

end Behavioral;

