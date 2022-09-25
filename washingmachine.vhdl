begin
case digit is
when "0000" => seg <= "1000000"; -- "0"
when "0001" => seg <= "1111001"; -- "1"
when "0010" => seg <= "0100100"; -- "2"
when "0011" => seg <= "0110000"; -- "3"
when "0100" => seg <= "0011001"; -- "4"
when "0101" => seg <= "0010010"; -- "5"
when "0110" => seg <= "0000010"; -- "6"
when "0111" => seg <= "1111000"; -- "7"
when "1000" => seg <= "0000000"; -- "8"
when "1001" => seg <= "0010000"; -- "9"
when "1010" => seg <= "0000100"; -- A
when "1011" => seg <= "0000011"; -- b
when "1100" => seg <= "1000110"; -- C
when "1101" => seg <= "0100001"; -- d
when "1110" => seg <= "0000110"; -- E
when "1111" => seg <= "0001110"; -- F
when others => seg <= "1111111"; -- F
end case;
end process;
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity controller is
port(
clk
: in std_logic;
reset
: in std_logic;
spin_dry : in std_logic;
-- perform spin dry
start_wash : in std_logic;
-- start wash process
door_open : in std_logic;
-- Check if door is open or closed
counter : in std_logic_vector(7 downto 0); -- output 8-bit counter
LEDR0
: out std_logic;
-- LED Fill the tank will water and soap
LEDR1
: out std_logic;
-- LED Rotate the motor to spin and wash
LEDR2
: out std_logic;
-- LED drain the water.
LEDR3
: out std_logic;
-- LED fill the tank with water only
LEDR4
: out std_logic;
-- LED Rotate the motor to spin and wash
LEDR5
: out std_logic;
-- LED Drain the water
LEDR6
: out std_logic;
-- LED dry spin
water_pump : out std_logic; -- start/stop water pump
soap
: out std_logic; -- start/stop soap
rotate_drum : out std_logic; -- rotate drum
drain
: out std_logic; -- open water drain
enable_timer : out std_logic -- open water drain
);
end controller;
architecture Behavioral of controller is
TYPE state_type IS (zero,one,two,three,four,five,six,seven);
SIGNAL state : state_type;
begin
next_state_logic : process(clk)
begin
if(clk'event and clk='1') then
case state is
when zero => -- Wait for Start
if (door_open = '1') then
if start_wash = '0' then
state <= zero;
end if;
elsif (door_open = '0') then
if (start_wash='1') then
state <= one;
end if;
end if;
when one =>
-- Fill the tank will water and soap
if (counter = x"32") then -- fill the water tank for 10
seconds. Counter 60 to 50
state <= two;
end if;
when two =>
-- Rotate the motor to spin and wash
if (counter = x"28") then -- rotate the spinner for 10
seconds. counter 50 to 40
state <= three;
end if;
when three =>
-- drain the water.
if (counter = x"1E") then -- drain the water 10 seconds.
counter 40 to 30
state <= four;
end if;
when four =>
-- fill the tank with water only
if (counter = x"14") then -- fill the tank with water only 10
seconds. counter 30 to 20
state <= five;
end if;
when five =>
-- Rotate the motor to spin and wash
if (counter = x"0A") then -- Rotate the motor to spin and
wash for 10 seconds if spin dry is enabled. 20 - 10
state <= six;
end if;
when six => -- Drain the water
if (spin_dry='0')then
if (counter = x"00") then -- open drain for 10
seconds if 10 - 0
state <= zero;
end if;
elsif (spin_dry='1') then
state <= seven;
end if;
when seven =>
if (counter = x"00") then -- Rotate the motor to dry spin for
10 seconds if spin dry is enabled. 10 - 0
state <= zero;
-- reset the state
end if;
end case;
if (door_open = '1') then -- if someone opens the door, reset the machine
state <= zero;
end if;
end if;
end process;
output_logic : process(reset,state,clk)
begin
if reset = '1' then
case state is
when zero => -- Wait for Start
water_pump <= '0';
soap
<= '0';
rotate_drum <= '0';
drain
<= '0';
enable_timer <= '0';
LEDR0
<= '0';
LEDR1
<= '0';
LEDR2
<= '0';
LEDR3
<= '0';
LEDR4
<= '0';
LEDR5
<= '0';
LEDR6
<= '0';
when one => -- Fill the tank will water and soap
water_pump <= '1';
soap
<= '1';
rotate_drum <= '0';
drain
<= '0';
enable_timer <= '1';
LEDR0
<= '1';
LEDR1
<= '0';
LEDR2
<= '0';
LEDR3
<= '0';
LEDR4
<= '0';
LEDR5
<= '0';
LEDR6
<= '0';
when two => -- Rotate the motor to spin and wash
water_pump <= '0';
soap
<= '0';
rotate_drum <= '1';
drain
<= '0';
enable_timer <= '1';
LEDR0
<= '1';
LEDR1
<= '1';
LEDR2
<= '0';
LEDR3
<= '0';
LEDR4
<= '0';
LEDR5
<= '0';
LEDR6
<= '0';
when three => -- drain the water.
water_pump <= '0';
soap
<= '0';
rotate_drum <= '0';
drain
<= '1';
enable_timer <= '1';
LEDR0
<= '1';
LEDR1
<= '1';
LEDR2
<= '1';
LEDR3
<= '0';
LEDR4
<= '0';
LEDR5
<= '0';
LEDR6
<= '0';
when four => -- fill the tank with water only
water_pump <= '1';
soap
<= '0';
rotate_drum <= '0';
drain
<= '0';
enable_timer <= '1';
LEDR0
<= '1';
LEDR1
<= '1';
LEDR2
<= '1';
LEDR3
<= '1';
LEDR4
<= '0';
LEDR5
<= '0';
LEDR6
<= '0';
when five => -- Rotate the motor to spin and wash
water_pump <= '0';
soap
<= '0';
rotate_drum <= '1';
drain
<= '0';
enable_timer <= '1';
LEDR0
<= '1';
LEDR1
<= '1';
LEDR2
<= '1';
LEDR3
<= '1';
LEDR4
<= '1';
LEDR5
<= '0';
LEDR6
<= '0';
when six => -- Drain the water
water_pump <= '0';
soap
<= '0';
rotate_drum <= '0';
drain
<= '1';
enable_timer <= '1';
LEDR0
<= '1';
LEDR1
<= '1';
LEDR2
<= '1';
LEDR3
<= '1';
LEDR4
<= '1';
LEDR5
<= '1';
LEDR6
<= '0';
when seven => -- spin dry
water_pump <= '0';
soap
<= '0';
rotate_drum <= '1';
drain
<= '1';
enable_timer <= '1';
LEDR0
<= '1';
LEDR1
<= '1';
LEDR2
<= '1';
LEDR3
<= '1';
LEDR4
<= '1';
LEDR5
<= '1';
LEDR6
<= '1';
end case;
elsif reset='0' then
water_pump <= '0';
soap
<= '0';
rotate_drum <= '0';
drain
<= '0';
enable_timer <= '0';
LEDR0
<= '0';
LEDR1
<= '0';
LEDR2
<= '0';
LEDR3
<= '0';
LEDR4
<= '0';
LEDR5
<= '0';
LEDR6
<= '0';
end if;
end process;
end Behavioral;
