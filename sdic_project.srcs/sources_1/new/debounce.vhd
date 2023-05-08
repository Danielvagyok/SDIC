----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2023 12:51:47 PM
-- Design Name: 
-- Module Name: debounce - Behavioral
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

entity debounce is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           btnDeb : out STD_LOGIC);
end debounce;

architecture Behavioral of debounce is

signal pressed : boolean := false;

begin

process (clk)
begin

    if rising_edge(clk) then
        if btn = '1' then
            pressed <= true;
        else
            if pressed then
                btnDeb <= '1';
            else
                btnDeb <= '0';
            end if;
            
            pressed <= false;
        end if;
    end if;

end process;

end Behavioral;
