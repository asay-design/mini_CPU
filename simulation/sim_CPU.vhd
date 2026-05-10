----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.05.2026 14:46:56
-- Design Name: 
-- Module Name: sim_CPU - Behavioral
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim_CPU is
end sim_CPU;

architecture sim of sim_CPU is

    signal start : std_logic := '0';
    signal clk   : std_logic := '0';

    component design_1_wrapper is
        port (
            clk     : in std_logic;
            start_0 : in std_logic
        );
    end component;
begin

    clk_proc : process
    begin
        while TRUE loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    start_proc : process
    begin
        wait for 100 ns; ----
        start <= '1';

    end process;

    CPU_inst : design_1_wrapper
    port map(
        clk     => clk,
        start_0 => start
    );
end sim;