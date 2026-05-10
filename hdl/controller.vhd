----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2026 12:38:42
-- Design Name: 
-- Module Name: controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Basic 4 instruction CPU with 6b addr
--
-- Instruction      Code           Operation
--   ADD          00AAAAAA      AC←AC  M[AAAAAA]
--   AND          01AAAAAA      AC←AC ∧ M[AAAAAA]
--   JMP          10AAAAAA      GOTO AAAAAA
--   INC          11XXXXXX      AC←AC  1
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
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
    generic (MEM_READ_CYCLES : integer := 2);
    port (
        clk        : in std_logic;
        start      : in std_logic;
        mem_data_r : in std_logic_vector(7 downto 0);
        mem_addr   : out std_logic_vector(5 downto 0);
        mem_data_w : out std_logic_vector(7 downto 0)
    );
end controller;

architecture Behavioral of controller is
    type cpu_state_type is(
    IDLE,
    FETCH1,
    FETCH2,
    FETCH3,
    ADD1,
    ADD2,
    AND1,
    AND2,
    JMP,
    INC
    );
    signal state        : cpu_state_type               := IDLE;

    --Signals
    signal mem_data_r_s : std_logic_vector(7 downto 0) := (others => '0');
    signal mem_data_w_s : std_logic_vector(7 downto 0) := (others => '0');
    signal mem_en_s     : std_logic                    := '0';

    --Registers 
    signal data_reg     : std_logic_vector(7 downto 0) := (others => '0');
    signal inst_reg     : std_logic_vector(1 downto 0) := (others => '0');
    signal addr_reg     : std_logic_vector(5 downto 0) := (others => '0');
    signal pc_reg       : std_logic_vector(5 downto 0) := (others => '0');
    signal ac_reg       : std_logic_vector(7 downto 0) := (others => '0');

    --Counters
    signal dummy_cnt    : UNSIGNED(5 downto 0)         := (others => '0');

begin
    mem_addr     <= addr_reg;
    mem_data_r_s <= mem_data_r;

    process (clk) begin
        if (rising_edge(clk)) then
            case state is
                when IDLE =>
                    if start = '1' then
                        state <= FETCH1;
                    end if;
                when FETCH1 =>
                    addr_reg  <= pc_reg;
                    dummy_cnt <= dummy_cnt + 1;
                    if (dummy_cnt >= MEM_READ_CYCLES - 1) then
                        state     <= FETCH2;
                        dummy_cnt <= (others => '0');
                    end if;
                when FETCH2 =>
                    dummy_cnt <= dummy_cnt + 1;
                    if (dummy_cnt >= MEM_READ_CYCLES - 1) then
                        data_reg  <= mem_data_r_s;
                        pc_reg    <= std_logic_vector(unsigned(pc_reg) + 1);
                        state     <= FETCH3;
                        dummy_cnt <= (others => '0');
                    end if;
                when FETCH3 =>
                    inst_reg  <= data_reg(7 downto 6);
                    addr_reg  <= data_reg(5 downto 0);
                    dummy_cnt <= dummy_cnt + 1;
                    if (dummy_cnt >= MEM_READ_CYCLES - 1) then
                        case data_reg(7 downto 6) is
                            when "00" =>
                                state <= ADD1;
                            when "01" =>
                                state <= AND1;
                            when "10" =>
                                state <= JMP;
                            when "11" =>
                                state <= INC;
                            when others =>
                                state <= IDLE;
                        end case;
                        dummy_cnt <= (others => '0');
                    end if;
                when ADD1 =>
                    dummy_cnt <= dummy_cnt + 1;
                    if (dummy_cnt >= MEM_READ_CYCLES - 1) then
                        data_reg  <= mem_data_r_s;
                        state     <= ADD2;
                        dummy_cnt <= (others => '0');
                    end if;
                when ADD2 =>
                    ac_reg <= std_logic_vector(unsigned(ac_reg) + UNSIGNED(data_reg));
                    state  <= FETCH1;
                when AND1 =>
                    dummy_cnt <= dummy_cnt + 1;
                    if (dummy_cnt >= MEM_READ_CYCLES - 1) then
                        data_reg  <= mem_data_r_s;
                        state     <= AND2;
                        dummy_cnt <= (others => '0');
                    end if;
                when AND2 =>
                    ac_reg <= ac_reg and data_reg;
                    state  <= FETCH1;
                when JMP =>
                    pc_reg <= mem_data_r_s(5 downto 0);
                    state  <= FETCH1;
                when INC =>
                    ac_reg <= std_logic_vector(unsigned(ac_reg) + 1);
                    state  <= FETCH1;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;