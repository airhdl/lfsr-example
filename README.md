# lfsr-example

A PN9 sequence checker for the AD9645 analog-to-digital converter, based on the [airhdl.com](https://airhdl.com/) VHDL/SystemVerilog generator for linear-feedback shift registers (LFSR).

The VHDL testbench is based on [VUnit](https://vunit.github.io/). To run the test in a simulator such as GHDL, please install VUnit as described [here](https://vunit.github.io/installing.html) and execute the following command:

```
python run.py
```

Related blog post: [Using airhdl to Design a PN Sequence Checker for an Analog Devices ADC](https://airhdl.com/blog/2023/02/27/using-airhdl-to-design-pn-sequence-checkers-for-analog-devices-adcs/)
