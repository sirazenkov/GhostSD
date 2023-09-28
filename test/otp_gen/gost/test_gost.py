#=======================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: GOST (Magma) block cipher module testbench
#=======================================================

import os
import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', 'src'))

@cocotb.test()
async def gost_tb(dut):
    """GOST (Magma) block cipher module testbench""" 
    istart = dut.istart
    oblock = dut.oblock
    dut.ikey.value = int('FFEEDDCCBBAA99887766554433221100F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF', 16)
    dut.iblock.value = int('FEDCBA9876543210', 16)
    ciphertext = int('4EE901E5C2D8CA3D', 16)

    cocotb.start_soon(Clock(dut.iclk, 40, units="ns").start())

    await FallingEdge(dut.iclk) 
    istart.value = 1
    await FallingEdge(dut.iclk) 
    istart.value = 0 
    await RisingEdge(dut.odone) 
    await FallingEdge(dut.iclk) 
    assert int(oblock.value) == ciphertext, f"GOST (Magma) block cipher operation failed: output expected - {ciphertext}, calculated - {oblock.value}!"

def test_gost():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 's_box.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 'round.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'gost.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="gost",
            always=True,
    )

    runner.test(hdl_toplevel="gost", test_module="test_gost",)

if __name__ == "__main__":
    test_gost()

