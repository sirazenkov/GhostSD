#=============================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: CRC16 (cyclic redundancy check) module testbench
#=============================================================

import os
import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge

import random

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', '..', 'src'))

import sys
sys.path.append(os.path.join(test_dir, '../../../'))
from common import crc16

NUM_OF_SAMPLES = 10 

async def reset(dut):
    await FallingEdge(dut.iclk)
    dut.irst.value = 1 
    dut.iunload.value = 0
    dut.idata.value = 0
    await FallingEdge(dut.iclk)
    dut.irst.value = 0
 
async def calc_crc(dut, data):
    await FallingEdge(dut.iclk)
    for i in range(1024):
        dut.idata.value = (data >> (1023-i)) & 1
        await FallingEdge(dut.iclk)
    dut.iunload.value = 1
    result = 0
    for i in range(16):
        result = (result << 1) | int(dut.ocrc.value)
        await FallingEdge(dut.iclk)
    return result

@cocotb.test()
async def crc16_tb(dut):
    """CRC16 module testbench""" 
    passed = True

    cocotb.start_soon(Clock(dut.iclk, 40, units="ns").start())

    for i in range(NUM_OF_SAMPLES):
        await reset(dut)
        block = random.randint(0,1<<1024)
        expected_crc16 = crc16(block)
        rtl_crc16 = await calc_crc(dut, block)
        assert rtl_crc16 == expected_crc16, f"CRC16 calculation failed on sample {i}: expected - {expected_crc16}, calculated - {rtl_crc16}!"

def test_crc16():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'sd', 'd_driver', 'crc16.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="crc16",
            always=True,
    )

    runner.test(hdl_toplevel="crc16", test_module="test_crc16",)

if __name__ == "__main__":
    test_crc16()
