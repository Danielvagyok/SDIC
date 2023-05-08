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
use IEEE.NUMERIC_STD.ALL;

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
           sel : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out std_logic);
end scoreboard_counter;

architecture Behavioral of scoreboard_counter is

type states is (start, idle, count_down, count_up);
signal current_state, next_state : states;

signal score: std_logic_vector (15 downto 0);

component driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end component driver7seg;

component debounce is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           btnDeb : out STD_LOGIC);
end component;

signal incDeb, decDeb : std_logic;

begin

deb1 : debounce port map (clk => clk, btn => inc, btnDeb => incDeb);
deb2 : debounce port map (clk => clk, btn => dec, btnDeb => decDeb);

ff: process(rst, clk)
begin
  if rst = '1' then
    current_state <= start;
  elsif rising_edge(clk) then
    current_state <= next_state;  
  end if;
end process;

clc: process(current_state, incDeb, decDeb)
begin
    case current_state is
        when start => next_state <= idle;
        when idle => if (incDeb xor decDeb) = '0' then
                        next_state <= idle;
                     elsif incDeb = '1' then
                        next_state <= count_up;
                     elsif decDeb = '1' then
                        next_state <= count_down;
                     else
                        next_state <= start;
                     end if;
        when count_up => next_state <= idle;
        when count_down => next_state <= idle;
        when others => next_state <= start;
    end case;
end process;

count: process(rst, clk)
--variable thousand : integer range 0 to 9 := 0;
--  variable hundred : integer range 0 to 9 := 0;
  variable ten : integer range 0 to 9 := 0;
  variable unit : integer range 0 to 9 := 0;
begin
  if rst = '1' then
--    thousand := 0;
--    hundred := 0;
    ten := 0;
    unit := 0;
  elsif rising_edge(clk) then
    if current_state = count_up then
      if unit = 9  then
        unit := 0;
        if ten = 9 then
          ten := 0;
        else  
          ten := ten + 1;
        end if;  
      else
        unit := unit + 1;
      end if;
    elsif current_state = count_down then
        if unit = 0 then
            unit := 9;
            if ten = 0 then 
              ten := 9;
            else  
              ten := ten - 1;
            end if;  
        else
            unit := unit - 1;
        end if;
    end if;
  end if;  
  
  score <= std_logic_vector(to_unsigned(15,4)) &
           std_logic_vector(to_unsigned(15,4)) &
           std_logic_vector(to_unsigned(ten,4)) &
           std_logic_vector(to_unsigned(unit,4));
  
end process;

display_score: driver7seg port map (clk => clk,
                             Din => score,
                             an => sel,
                             seg => seg,
                             dp_in => (others =>'0'),
                             dp_out => dp,
                             rst => rst);

end Behavioral;
