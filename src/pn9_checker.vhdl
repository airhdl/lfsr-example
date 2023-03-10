-------------------------------------------------------------------------------
--
--  AD9645 PN9 Sequence Checker
--
--  Description:  
--    An test pattern checker for the PN9 sequence generated by the AD945
--    analog-to-digital converter.
--
--  Author(s):
--    Guy Eschemann, guy@airhdl.com
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2023 Guy Eschemann
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.PN9_lfsr_pkg.all;

entity pn9_checker is
    generic(
        WORD_LENGTH : natural := 14
    );
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        din_valid : in  std_logic;
        din       : in  std_logic_vector(WORD_LENGTH - 1 downto 0);
        pn9_ok    : out std_logic
    );
end entity;

architecture rtl of pn9_checker is

    -------------------------------------------------------------------------------
    -- Constants
    -------------------------------------------------------------------------------

    constant PN9_INIT_VALUE : std_logic_vector(13 downto 0) := 14x"1FE0";

    -------------------------------------------------------------------------------
    -- Subprograms
    -------------------------------------------------------------------------------

    -- Compute next expected PN9 word, given the current LFSR state
    procedure next_pn9_word(lfsr_state : in std_logic_vector; lfsr_state_next : out std_logic_vector; pn9_word : out std_logic_vector) is
        variable result          : std_logic_vector(WORD_LENGTH - 1 downto 0);
        variable lfsr_state_curr : std_logic_vector(lfsr_state'range);
    begin
        lfsr_state_curr     := lfsr_state;
        for i in 0 to WORD_LENGTH - 1 loop
            result          := result(result'high - 1 downto 0) & lfsr_state_curr(lfsr_state_curr'high);
            lfsr_state_curr := next_pn9_lfsr(lfsr_state_curr);
        end loop;
        result(result'high) := not result(result'high); -- invert MSB
        lfsr_state_next     := lfsr_state_curr;
        pn9_word            := result;
    end procedure;

    -------------------------------------------------------------------------------
    -- Types
    -------------------------------------------------------------------------------

    type state_t is (SYNC, TRACK);

    -------------------------------------------------------------------------------
    -- Signals
    -------------------------------------------------------------------------------

    signal state      : state_t                                        := SYNC;
    signal lfsr_state : std_logic_vector(PN9_LFSR_LENGTH - 1 downto 0) := PN9_LFSR_INIT;

begin

    checker : process(clk) is
        variable lfsr_state_next : std_logic_vector(PN9_LFSR_LENGTH - 1 downto 0);
        variable din_expected    : std_logic_vector(WORD_LENGTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pn9_ok     <= '0';
                lfsr_state <= PN9_LFSR_INIT;
                state      <= SYNC;
            else

                case state is
                    -- Wait for the PN9 sequence initial value, i.e. 0x1FE0
                    when SYNC =>
                        next_pn9_word(PN9_LFSR_INIT, lfsr_state_next, din_expected);
                        if din_valid = '1' and din = din_expected then
                            lfsr_state <= lfsr_state_next;
                            state      <= TRACK;
                        end if;

                    -- Check if the current input word matches the next expected PN9 word. If not, resynchronize.
                    when TRACK =>
                        next_pn9_word(lfsr_state, lfsr_state_next, din_expected);
                        if din_valid = '1' then
                            if din = din_expected then
                                pn9_ok     <= '1';
                                lfsr_state <= lfsr_state_next;
                            else
                                pn9_ok <= '0';
                                state  <= SYNC;
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process;

end architecture;
