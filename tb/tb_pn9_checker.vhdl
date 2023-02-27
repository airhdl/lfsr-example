-------------------------------------------------------------------------------
--
--  AD9645 PN9 Sequence Checker Testbench
--
--  Description:  
--    VUnit testbench for the pn9_checker component
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

library vunit_lib;
context vunit_lib.vunit_context;

use std.textio.all;

entity tb_pn9_checker is
    generic(
        runner_cfg        : string;
        pn9_sequence_path : string      -- path to a text file containing the PN9 sequence words
    );
end entity;

architecture tb of tb_pn9_checker is

    constant WORD_LENGTH : natural := 14;
    constant CLK_PERIOD  : time    := 10 ns;

    signal clk       : std_logic := '0';
    signal rst       : std_logic;
    signal din_valid : std_logic;
    signal din       : std_logic_vector(WORD_LENGTH - 1 downto 0);
    signal pn9_ok    : std_logic;

begin

    -------------------------------------------------------------------------------
    -- Clock generator
    -------------------------------------------------------------------------------

    clk <= not clk after CLK_PERIOD / 2;

    -------------------------------------------------------------------------------
    -- Test process
    -------------------------------------------------------------------------------

    main : process
        file f            : text;
        variable idx      : natural;
        variable buf      : line;
        variable pn9_word : std_logic_vector(15 downto 0);
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop

            if run("operation") then
                info("reset the DUT");
                rst       <= '1';
                din_valid <= '0';
                wait for CLK_PERIOD * 3;
                wait until rising_edge(clk);
                rst       <= '0';

                info("apply the expected PN9 sequence");
                file_open(f, pn9_sequence_path, read_mode);
                idx := 0;
                while not endfile(f) loop
                    readline(f, buf);
                    hread(buf, pn9_word);
                    wait until rising_edge(clk);
                    din_valid <= '1';
                    din       <= pn9_word(din'range);
                    -- Check that the PN9 checker locks after a few samples and remains locked
                    if idx >= 3 then
                        check(pn9_ok = '1', "pn9_ok not set");
                    end if;
                    idx       := idx + 1;
                end loop;
                file_close(f);

                info("simulate an out-of-sequence word");
                wait until rising_edge(clk);
                din_valid <= '1';
                din       <= 14x"0000";
                wait until rising_edge(clk);
                din_valid <= '0';
                wait until rising_edge(clk);
                check(pn9_ok = '0', "pn9_ok still set");

            end if;
        end loop;

        test_runner_cleanup(runner);    -- Simulation ends here
    end process;

    -------------------------------------------------------------------------------
    -- Unit under test
    -------------------------------------------------------------------------------

    uut : entity work.pn9_checker
        generic map(
            WORD_LENGTH => WORD_LENGTH
        )
        port map(
            clk       => clk,
            rst       => rst,
            din_valid => din_valid,
            din       => din,
            pn9_ok    => pn9_ok
        );

end architecture;
