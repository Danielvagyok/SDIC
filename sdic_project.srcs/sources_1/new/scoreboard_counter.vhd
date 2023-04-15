----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2023 02:14:52 PM
-- Design Name: 
-- Module Name: scoreboard_counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scoreboard_counter is
    Port ( inc : in STD_LOGIC;
           dec : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           seg : out STD_LOGIC_VECTOR (0 to 6);
           sel : out STD_LOGIC_VECTOR (3 downto 0));
end scoreboard_counter;

architecture Behavioral of scoreboard_counter is

type states is (start, idle, count_down, count_up);
signal current_state, next_state : states;

component driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end component driver7seg;

begin

process(rst, clk)
begin
  if rst = '1' then
    current_state <= start;
  elsif rising_edge(clk) then
    current_state <= next_state;  
  end if;
end process;

process(current_state, inc, dec)
begin
    case current_state is
        when start => next_state <= idle;
        when idle => if (inc xor dec) = '0' then
                        next_state <= idle;
                     elsif inc = '1' then
                        next_state <= count_up;
                     elsif dec = '1' then
                        next_state <= count_down;
                     else
                        next_state <= start;
                     end if;
        when count_up => next_state <= idle;
        when count_down => next_state <= idle;
        when others => next_state <= start;
    end case;
end process;

end Behavioral;
