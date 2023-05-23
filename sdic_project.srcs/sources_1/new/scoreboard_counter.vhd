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
           ch : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sw : in std_logic_vector (15 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           sel : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out std_logic);
end scoreboard_counter;

architecture Behavioral of scoreboard_counter is

type states is (start, idle, playerSel, count_down, count_up);
signal current_state, next_state : states;

signal score: std_logic_vector (15 downto 0);
signal player: std_logic := '0';

shared variable point : integer range 1 to 17;

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

signal incDeb, decDeb, chDeb : std_logic;

begin

deb1 : debounce port map (clk => clk, btn => inc, btnDeb => incDeb);
deb2 : debounce port map (clk => clk, btn => dec, btnDeb => decDeb);
deb3 : debounce port map (clk => clk, btn => ch, btnDeb => chDeb);


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

player_select: process(rst, clk)
begin
    if rst = '1' then
        player <= '0';
    elsif rising_edge(clk) then
        if current_state = idle and chDeb = '1' then
            case player is
                when '0' => player <= '1';
                when '1' => player <= '0';
                when others => player <= 'X';
            end case;
        end if;
    end if;
end process;

point_select: process(clk)
begin
    if rising_edge(clk) then
        point := 1;
        for i in 0 to 15 loop
            if sw(i) = '1' then
                point := point + 1;
            end if;
        end loop;
    end if;
end process;

count: process(rst, clk)
--variable thousand : integer range 0 to 9 := 0;
--  variable hundred : integer range 0 to 9 := 0;
  variable ten1 : integer range 0 to 9 := 0;
  variable ten2 : integer range 0 to 9 := 0;
  variable unit1 : integer range 0 to 9 := 0;
  variable unit2 : integer range 0 to 9 := 0;
  variable carry : integer range 0 to 2;
  variable borrow : integer range 0 to 2;
begin
  if rst = '1' then
--    thousand := 0;
--    hundred := 0;
    ten1 := 0;
    ten2 := 0;
    unit1 := 0;
    unit2 := 0;
  elsif rising_edge(clk) then
    if player = '0' then
        if current_state = count_up then
          if unit1 + point > 9  then
            if unit1 + point - 10 > 9 then
                carry := 2;
            else
                carry := 1;
            end if;
                     
            case carry is
                when 1 => unit1 := unit1 + point - 10;
                when 2 => unit1 := unit1 + point - 20;
            end case;
            
            if ten1 + carry > 9 then
              ten1 := 0;
            else  
              ten1 := ten1 + carry;
            end if;
              
          else
            unit1 := unit1 + point;
          end if;
          
        elsif current_state = count_down then
           if unit1 - point < 0  then
            if unit1 - point + 10 < 0 then
                borrow := 2;
            else
                borrow := 1;
            end if;
                     
            case borrow is
                when 1 => unit1 := unit1 - point + 10;
                when 2 => unit1 := unit1 - point + 20;
            end case;
            
            if ten1 - borrow < 0 then
              ten1 := 9;
            else  
              ten1 := ten1 - borrow;
            end if;
              
          else
            unit1 := unit1 - point;
          end if;
        end if;
     elsif player = '1' then
         if current_state = count_up then
          if unit2 + point > 9  then
            if unit2 + point - 10 > 9 then
                carry := 2;
            else
                carry := 1;
            end if;
                     
            case carry is
                when 1 => unit2 := unit2 + point - 10;
                when 2 => unit2 := unit2 + point - 20;
            end case;
            
            if ten2 + carry > 9 then
              ten2 := 0;
            else  
              ten2 := ten2 + carry;
            end if;
              
          else
            unit2 := unit2 + point;
          end if;
          
        elsif current_state = count_down then
           if unit2 - point < 0  then
            if unit2 - point + 10 < 0 then
                borrow := 2;
            else
                borrow := 1;
            end if;
                     
            case borrow is
                when 1 => unit2 := unit2 - point + 10;
                when 2 => unit2 := unit2 - point + 20;
            end case;
            
            if ten2 - borrow < 0 then
              ten2 := 9;
            else  
              ten2 := ten2 - borrow;
            end if;
              
          else
            unit2 := unit2 - point;
          end if;
        end if;
     end if;
  end if;  
  
  score <= std_logic_vector(to_unsigned(ten2,4)) &
           std_logic_vector(to_unsigned(unit2,4)) &
           std_logic_vector(to_unsigned(ten1,4)) &
           std_logic_vector(to_unsigned(unit1,4));
  
end process;

display_score: driver7seg port map (clk => clk,
                             Din => score,
                             an => sel,
                             seg => seg,
                             dp_in => "0100",
                             dp_out => dp,
                             rst => rst);

end Behavioral;
