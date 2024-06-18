library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity adsr is
    generic (
        DATA_WIDTH: integer := 16
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        -- Note on / off
        en: in std_logic;
        -- DAC ready for next sample
        nextSample: in std_logic;
        -- ADRS, all timings in 8bit
        attack: in signed(7 downto 0);  -- time to reach max amplitude
        decay: in signed(7 downto 0);   -- time to reach sustain amplitude
        sustain: in signed(7 downto 0); -- sustain amplitude
        -- release is a keyword or something
        rel: in signed(7 downto 0);    -- time to reach 0 amplitude
        -- Input amplitude
        signalIn: in signed(DATA_WIDTH-1 downto 0);
        -- Resultant amplitude
        signalOut: out signed(DATA_WIDTH-1 downto 0)
    );
end adsr;

architecture implementation of adsr is
    type ADSR_STATE is (ATTACK_S, DECAY_S, SUSTAIN_S, RELEASE_S);
    constant RESULT_WIDTH : integer := DATA_WIDTH + 8;
    signal result: std_logic_vector(RESULT_WIDTH-1 downto 0);
    signal amplitude: signed(7 downto 0);
    signal nextIncSig: std_logic;
    signal phase_counter : unsigned(15 downto 0);
    --signal reset: std_logic;
begin

    -- Take the upper bits-1 (because of sign) to scale the signal down to data-width
    signalOut <= signed(result(RESULT_WIDTH-2 downto RESULT_WIDTH-DATA_WIDTH-1));
    
    -- Use DSP slice for multiplication to help with negative slack/register counts
    --reset <= not reset_n;
    multipy_signal : MULT_MACRO
    generic map (
        DEVICE => "7SERIES",
        LATENCY => 3,   -- Desired clock cycle latency, 0-4
        WIDTH_A => DATA_WIDTH,  -- Multiplier A-input bus width, 1-25 
        WIDTH_B => 8   -- Multiplier B-input bus width, 1-18
    )
    port map (
        P => result,     -- Multiplier ouput bus, width determined by WIDTH_P generic 
        A => std_logic_vector(signalIn),     -- Multiplier input A bus, width determined by WIDTH_A generic 
        B => std_logic_vector(amplitude),     -- Multiplier input B bus, width determined by WIDTH_B generic 
        CE => '1',   -- 1-bit active high input clock enable
        CLK => clk, -- 1-bit positive edge clock input
        RST => reset  -- 1-bit input active high reset
    );
    
    ----------------------------------------------------------------------------
    -- Divides sampling rate so that we have a reasonable
    -- ammount of time for the envelope.
    -- 分频器，将nextSample分频，每6个nextSample产生一个nextIncSig的脉冲
    -- 分频后，相当于把adsr四个状态的时间都延长了，这样让包络的效果更加明显（否则就变化太快了，比如attack瞬间就完成了）
    ----------------------------------------------------------------------------
    clk_divider : process(clk, nextSample, reset)
         variable count: integer := 0;
         constant maxCount: integer := 7;
         variable prevState: std_logic := '0';
     begin
         if(rising_edge(clk)) then
             if(reset = '1') then
                 count := 0;
                 nextIncSig <= '0';
             elsif(nextSample = '1' and prevState = '0') then
                 count := count + 1;
                 if (count = maxCount) then
                     nextIncSig <= '1';
                     count := 0;
                 end if;
                 prevState := nextSample;
             else
                 nextIncSig <= '0';
                 prevState := nextSample;
             end if;
         end if;
     end process;

    ----------------------------------------------------------------------------
    -- State machine that changes the amplitude
    -- Counts up to the respective inputs counts, increments amplitude,
    -- resets, then continues until desired amplitude is met.
    -- 如果不适用adsr的话(en=0，对应的就是noteoff信号），任何状态都会被重置为RELEASE_S
    -- 这里amplitude定义的最大值就是to_signed(126,8),A定义的是每多少个nextIncSig增加一个amplitude，当到了最大值的时候，就会进入DECAY_S状态
    ----------------------------------------------------------------------------
  adsr_state_machine : process(clk, nextIncSig, reset)
        variable state: ADSR_STATE := RELEASE_S;
        variable count: integer := 0;
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state := RELEASE_S;
                amplitude <= (others => '0');
                count := 0;
            elsif (nextIncSig = '1') then
                case state is
                    -- Not sure why max is stable at 126
                    -- but keeping it there removes popping
                    when ATTACK_S =>
                        if (en = '0') then
                            state := RELEASE_S;
                        elsif(attack = 0) then
                            amplitude <= to_signed(126,8);
                            state := DECAY_S;
                        else
                            count := count + 1;
                            if (count = attack) then
                                amplitude <= amplitude + 1;
                                count := 0;
                                if(amplitude = to_signed(126,8)) then
                                    state := DECAY_S;
                                    count := 0;
                                end if;
                            end if;
                        end if;
                        
                    when DECAY_S =>
                        if (en = '0') then
                            state := RELEASE_S;
                        elsif(decay = 0) then
                            amplitude <= sustain;
                            state := SUSTAIN_S;
                        else
                            count := count + 1;
                            if (count = decay) then
                                amplitude <= amplitude - 1;
                                count := 0;
                                if (amplitude = sustain) then
                                    state := SUSTAIN_S;
                                    count := 0;
                                end if;
                            end if;
                        end if;
                
                       
                    when SUSTAIN_S =>
                        if(en = '0') then
                            state := DECAY_S;
                        end if;
                        
                    when RELEASE_S =>
                        if(en = '1') then
                            state := ATTACK_S;
                            count := 0;
                        elsif(amplitude > 0) then
                            if(rel = 0) then
                                amplitude <= (others => '0');
                            else
                                count := count + 1;
                                if (count = rel) then
                                    amplitude <= amplitude - 1;
                                    count := 0;
                                end if;
                            end if;
                        end if;
                        
                    when others => state := RELEASE_S;
                end case;
            end if;
        end if;
    end process;


end implementation;
