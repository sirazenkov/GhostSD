# GhostSD

[![design-simulation](https://github.com/sirazenkov/GhostSD/actions/workflows/simulation.yml/badge.svg)](https://github.com/sirazenkov/GhostSD/actions/workflows/simulation.yml)

GOST-based SDSC-card encryptor implemented on boards:
- [iCESugar-nano](https://github.com/wuxx/icesugar-nano)
- [Tang Primer 20K (with Dock ext-board)](https://wiki.sipeed.com/hardware/en/tang/tang-primer-20k/primer-20k.html)
- [PYNQ-Z1](https://digilent.com/reference/programmable-logic/pynq-z1/start)

SD cards are described in the Physical Layer [Simplified Specification](https://www.sdcard.org/downloads/pls/) by the SD Card Association and the SD Group.

Using the 64-bit GOST block cipher (Magma) in counter mode. \
More details in GOST R 34.12-2015 (RFC 8891) and GOST R 34.13-2015.

![alt text](https://github.com/sirazenkov/GhostSD/blob/master/docs/photo.png?raw=true)

### Directory structure
docs - diagrams and photos describing the project \
prj - project files for different flows \
src - Verilog HDL synthesizable sources \
test - testbenches written in Python and Verilog

### Required software
- Open-source flow (iCESugar-nano)
    - [yosys (v0.34)](https://github.com/YosysHQ/yosys) (synthesis)
    - [nextpnr (v0.6)](https://github.com/YosysHQ/nextpnr) (place & route)
    - [icepack](https://github.com/YosysHQ/icestorm/tree/master/icepack) (bitstream generation)
    - [icesprog](https://github.com/wuxx/icesugar/tree/master/tools/src) (device programming and debug)
- Gowin flow (Tang Primer 20K)
    - [Gowin EDA Education (v1.9.8.07)](https://www.gowinsemi.com/en/support/home/)
- Xilinx flow (PYNQ-Z1)
    - [Vivado (2020.2)](https://www.xilinx.com/products/design-tools/vivado.html)
- Simulation
    - [cocotb](https://github.com/cocotb/cocotb)
    - [pytest](https://docs.pytest.org/en/7.4.x/)
    - [Icarus Verilog](https://github.com/steveicarus/iverilog)
    - [GTKWave](https://github.com/gtkwave/gtkwave) (displays the .vcd waveforms generated by Icarus Verilog)

### Starting up
1. Connect the [PMOD microSD-card shield](https://aliexpress.ru/item/1005002079993579.html?spm=a2g0o.store_pc_allProduct.8148356.28.66223d9caZHKJO&pdp_npi=2%40dis%21RUB%21219%2C17%20%D1%80%D1%83%D0%B1.%21219%2C17%20%D1%80%D1%83%D0%B1.%21%21%21%21%21%40211675ce16734350768246290efb9d%2112000018671910390%21sh&sku_id=12000018671910390) to the FPGA board the same way as on the photo.
2. Insert your microSD card in the shield and connect the FPGA board to the computer.
3. Switch directory to `prj/<flow>` where chosen flow depends on the board you're using.
4. Run `make`. This will run synthesis, place & route and generate a bitstream.
5. Program the device with `make program` (might require `sudo`).
6. Reset the design:
    - `sudo make reset` for iCESugar-nano
    - press button S3 for Tang Primer 20K
    - press button BTN3 for PYNQ-Z1
7. Start encryption/decryption:
    - `sudo make start` for iCESugar-nano
    - press button S4 for Tang Primer 20K
    - press button BTN2 for PYNQ-Z1
8. Wait until the LED will light up:
    - yellow on iCESugar-nano
    - LED 5 on Tang Primer 20K
    - LD2 on PYNQ-Z1

    It means that operation finished successfully.
9. You can check if operation failed by
    - running `sudo make read_fail` and looking if it returns 1 for iCESugar-nano
    - looking if LED 4 on Tang Primer 20K lighted up
    - looking if LD3 on PYNQ-Z1 lighted up

### Simulation
- Run simulation for the whole design: `SIM=icarus HDL_TOPLEVEL_LANG=verilog pytest test -s`
- Run simulation for a specific module:
    1. `cd test/<path to module's testbench>`
    2. `SIM=icarus HDL_TOPLEVEL_LANG=verilog pytest test_<module_name>.py -s`
    3. open waveform: `gtkwave sim_build/wave.vcd`. After the window opens, `Ctrl+O` and select `add_waves.gtkw` file in the folder with the testbench.

### Ports 
![alt text](https://github.com/sirazenkov/GhostSD/blob/master/docs/GhostSD_system.png?raw=true)

### Operating time
Flow        |  1 GB   |  2 GB    | Blocks per transaction |  OTP/SD clk (MHz) |
------------|---------|----------|------------------------|-------------------|
Open-source | 13m 23s |  27m 4s  |           8            |   36/18           |
Gowin       | 5m 35s  |  10m 57s |           16           |   175/50          |
Xilinx      | 3m 54s  |  6m 24s  |           128          |   175/50          |

#### TODO:
1. External memory support
2. SDHC and SDXC cards support
