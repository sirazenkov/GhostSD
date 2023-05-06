#======================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: D driver module testbench
#======================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import logging

import random

import sys
sys.path.insert(1, '../../')
from common import *

NUM_OF_TRANSACTIONS = 2

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class D_driver_BFM():
    def __init__(self):
        self.dut = cocotb.top
        self.multiplex = [0 for i in range(8)]

    async def start_operation(self):
        cocotb.start_soon(Clock(self.dut.iclk, 55, units="ns").start())
        cocotb.start_soon(self.ram())

    async def reset(self):
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value     = 1 
        self.dut.idata_sd.value = 0xF
        self.dut.istart.value   = 0
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
        await FallingEdge(self.dut.iclk)

    async def ram(self):
        mem = [[0 for i in range(1024)] for j in range(8)]
        while(True):
            await RisingEdge(self.dut.iclk)
            if(int(self.dut.owrite_en.value) == 1):
                mem[int(self.dut.osel_ram.value)][int(self.dut.oaddr.value)] = int(self.dut.owdata.value)
            self.multiplex = [mem[i][int(self.dut.oaddr.value)] for i in range(8)]
            await FallingEdge(self.dut.iclk)
            self.dut.irdata.value = self.multiplex[int(self.dut.osel_ram.value)]

    async def send_blocks(self, blocks, crc_packets):
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 0
        for j in range(8):
            await self.random_delay(10)
            await FallingEdge(self.dut.iclk)
            self.dut.idata_sd.value = 0 # Start bit
            await FallingEdge(self.dut.iclk)
            for i in range(1024):
                self.dut.idata_sd.value = blocks[j][i]
                await FallingEdge(self.dut.iclk)
            for i in range(16):
                self.dut.idata_sd.value = crc_packets[j][i]
                await FallingEdge(self.dut.iclk)
            self.dut.idata_sd.value = 0xF # End bit
        await RisingEdge(self.dut.oread_done)
        await FallingEdge(self.dut.iclk)
        return (int(self.dut.oread_done.value) == 1, int(self.dut.owrite_done.value) == 1)

    async def receive_blocks(self, expected_blocks, crc_packets):
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 0
        blocks = [[] for i in range(8)]
        for j in range(8):
            await FallingEdge(self.dut.iclk)
            for i in range(1024):
                blocks[j].append(int(self.dut.odata_sd.value))
                await FallingEdge(self.dut.iclk)
            crc_failed = False
            for i in range(16):
                if(int(self.dut.odata_sd.value) != crc_packets[j][i]):
                    crc_failed = True
                await FallingEdge(self.dut.iclk)
            await self.random_delay(10)
            await FallingEdge(self.dut.iclk)
            self.dut.istart.value = 1
            if (j != 7):
                await RisingEdge(self.dut.odata_sd_en)
                await FallingEdge(self.dut.iclk)
                self.dut.istart.value = 0
        await RisingEdge(self.dut.owrite_done)
        blocks_equal = expected_blocks == blocks
        return (blocks_equal, crc_failed)

    async def random_delay(self, upper_bound):
        delay = random.randint(1,upper_bound)
        await ClockCycles(self.dut.iclk, delay)

@cocotb.test()
async def d_driver_tb(_):
    """D line's driver testbench""" 
    passed = True
    bfm = D_driver_BFM()
    await bfm.start_operation()
    await bfm.reset()

    for i in range(NUM_OF_TRANSACTIONS):
        blocks = [[random.randint(0,15) for i in range(1024)] for j in range(8)]
        crc_packets = [gen_crc16_packets(block) for block in blocks]
        await bfm.random_delay(10)
        done, crc_fail = await bfm.send_blocks(blocks, crc_packets)
        if(not crc_fail):
            logger.info(f"CRC16 check for blocks pack {i} succeeded!")
        else:
            logger.error(f"CRC16 check for blocks pack {i} failed!")
            passed = False
            break
        if(done):
            logger.info(f"Module received blocks pack {i} successfully!") 
        else:
            logger.error(f"Module did not receive blocks pack {i} successfully!")
            passed = False
            break
        await bfm.random_delay(10)
        blocks_equal, crc_fail = await bfm.receive_blocks(blocks, crc_packets)
        if(blocks_equal):
            logger.info(f"Blocks pack {i} from module is equal the initial blocks pack {i}!") 
        else:
            logger.error(f"Blocks pack {i} from module does not equal the initial blocks pack {i}!")
            passed = False
            break
        if(not crc_fail):
            logger.info(f"Correct CRC in blocks pack {i} from the module!")
        else:
            logger.error(f"Wrong CRC in blocks pack {i} from the module!")
            passed = False
            break
        if(int(bfm.dut.odata_sd_en.value) == 0):
            logger.info(f"Finish bit set in blocks pack {i} from module!") 
        else:
            logger.error(f"Finish bit not set in blocks pack {i} from module!")
            passed = False
            break
    assert passed

