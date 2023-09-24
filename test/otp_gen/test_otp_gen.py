#====================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: One-time pad generator module testbench
#====================================================

import os
import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', 'src'))

@cocotb.test()
async def otp_gen_tb(dut):
    """One-time pad generator module testbench (EMPTY)""" 
    istart = dut.istart
    dut.ikey.value = int('FFEEDDCCBBAA99887766554433221100F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF', 16)
    dut.iIV.value = 0
    dut.inew_otp.value = 0

    cocotb.start_soon(Clock(dut.iclk, 40, units="ns").start())

    await FallingEdge(dut.iclk) 
    istart.value = 1
    await FallingEdge(dut.iclk) 
    istart.value = 0 
    await RisingEdge(dut.odone) 
    await FallingEdge(dut.iclk) 

def test_otp_gen():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 's_box.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 'round.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'gost.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'otp_gen.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="otp_gen",
            always=True,
    )

    runner.test(hdl_toplevel="otp_gen", test_module="test_otp_gen",)

if __name__ == "__main__":
    test_otp_gen()
