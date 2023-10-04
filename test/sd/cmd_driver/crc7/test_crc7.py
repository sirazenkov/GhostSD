#============================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: CRC7 (cyclic redundancy check) module testbench
#============================================================

import os
import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge

from random import randint

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', '..', 'src'))

import sys
sys.path.append(os.path.join(test_dir, '../../../'))
from common import crc7

NUM_OF_SAMPLES = 100 

async def reset(dut):
    await FallingEdge(dut.iclk)
    dut.irst.value = 1 
    dut.iunload.value = 0
    dut.idata.value = 0
    await FallingEdge(dut.iclk)
    dut.irst.value = 0
 
async def calc_crc(dut, data):
    await FallingEdge(dut.iclk)
    for i in range(39):
        dut.idata.value = (data >> (38-i)) & 1
        await FallingEdge(dut.iclk)
    dut.iunload.value = 1
    result = 0
    for i in range(7):
        result = (result << 1) | int(dut.ocrc.value)
        await FallingEdge(dut.iclk)
    return result

@cocotb.test()
async def crc7_tb(dut):
    """CRC7 module testbench""" 
    passed = True

    cocotb.start_soon(Clock(dut.iclk, 40, units="ns").start())

    for i in range(NUM_OF_SAMPLES):
        await reset(dut)
        block = randint(0,1<<39)
        expected_crc7 = crc7(block)
        rtl_crc7 = await calc_crc(dut, block)
        assert rtl_crc7 == expected_crc7, f"CRC7 calculation failed on sample {i}: expected - {expected_crc7}, calculated - {rtl_crc7}!"

def test_crc7():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'sd', 'cmd_driver', 'crc7.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="crc7",
            always=True,
    )

    runner.test(hdl_toplevel="crc7", test_module="test_crc7",)

if __name__ == "__main__":
    test_crc7()

