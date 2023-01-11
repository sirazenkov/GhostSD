# GhostSD (Work in progress)
GOST-based SDSC-card encryptor implemented on [iCESugar-nano](https://github.com/wuxx/icesugar-nano) FPGA

![alt text](https://github.com/sirazenkov/GhostSD/blob/master/docs/photo.jpg?raw=true)

### Directory structure
docs - diagrams describing the project and a photo \
prj - everything for timing analysis, bitstream generation and running the design \
src - Verilog HDL synthesizable sources \
test - Testbenches written in Verilog

### Required software
- [Yosys](https://github.com/YosysHQ/yosys) (synthesis)
- [nextpnr](https://github.com/YosysHQ/nextpnr) (place & route)
- [icetime](https://github.com/YosysHQ/icestorm/tree/master/icetime) (timing analysis)
- [icepack](https://github.com/YosysHQ/icestorm/tree/master/icepack) (bitstream generation)
- [icesprog](https://github.com/wuxx/icesugar/tree/master/tools/src) (device programming and debug)
- [Icarus Verilog](https://github.com/steveicarus/iverilog) (simulation)

### Starting up
1. Connect the board with [PMOD microSD-card shield](https://aliexpress.ru/item/1005002079993579.html?spm=a2g0o.store_pc_allProduct.8148356.28.66223d9caZHKJO&pdp_npi=2%40dis%21RUB%21219%2C17%20%D1%80%D1%83%D0%B1.%21219%2C17%20%D1%80%D1%83%D0%B1.%21%21%21%21%21%40211675ce16734350768246290efb9d%2112000018671910390%21sh&sku_id=12000018671910390) to the computer.
2. Insert your microSD card in the shield.
3. Change directory to prj/: `cd prj`.
4. Run `make`. This will run synthesis, place & route, timing analysis and generate a bitstream.
5. Program the device with `make program`. Start and reset inputs are set to 0 before flashing the device.
6. Reset the design: `make reset`.
7. Start encryption/decryption: `make start`.
8. Wait until the yellow LED on the board will light up. It means that the operation finished successfully.
9. You can check if the operation failed by running `make read_fail`. If it returns 1 - opertion failed.

### Simulation
Switch to test/ directory to run simulation:
```
cd test
make
```
Run `make clean` to delete artifacts.

*All code was written in vim* :heart:
