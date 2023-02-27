##-----------------------------------------------------------------------------
##
##  AD9645 PN9 Sequence Checker
##
##  Description:  
##    Prints the 511 words of the AD9645 PN9 test sequence
##
##  Usage:
##    python pn9.py
##
##  Author(s):
##    Guy Eschemann, guy@airhdl.com
##
##-----------------------------------------------------------------------------
##
## Copyright (c) 2023 Guy Eschemann
## 
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
## 
##     http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
##-----------------------------------------------------------------------------

from PN9_lfsr import *

WORD_LENGTH = 14

if __name__ == "__main__":

    sequence_length = 2 ** PN9_LFSR_LENGTH - 1
    lfsr = PN9_LFSR_INIT
    for i in range(sequence_length):
        pn9_word = 0
        for j in range(WORD_LENGTH):
            msb = (lfsr >> (PN9_LFSR_LENGTH - 1)) & 0x1
            pn9_word = (pn9_word << 1) | msb
            lfsr = next_pn9_lfsr(lfsr)
        pn9_word &= 2**WORD_LENGTH - 1
        pn9_word ^= 2**(WORD_LENGTH-1)  # invert MSB
        print("%.4X" % pn9_word)
