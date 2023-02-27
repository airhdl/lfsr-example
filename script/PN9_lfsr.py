#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# 'PN9' linear-feedback shift register Python model
# -----------------------------------------------------------------------------
# usage: lfsr.py [-h] [count]
#
# positional arguments:
#   count       number of output words to generate (default: 16)
#
# optional arguments:
#   -h, --help            show the help message and exit
#   -r [{dec,hex,bin}], --radix [{dec,hex,bin}]
#                         radix (default: hex)
#   -i [INIT], --init [INIT]
#                         initial value
# -----------------------------------------------------------------------------
# Generated on 2023-02-26 at 11:19 (UTC) by airhdl version 2023.01.3-754176777
# -----------------------------------------------------------------------------
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------

import argparse

PN9_LFSR_LENGTH = 9
PN9_LFSR_TAPS = [9, 5]
PN9_LFSR_INIT = 0x1FF

def get_bit(val, i):
    return (val >> i) & 0x1
def xor(a, b):
    return (a ^ b) & 0x1

def next_pn9_lfsr(val):
    feedback = get_bit(val, PN9_LFSR_TAPS[0]-1)
    for i in range(1, len(PN9_LFSR_TAPS)):
        feedback = xor(feedback, get_bit(val, PN9_LFSR_TAPS[i]-1))
    mask = 2**PN9_LFSR_LENGTH-1
    val = (val << 1) & mask
    val |= feedback
    return val

if __name__ == "__main__":
    # Parse the command line arguments
    arg_parser = argparse.ArgumentParser(
        description=f'linear feedback shift register (length: {PN9_LFSR_LENGTH} bits)')
    arg_parser.add_argument('count', help='number of output words to generate (default: 16)',
        nargs="?", type=int, default=16)
    arg_parser.add_argument('-r', '--radix', help='radix (default: hex)',
        nargs="?", type=str, default="hex", choices=["dec", "hex", "bin"])
    arg_parser.add_argument('-i', '--init', help="initial value (default: 0x{:X})".format(PN9_LFSR_INIT),
        nargs="?", type=str, default="0x{:X}".format(PN9_LFSR_INIT))
    args = arg_parser.parse_args()
    if args.init.startswith("0x"):
        init = int(args.init, 16)
    elif args.init.startswith("0b"):
        init = int(args.init, 2)
    else:
        init = int(args.init, 10)
    val = init
    # Compute the output sequence
    for i in range(0, args.count):
        if args.radix == "dec":
            print("{:d}".format(val))
        elif args.radix == "hex":
            digits = int((PN9_LFSR_LENGTH + 3) / 4)
            print(("{:0" + str(digits) + "X}").format(val))
        else:
            print(("{:0" + str(PN9_LFSR_LENGTH) + "b}").format(val))
        val = next_pn9_lfsr(val)
