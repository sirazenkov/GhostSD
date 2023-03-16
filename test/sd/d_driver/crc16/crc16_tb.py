#=============================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: CRC16 (cyclic redundancy check) module testbench
#=============================================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge

import logging

import random

import sys
sys.path.insert(1, '../../../')
from common import crc16

NUM_OF_TRANSACTIONS = 5

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class CRC16_BFM():
    def __init__(self):
        self.dut = cocotb.top

    async def start_operation(self):
        cocotb.start_soon(Clock(self.dut.iclk, 40, units="ns").start())
    
    async def reset(self):
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 1 
        self.dut.iunload.value = 0
        self.dut.idata.value = 0
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
 
    async def calc_crc(self, data):
        await FallingEdge(self.dut.iclk)
        for i in range(1024):
            self.dut.idata.value = (data >> (1023-i)) & 1
            await FallingEdge(self.dut.iclk)
        self.dut.iunload.value = 1
        result = 0
        for i in range(16):
            result = (result << 1) | int(self.dut.ocrc.value)
            await FallingEdge(self.dut.iclk)
        return result

@cocotb.test()
async def crc16_tb(_):
    """CRC16 module testbench""" 
    passed = True
    bfm = CRC16_BFM()
    await bfm.start_operation()

    for i in range(NUM_OF_TRANSACTIONS):
        await bfm.reset()
        block = random.randint(0,1<<1024)
        expected_crc16 = crc16(block)
        rtl_crc16 = await bfm.calc_crc(block)
        if(rtl_crc16 != expected_crc16):
            passed = False
            logger.error(f"CRC16 calculation failed for round {i}: expected - {expected_crc16}, calculated - {rtl_crc16}!")
            break
        else:
            logger.info(f"CRC16 calculation succeeded for round {i}!") 
    assert passed

