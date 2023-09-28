#=================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: GOST round testbench
#=================================

import os
import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', '..', 'src'))

@cocotb.test()
async def round_tb(dut):
    """GOST round testbench""" 
    istart = dut.istart
    iblock = dut.iblock
    ikey   = dut.ikey
    oblock = dut.oblock
    i = 1

    f = open(test_dir +"/data.csv", "r")
 
    cocotb.start_soon(Clock(dut.iclk, 40, units="ns").start())

    while(True):
        dataset = f.readline().split(",")
        if(len(dataset) != 3):
            break
        dataset = [int(d, 16) for d in dataset]
        if(len(dataset) != 3):
            break
        await FallingEdge(dut.iclk) 
        iblock.value, ikey.value = dataset[0:2]
        istart.value = 1
        await FallingEdge(dut.iclk) 
        istart.value = 0 
        await RisingEdge(dut.odone) 
        await FallingEdge(dut.iclk) 
        assert int(oblock.value) == dataset[2], f"GOST round operation failed on {i} input value: output expected - {dataset[2]}, calculated - {int(oblock.value)}!"
        i = i + 1

def test_round():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 's_box.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 'round.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="round",
            always=True,
    )

    runner.test(hdl_toplevel="round", test_module="test_round",)

if __name__ == "__main__":
    test_round()

