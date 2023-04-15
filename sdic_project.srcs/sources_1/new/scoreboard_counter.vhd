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
           d1 : out STD_LOGIC_VECTOR (7 downto 0);
           d0 : out STD_LOGIC_VECTOR (7 downto 0));
end scoreboard_counter;

architecture Behavioral of scoreboard_counter is

begin


end Behavioral;
