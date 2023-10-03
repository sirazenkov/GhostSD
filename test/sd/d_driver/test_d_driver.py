#======================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: D driver module testbench
#======================================

import os
import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import random

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', 'src'))

import sys
sys.path.append(os.path.join(test_dir, '../../'))
from common import *

RAM_BLOCKS = 8
NUM_OF_TRANSACTIONS = 2

async def ram(dut):
    mem = [[0 for i in range(1024)] for j in range(RAM_BLOCKS)]
    while(True):
        await RisingEdge(dut.iclk)
        if(int(dut.owrite_en.value) == 1):
            mem[int(dut.osel_ram.value)][int(dut.oaddr.value)] = int(dut.owdata.value)
        multiplex = [mem[i][int(dut.oaddr.value)] for i in range(RAM_BLOCKS)]
        await FallingEdge(dut.iclk)
        dut.irdata.value = multiplex[int(dut.osel_ram.value)]

async def send_status(dut):
    blocks = [randint(0,15) for i in range(128)]
    crc_packets = gen_crc16_packets(blocks)

    await FallingEdge(dut.iclk)
    dut.istatus.value = 1
    await FallingEdge(dut.iclk)
    dut.istatus.value = 0 

    await random_delay(dut, 10)

    await FallingEdge(dut.iclk)
    dut.idata_sd.value = 0 # Start bit
    await FallingEdge(dut.iclk)

    for i in range(128):
        dut.idata_sd.value = blocks[i]
        await FallingEdge(dut.iclk)

    for i in range(16):
        dut.idata_sd.value = crc_packets[i]
        await FallingEdge(dut.iclk)

    dut.idata_sd.value = 0xF # End bit
    await FallingEdge(dut.iclk)

    await ClockCycles(dut.iclk, 8, rising=False)

    return (int(dut.oread_done.value) == 1, int(dut.owrite_done.value) == 1)

async def send_blocks(dut, blocks, crc_packets):
    await FallingEdge(dut.iclk)
    dut.istart.value = 1
    await FallingEdge(dut.iclk)
    dut.istart.value = 0
    for j in range(RAM_BLOCKS):
        await random_delay(dut, 10)
        await FallingEdge(dut.iclk)
        dut.idata_sd.value = 0 # Start bit
        await FallingEdge(dut.iclk)
        for i in range(1024):
            dut.idata_sd.value = blocks[j][i]
            await FallingEdge(dut.iclk)
        for i in range(16):
            dut.idata_sd.value = crc_packets[j][i]
            await FallingEdge(dut.iclk)
        dut.idata_sd.value = 0xF # End bit
    await RisingEdge(dut.oread_done)
    await FallingEdge(dut.iclk)
    return (int(dut.oread_done.value) == 1, int(dut.owrite_done.value) == 1)

async def receive_blocks(dut, expected_blocks, crc_packets):
    await FallingEdge(dut.iclk)
    dut.istart.value = 1
    await FallingEdge(dut.iclk)
    dut.istart.value = 0
    blocks = [[] for i in range(RAM_BLOCKS)]
    for j in range(RAM_BLOCKS):
        await FallingEdge(dut.iclk)
        for i in range(1024):
            blocks[j].append(int(dut.odata_sd.value))
            await FallingEdge(dut.iclk)
        crc_failed = False
        for i in range(16):
            if(int(dut.odata_sd.value) != crc_packets[j][i]):
                crc_failed = True
            await FallingEdge(dut.iclk)
        await random_delay(dut, 10)
        await FallingEdge(dut.iclk)
        dut.istart.value = 1
        if (j != 7):
            await RisingEdge(dut.odata_sd_en)
            await FallingEdge(dut.iclk)
            dut.istart.value = 0
    await RisingEdge(dut.owrite_done)
    blocks_equal = expected_blocks == blocks
    return (blocks_equal, crc_failed)

async def random_delay(dut, upper_bound):
    delay = random.randint(1, upper_bound)
    await ClockCycles(dut.iclk, delay)

@cocotb.test()
async def d_driver_tb(dut):
    """D line's driver testbench""" 

    cocotb.start_soon(Clock(dut.iclk, 55, units="ns").start())

    await FallingEdge(dut.iclk)
    dut.irst.value     = 1 
    dut.idata_sd.value = 0xF
    dut.istart.value   = 0
    await FallingEdge(dut.iclk)
    dut.irst.value = 0
    await FallingEdge(dut.iclk)

    cocotb.start_soon(ram(dut))

    read_done, write_done = await send_status(dut)
    assert not read_done, "Mixed up status and data!"
    assert write_done, "Status read failed!"

    for i in range(NUM_OF_TRANSACTIONS):
        blocks = [[random.randint(0,15) for i in range(1024)] for j in range(RAM_BLOCKS)]
        crc_packets = [gen_crc16_packets(block) for block in blocks]

        await random_delay(dut, 10)

        done, crc_fail = await send_blocks(dut, blocks, crc_packets)
        assert not crc_fail, f"CRC16 check for blocks pack {i} failed!"
        assert done, f"Module did not receive blocks pack {i} successfully!"

        await random_delay(dut, 10)

        blocks_equal, crc_fail = await receive_blocks(dut, blocks, crc_packets)
        assert blocks_equal, f"Blocks pack {i} from module does not equal the initial blocks pack {i}!"
        assert not crc_fail, f"Wrong CRC in blocks pack {i} from the module!"
        assert int(dut.odata_sd_en.value) == 0, f"Finish bit not set in blocks pack {i} from module!"

def test_d_driver():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'sd', 'd_driver', 'crc16.v'),
                       os.path.join(rtl_dir, 'sd', 'd_driver', 'd_driver.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="d_driver",
            always=True,
    )

    runner.test(hdl_toplevel="d_driver", test_module="test_d_driver",)

if __name__ == "__main__":
    test_d_driver()

