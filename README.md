# GhostSD

[![design-simulation](https://github.com/sirazenkov/GhostSD/actions/workflows/simulation.yml/badge.svg)](https://github.com/sirazenkov/GhostSD/actions/workflows/simulation.yml)

GOST-based SDSC-card encryptor implemented on boards:
- [iCESugar-nano](https://github.com/wuxx/icesugar-nano)
- [Tang Primer 20K](https://wiki.sipeed.com/hardware/en/tang/tang-primer-20k/primer-20k.html)

![alt text](https://github.com/sirazenkov/GhostSD/blob/master/docs/photo.png?raw=true)

### Directory structure
docs - diagrams describing the project and photos \
prj - project files for different flows \
src - Verilog HDL synthesizable sources \
test - Testbenches written in Python and Verilog

### Required software
- Open-source flow
    - [Yosys](https://github.com/YosysHQ/yosys) (synthesis)
    - [nextpnr](https://github.com/YosysHQ/nextpnr) (place & route)
    - [icetime](https://github.com/YosysHQ/icestorm/tree/master/icetime) (timing analysis)
    - [icepack](https://github.com/YosysHQ/icestorm/tree/master/icepack) (bitstream generation)
    - [icesprog](https://github.com/wuxx/icesugar/tree/master/tools/src) (device programming and debug)
- Gowin flow
    - [Gowin EDA](https://www.gowinsemi.com/en/support/home/)
- Simulation
    - [cocotb](https://github.com/cocotb/cocotb)
    - [Icarus Verilog](https://github.com/steveicarus/iverilog)

### Starting up
1. Connect the [PMOD microSD-card shield](https://aliexpress.ru/item/1005002079993579.html?spm=a2g0o.store_pc_allProduct.8148356.28.66223d9caZHKJO&pdp_npi=2%40dis%21RUB%21219%2C17%20%D1%80%D1%83%D0%B1.%21219%2C17%20%D1%80%D1%83%D0%B1.%21%21%21%21%21%40211675ce16734350768246290efb9d%2112000018671910390%21sh&sku_id=12000018671910390) to the FPGA board the same way as on the photo.
2. Insert your microSD card in the shield and connect the FPGA board to the computer.
3. Switch directory to prj/open-source for iCESugar-nano and prj/gowin for Tang Primer 20K.
4. Run `make`. This will run synthesis, place & route, timing analysis and generate a bitstream.
5. Program the device with `make program` (might require sudo).
6. Reset the design: `sudo make reset` for iCESugar-nano and press button S3 for Tang Primer 20K.
7. Start encryption/decryption: `sudo make start` for iCESugar-nano and press button S4 for Tang Primer 20K.
8. Wait until the yellow LED on the iCESugar-nano board or LED 5 on Tang Primer 20K will light up. It means that the operation finished successfully.
9. You can check if the operation failed by running `sudo make read_fail` for iCESugar-nano. If it returns 1 or LED 4 on Tang Primer 20K lighted up - opertion failed. 

### Simulation
Run simulation: `make -C test`. \
You may delete output files with `make -C test cleanall`.

### Project scheme
![alt text](https://github.com/sirazenkov/GhostSD/blob/master/docs/GhostSD_system.png?raw=true)
