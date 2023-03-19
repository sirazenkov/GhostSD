#=========================================
# company: Tomsk State University
# developer: Simon Razenkov
# e-mail: sirazenkov@stud.tsu.ru
# description: CMD driver module testbench
#=========================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, ClockCycles

import logging

import random

import sys
sys.path.insert(1, '../../')
from common import crc7, Transaction, RCA, transactions

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class CMD_driver_BFM():
    def __init__(self):
        self.dut = cocotb.top

    async def start_operation(self):
        cocotb.start_soon(Clock(self.dut.iclk, 55, units="ns").start())

    async def reset(self):
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value     = 1 
        self.dut.icmd_sd.value  = 1
        self.dut.istart.value   = 0
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
        await FallingEdge(self.dut.iclk)

    async def send_cmd(self, index, arg):
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        self.dut.icmd_index.value = index
        self.dut.icmd_arg.value   = arg
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 0
        start_bit = int(self.dut.ocmd_sd.value)
        await FallingEdge(self.dut.iclk)
        transm_bit = int(self.dut.ocmd_sd.value)
        return start_bit == 0 and transm_bit == 1

    async def check_cmd_field(self, field, length):
        field_ok = True
        for i in range(length):
            await FallingEdge(self.dut.iclk)
            if(int(self.dut.ocmd_sd.value) != ((field >> (length-1-i)) & 1)):
                field_ok = False
        return field_ok

    async def send_response(self, index, resp, crc):
        if(index == 15):
            return int(self.dut.odone.value)
        await FallingEdge(self.dut.iclk)
        self.dut.icmd_sd.value = 0
        await ClockCycles(self.dut.iclk, 2, rising=False)
        if(index == 2):
            self.dut.icmd_sd.value = 1
            for i in range(133):
                if(i == 6):
                    self.dut.icmd_sd.value = 0
                await FallingEdge(self.dut.iclk)
        else:
            for i in range(6):
                if(index == 41):
                    self.dut.icmd_sd.value = 1 
                else:
                    self.dut.icmd_sd.value = 1 & (index >> (5-i))
                await FallingEdge(self.dut.iclk)
            for i in range(32):
                self.dut.icmd_sd.value = 1 & (resp >> (31-i)) 
                await FallingEdge(self.dut.iclk)
            for i in range(7):
                if(index == 41):
                    self.dut.icmd_sd.value = 1 
                else:
                    self.dut.icmd_sd.value = 1 & (crc >> (6-i))
                await FallingEdge(self.dut.iclk)
        self.dut.icmd_sd.value = 1
        await FallingEdge(self.dut.iclk)
        return int(self.dut.odone.value)

    async def random_delay(self, upper_bound):
        delay = random.randint(0,upper_bound)
        await ClockCycles(self.dut.iclk, delay)

@cocotb.test()
async def cmd_driver_tb(_):
    """CMD line's driver testbench""" 
    passed = True
    bfm = CMD_driver_BFM()
    await bfm.start_operation()
    await bfm.reset()

    for trans in transactions:
        await bfm.random_delay(10)
        started = await bfm.send_cmd(trans.index, trans.arg)
        if(started):
            logger.info(f"Started command {trans.index} transmission!")
        else:
            logger.error(f"Failed starting command {trans.index} transmission!")
            passed = False
            break
        index_ok = await bfm.check_cmd_field(trans.index, 6)
        if(index_ok):
            logger.info(f"Command index {trans.index} received successfully!") 
        else:
            logger.error(f"Failed receiving command index {trans.index}!") 
            passed = False
            break
        arg_ok = await bfm.check_cmd_field(trans.arg, 32)
        if(arg_ok):
            logger.info(f"Command argument for (A)CMD{trans.index} received successfully!") 
        else:
            logger.error(f"Failed receiving command argument for (A)CMD{trans.index}!") 
            passed = False
            break
        crc_ok = await bfm.check_cmd_field(trans.cmd_crc, 7)
        if(crc_ok):
            logger.info(f"Command CRC for (A)CMD{trans.index} received successfully!") 
        else:
            logger.error(f"Failed CRC check for (A)CMD{trans.index}!") 
            passed = False
            break
        await FallingEdge(bfm.dut.iclk)
        if(int(bfm.dut.ocmd_sd.value) == 1):
            logger.info(f"End bit set after (A)CMD{trans.index}!") 
        else:
            logger.error(f"End bit not set after (A)CMD{trans.index}!") 
            passed = False
            break
        await bfm.random_delay(10)
        complete_resp = await bfm.send_response(trans.index, trans.resp, trans.resp_crc)
        if(complete_resp):
            logger.info(f"Sent response for command {trans.index}!") 
        else:
            logger.error(f"Failed sending response for command {trans.index}!") 
            passed = False
            break
    assert passed

