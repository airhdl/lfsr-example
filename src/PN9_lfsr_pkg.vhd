-- -----------------------------------------------------------------------------
-- 'PN9' linear-feedback shift register VHDL package
-- -----------------------------------------------------------------------------
-- Generated on 2023-02-25 at 10:11 (UTC) by airhdl version 2023.01.3-754176777
-- -----------------------------------------------------------------------------
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package PN9_lfsr_pkg is

    type int_array is array (natural range <>) of integer;

    constant PN9_LFSR_LENGTH : natural                                        := 9;
    constant PN9_LFSR_TAPS   : int_array                                      := (8, 4);
    constant PN9_LFSR_INIT   : std_logic_vector(PN9_LFSR_LENGTH - 1 downto 0) := (others => '1');

    function next_pn9_lfsr(val : std_logic_vector(PN9_LFSR_LENGTH-1 downto 0)) return std_logic_vector;

end package PN9_lfsr_pkg;

package body PN9_lfsr_pkg is

    function next_pn9_lfsr(val : std_logic_vector(PN9_LFSR_LENGTH-1 downto 0)) return std_logic_vector is
        variable result   : std_logic_vector(PN9_LFSR_LENGTH - 1 downto 0);
        variable feedback : std_logic;
    begin
        feedback := val(PN9_LFSR_TAPS(0));
        for tap_idx in 1 to PN9_LFSR_TAPS'length - 1 loop
            feedback := feedback xor val(PN9_LFSR_TAPS(tap_idx));
        end loop;
        result   := val(PN9_LFSR_LENGTH - 2 downto 0) & feedback;
        return result;
    end function;

end package body PN9_lfsr_pkg;
