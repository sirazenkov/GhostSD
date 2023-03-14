import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import logging

import random

import sys
sys.path.insert(1, '../../')
from common import crc7

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class Transaction:
    def __init__(self, index, arg, resp):
        self.index = index
        self.arg   = arg
        self.resp  = resp
        self.cmd_crc = crc7(index << 32 | arg)
        self.resp_crc = crc7(resp)

RCA = random.randint(0, 1 << 16)

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
        return int(self.dut.ocmd_sd.value) == 0

    async def check_cmd_field(self, field, length):
        field_ok = True
        for i in range(length):
            await FallingEdge(self.dut.iclk)
            if(int(self.dut.ocmd_sd.value) != ((field >> (length-i)) & 1)):
                field_ok == False
        return field_ok

    async def check_done_cmd(self):
        end_bit_set = int(self.dut.ocmd_sd.value) == 1
        done = int(self.dut.odone.value) == 1
        return (end_bit_set, done)

    async def send_response(self, index, resp, crc):
        await FallingEdge(self.dut.iclk)
        self.dut.icmd_sd.value = 0
        await FallingEdge(self.dut.iclk)
        if(index == 2):
            for i in range(134):
                await FallingEdge(self.dut.iclk)
                if(i == 2):
                    self.dut.icmd_sd.value = 1
                elif(i == 8):
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

transactions = (
    Transaction(55, (1 << 16) - 1, 1 << 5),
    Transaction(41, 1 << 31 | 3 << 20, 1 << 31 | 3 << 20),
    Transaction(2, (1 << 32) - 1, 0),
    Transaction(3, (1 << 32) - 1, RCA << 16),
    Transaction(7, RCA << 16 | (1 << 16) - 1, 3 << 9),
    Transaction(55, RCA << 16 | (1 << 16) - 1, 1 << 5),
    Transaction(6, (1 << 32) - 2, 4 << 9),
    Transaction(17, 0, 4 << 9),
    Transaction(24, 0, 4 << 9),
    Transaction(17, 1, 4 << 9 | 1 << 31),
    Transaction(15, RCA << 16 | (1 << 16) - 1, 0)
    )

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
        crc_ok = await bfm.check_cmd_field(trans.cmd_crc, 32)
        if(crc_ok):
            logger.info(f"Command CRC for (A)CMD{trans.index} received successfully!") 
        else:
            logger.error(f"Failed CRC check for (A)CMD{trans.index}!") 
            passed = False
            break
        cmd_end_bit, cmd_done = await bfm.check_done_cmd()
        if(cmd_end_bit):
            logger.info(f"End bit set after (A)CMD{trans.index}!") 
        else:
            logger.error(f"End bit not set after (A)CMD{trans.index}!") 
            passed = False
            break
        if(cmd_done):
            logger.info(f"(A)CMD{trans.index} successfully transmitted!") 
        else:
            logger.error(f"Module not done after transmitting (A)CMD{trans.index}!") 
            passed = False
            break
        await bfm.random_delay(10)
        complete_resp = await bfm.send_response(trans.index, trans.resp, trans.cmd_crc)
        if(complete_resp):
            logger.info(f"Received response for command {trans.index}!") 
        else:
            logger.error(f"Failed response receiving for command {trans.index}!") 
            passed = False
            break
    assert passed

